import * as functions from 'firebase-functions';
import { admin, stripe } from './index';

interface CommissionCalculation {
  bookingId: string;
  totalAmount: number;
  commissionRate: number;
  commissionAmount: number;
  hostEarnings: number;
  platformFee: number;
}

interface PayoutRequest {
  hostId: string;
  amount: number;
  currency: string;
}

// Calculate commission for a booking
export const calculateCommission = functions.https.onCall(
  async (data: { bookingId: string; totalAmount: number }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { bookingId, totalAmount } = data;
      const db = admin.firestore();

      // Get commission rate (default 15%)
      const settingsDoc = await db.collection('settings').doc('commission').get();
      const commissionRate = settingsDoc.exists ? 
        settingsDoc.data()?.rate || 0.15 : 0.15;

      // Calculate amounts
      const commissionAmount = totalAmount * commissionRate;
      const hostEarnings = totalAmount - commissionAmount;
      const platformFee = commissionAmount;

      const calculation: CommissionCalculation = {
        bookingId,
        totalAmount,
        commissionRate,
        commissionAmount,
        hostEarnings,
        platformFee,
      };

      // Save calculation
      await db.collection('commissionCalculations').doc(bookingId).set({
        ...calculation,
        calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        calculation,
      };
    } catch (error) {
      console.error('Error calculating commission:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to calculate commission'
      );
    }
  }
);

// Process host payout
export const processHostPayout = functions.https.onCall(
  async (data: PayoutRequest, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { hostId, amount, currency } = data;
      const db = admin.firestore();

      // Get host data
      const hostDoc = await db.collection('users').doc(hostId).get();
      if (!hostDoc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Host not found'
        );
      }

      const hostData = hostDoc.data();
      const stripeAccountId = hostData?.stripeAccountId;

      if (!stripeAccountId) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Host does not have a Stripe account'
        );
      }

      // Check if host can receive payouts
      const account = await stripe.accounts.retrieve(stripeAccountId);
      if (!account.payouts_enabled) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Host account is not enabled for payouts'
        );
      }

      // Create payout
      const payout = await stripe.payouts.create(
        {
          amount: Math.round(amount * 100), // Convert to cents
          currency: currency.toLowerCase(),
          method: 'instant',
        },
        {
          stripeAccount: stripeAccountId,
        }
      );

      // Save payout record
      await db.collection('payouts').doc(payout.id).set({
        payoutId: payout.id,
        hostId,
        stripeAccountId,
        amount,
        currency,
        status: payout.status,
        method: payout.method,
        arrivalDate: new Date(payout.arrival_date * 1000),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update host earnings
      await db.collection('users').doc(hostId).update({
        'earnings.totalPaidOut': admin.firestore.FieldValue.increment(amount),
        'earnings.lastPayoutAt': admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        payoutId: payout.id,
        status: payout.status,
        arrivalDate: new Date(payout.arrival_date * 1000),
      };
    } catch (error) {
      console.error('Error processing host payout:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to process payout'
      );
    }
  }
);

// Generate commission report
export const generateCommissionReport = functions.https.onCall(
  async (data: { startDate: string; endDate: string; hostId?: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { startDate, endDate, hostId } = data;
      const db = admin.firestore();

      const start = new Date(startDate);
      const end = new Date(endDate);

      // Build query
      let query = db
        .collection('commissions')
        .where('calculatedAt', '>=', start)
        .where('calculatedAt', '<=', end);

      if (hostId) {
        query = query.where('hostId', '==', hostId);
      }

      const commissionsSnapshot = await query.get();

      let totalCommissions = 0;
      let totalHostEarnings = 0;
      let totalBookings = 0;
      const hostBreakdown: Record<string, any> = {};

      commissionsSnapshot.forEach(doc => {
        const commission = doc.data();
        totalCommissions += commission.amount || 0;
        totalHostEarnings += commission.hostEarnings || 0;
        totalBookings++;

        // Host breakdown
        if (!hostBreakdown[commission.hostId]) {
          hostBreakdown[commission.hostId] = {
            hostId: commission.hostId,
            totalCommissions: 0,
            totalEarnings: 0,
            bookingsCount: 0,
          };
        }

        hostBreakdown[commission.hostId].totalCommissions += commission.amount || 0;
        hostBreakdown[commission.hostId].totalEarnings += commission.hostEarnings || 0;
        hostBreakdown[commission.hostId].bookingsCount++;
      });

      const report = {
        period: { startDate, endDate },
        summary: {
          totalCommissions,
          totalHostEarnings,
          totalBookings,
          averageCommissionPerBooking: totalBookings > 0 ? totalCommissions / totalBookings : 0,
        },
        hostBreakdown: Object.values(hostBreakdown),
        generatedAt: new Date().toISOString(),
      };

      // Save report
      const reportRef = await db.collection('reports').add({
        type: 'commission',
        ...report,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        reportId: reportRef.id,
        report,
      };
    } catch (error) {
      console.error('Error generating commission report:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to generate commission report'
      );
    }
  }
);

// Update commission rates
export const updateCommissionRates = functions.https.onCall(
  async (data: { rate: number; effectiveDate?: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      // Check if user is admin
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(context.auth.uid)
        .get();

      if (!userDoc.exists || userDoc.data()?.role !== 'admin') {
        throw new functions.https.HttpsError(
          'permission-denied',
          'Only admins can update commission rates'
        );
      }

      const { rate, effectiveDate } = data;
      const db = admin.firestore();

      // Validate rate
      if (rate < 0 || rate > 1) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Commission rate must be between 0 and 1'
        );
      }

      const effective = effectiveDate ? new Date(effectiveDate) : new Date();

      // Update commission settings
      await db.collection('settings').doc('commission').set({
        rate,
        effectiveDate: effective,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: context.auth.uid,
      }, { merge: true });

      // Log the change
      await db.collection('commissionHistory').add({
        previousRate: null, // TODO: Get previous rate
        newRate: rate,
        effectiveDate: effective,
        updatedBy: context.auth.uid,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        rate,
        effectiveDate: effective,
      };
    } catch (error) {
      console.error('Error updating commission rates:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to update commission rates'
      );
    }
  }
);

export const commissionFunctions = {
  calculateCommission,
  processHostPayout,
  generateCommissionReport,
  updateCommissionRates,
};