import * as functions from 'firebase-functions';
import { admin, stripe } from './index';

interface HostOnboardingData {
  userId: string;
  businessType: 'individual' | 'company';
  country: string;
  email: string;
  phone: string;
  businessProfile?: {
    name: string;
    description: string;
    website?: string;
  };
}

interface HostEarningsQuery {
  hostId: string;
  startDate?: string;
  endDate?: string;
  period?: 'week' | 'month' | 'year';
}

// Onboard host with Stripe Connect
export const onboardHost = functions.https.onCall(
  async (data: HostOnboardingData, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { userId, businessType, country, email, phone, businessProfile } = data;
      const db = admin.firestore();

      // Check if user already has a Stripe account
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User not found');
      }

      const userData = userDoc.data();
      if (userData?.stripeAccountId) {
        throw new functions.https.HttpsError(
          'already-exists',
          'User already has a Stripe account'
        );
      }

      // Create Stripe Connect Express account
      const account = await stripe.accounts.create({
        type: 'express',
        country: country.toUpperCase(),
        email,
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
        business_type: businessType,
        business_profile: businessProfile ? {
          name: businessProfile.name,
          product_description: businessProfile.description,
          url: businessProfile.website,
        } : undefined,
        metadata: {
          userId,
          platform: 'salas_beats',
        },
      });

      // Update user with Stripe account ID
      await userDoc.ref.update({
        stripeAccountId: account.id,
        role: 'host',
        hostOnboardingStarted: true,
        stripeAccountStatus: {
          chargesEnabled: account.charges_enabled,
          payoutsEnabled: account.payouts_enabled,
          detailsSubmitted: account.details_submitted,
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Create onboarding link
      const accountLink = await stripe.accountLinks.create({
        account: account.id,
        refresh_url: `${functions.config().app.base_url}/host/onboarding/refresh`,
        return_url: `${functions.config().app.base_url}/host/dashboard`,
        type: 'account_onboarding',
      });

      return {
        success: true,
        accountId: account.id,
        onboardingUrl: accountLink.url,
      };
    } catch (error) {
      console.error('Error onboarding host:', error);
      throw new functions.https.HttpsError('internal', 'Failed to onboard host');
    }
  }
);

// Update host status
export const updateHostStatus = functions.https.onCall(
  async (data: { hostId: string; status: 'active' | 'inactive' | 'suspended'; reason?: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      // Check if user is admin
      const adminDoc = await admin.firestore()
        .collection('users')
        .doc(context.auth.uid)
        .get();

      if (!adminDoc.exists || adminDoc.data()?.role !== 'admin') {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Only admins can update host status'
        );
      }

      const { hostId, status, reason } = data;
      const db = admin.firestore();

      // Update host status
      await db.collection('users').doc(hostId).update({
        hostStatus: status,
        hostStatusReason: reason || '',
        hostStatusUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        hostStatusUpdatedBy: context.auth.uid,
      });

      // If suspended, deactivate all listings
      if (status === 'suspended') {
        const listingsSnapshot = await db
          .collection('listings')
          .where('hostId', '==', hostId)
          .where('status', '==', 'active')
          .get();

        const batch = db.batch();
        listingsSnapshot.forEach(doc => {
          batch.update(doc.ref, {
            status: 'suspended',
            suspendedAt: admin.firestore.FieldValue.serverTimestamp(),
            suspensionReason: 'Host suspended',
          });
        });

        await batch.commit();
      }

      return {
        success: true,
        status,
        updatedAt: new Date(),
      };
    } catch (error) {
      console.error('Error updating host status:', error);
      throw new functions.https.HttpsError('internal', 'Failed to update host status');
    }
  }
);

// Verify host account
export const verifyHostAccount = functions.https.onCall(
  async (data: { hostId: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { hostId } = data;
      const db = admin.firestore();

      // Get host data
      const hostDoc = await db.collection('users').doc(hostId).get();
      if (!hostDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Host not found');
      }

      const hostData = hostDoc.data();
      const stripeAccountId = hostData?.stripeAccountId;

      if (!stripeAccountId) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Host does not have a Stripe account'
        );
      }

      // Get Stripe account details
      const account = await stripe.accounts.retrieve(stripeAccountId);

      // Update host with current Stripe status
      await hostDoc.ref.update({
        stripeAccountStatus: {
          chargesEnabled: account.charges_enabled,
          payoutsEnabled: account.payouts_enabled,
          detailsSubmitted: account.details_submitted,
          requirementsCurrentlyDue: account.requirements?.currently_due || [],
          requirementsEventuallyDue: account.requirements?.eventually_due || [],
          requirementsPastDue: account.requirements?.past_due || [],
        },
        hostVerified: account.charges_enabled && account.payouts_enabled,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        verified: account.charges_enabled && account.payouts_enabled,
        accountStatus: {
          chargesEnabled: account.charges_enabled,
          payoutsEnabled: account.payouts_enabled,
          detailsSubmitted: account.details_submitted,
          requirementsCurrentlyDue: account.requirements?.currently_due || [],
          requirementsEventuallyDue: account.requirements?.eventually_due || [],
          requirementsPastDue: account.requirements?.past_due || [],
        },
      };
    } catch (error) {
      console.error('Error verifying host account:', error);
      throw new functions.https.HttpsError('internal', 'Failed to verify host account');
    }
  }
);

// Calculate host earnings
export const calculateHostEarnings = functions.https.onCall(
  async (data: HostEarningsQuery, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { hostId, startDate, endDate, period } = data;
      const db = admin.firestore();

      // Determine date range
      let start: Date;
      let end: Date;

      if (startDate && endDate) {
        start = new Date(startDate);
        end = new Date(endDate);
      } else if (period) {
        end = new Date();
        switch (period) {
          case 'week':
            start = new Date(end.getTime() - 7 * 24 * 60 * 60 * 1000);
            break;
          case 'month':
            start = new Date(end.getFullYear(), end.getMonth(), 1);
            break;
          case 'year':
            start = new Date(end.getFullYear(), 0, 1);
            break;
          default:
            start = new Date(end.getTime() - 30 * 24 * 60 * 60 * 1000);
        }
      } else {
        // Default to last 30 days
        end = new Date();
        start = new Date(end.getTime() - 30 * 24 * 60 * 60 * 1000);
      }

      // Get completed bookings for the period
      const bookingsSnapshot = await db
        .collection('bookings')
        .where('hostId', '==', hostId)
        .where('status', '==', 'completed')
        .where('completedAt', '>=', start)
        .where('completedAt', '<=', end)
        .get();

      let totalRevenue = 0;
      let totalCommissions = 0;
      let totalEarnings = 0;
      let bookingsCount = 0;
      const dailyEarnings: Record<string, number> = {};

      bookingsSnapshot.forEach(doc => {
        const booking = doc.data();
        const revenue = booking.totalAmount || 0;
        const commission = booking.commissionAmount || (revenue * 0.15);
        const earnings = revenue - commission;

        totalRevenue += revenue;
        totalCommissions += commission;
        totalEarnings += earnings;
        bookingsCount++;

        // Daily breakdown
        const dateKey = booking.completedAt.toDate().toISOString().split('T')[0];
        dailyEarnings[dateKey] = (dailyEarnings[dateKey] || 0) + earnings;
      });

      // Get pending earnings (confirmed but not completed)
      const pendingBookingsSnapshot = await db
        .collection('bookings')
        .where('hostId', '==', hostId)
        .where('status', '==', 'confirmed')
        .get();

      let pendingEarnings = 0;
      pendingBookingsSnapshot.forEach(doc => {
        const booking = doc.data();
        const revenue = booking.totalAmount || 0;
        const commission = booking.commissionAmount || (revenue * 0.15);
        pendingEarnings += revenue - commission;
      });

      // Get payout history
      const payoutsSnapshot = await db
        .collection('payouts')
        .where('hostId', '==', hostId)
        .where('paidAt', '>=', start)
        .where('paidAt', '<=', end)
        .get();

      let totalPayouts = 0;
      payoutsSnapshot.forEach(doc => {
        const payout = doc.data();
        totalPayouts += payout.amount || 0;
      });

      const earnings = {
        period: {
          start: start.toISOString(),
          end: end.toISOString(),
        },
        summary: {
          totalRevenue,
          totalCommissions,
          totalEarnings,
          pendingEarnings,
          totalPayouts,
          availableForPayout: totalEarnings - totalPayouts,
          bookingsCount,
          averageEarningsPerBooking: bookingsCount > 0 ? totalEarnings / bookingsCount : 0,
        },
        dailyBreakdown: Object.entries(dailyEarnings).map(([date, amount]) => ({
          date,
          earnings: amount,
        })),
      };

      return {
        success: true,
        earnings,
      };
    } catch (error) {
      console.error('Error calculating host earnings:', error);
      throw new functions.https.HttpsError('internal', 'Failed to calculate earnings');
    }
  }
);

export const hostFunctions = {
  onboardHost,
  updateHostStatus,
  verifyHostAccount,
  calculateHostEarnings,
};