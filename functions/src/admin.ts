import * as functions from 'firebase-functions';
import { admin } from './index';

interface DashboardQuery {
  period?: 'week' | 'month' | 'year';
  startDate?: string;
  endDate?: string;
}

interface ExportQuery {
  type: 'bookings' | 'users' | 'earnings' | 'listings';
  startDate: string;
  endDate: string;
  format: 'csv' | 'json';
}

interface UserManagementAction {
  userId: string;
  action: 'suspend' | 'activate' | 'delete' | 'promote' | 'demote';
  reason?: string;
}

// Generate dashboard data
export const generateDashboardData = functions.https.onCall(
  async (data: DashboardQuery, context) => {
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
          'Only admins can access dashboard data'
        );
      }

      const { period, startDate, endDate } = data;
      const db = admin.firestore();

      // Determine date range
      let start: Date;
      let end: Date;

      if (startDate && endDate) {
        start = new Date(startDate);
        end = new Date(endDate);
      } else {
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
      }

      // Get metrics in parallel
      const [usersSnapshot, hostsSnapshot, listingsSnapshot, bookingsSnapshot, commissionsSnapshot] = await Promise.all([
        db.collection('users').where('createdAt', '>=', start).where('createdAt', '<=', end).get(),
        db.collection('users').where('role', '==', 'host').where('createdAt', '>=', start).where('createdAt', '<=', end).get(),
        db.collection('listings').where('createdAt', '>=', start).where('createdAt', '<=', end).get(),
        db.collection('bookings').where('createdAt', '>=', start).where('createdAt', '<=', end).get(),
        db.collection('commissions').where('calculatedAt', '>=', start).where('calculatedAt', '<=', end).get(),
      ]);

      // Calculate metrics
      const metrics = {
        users: {
          total: usersSnapshot.size,
          new: usersSnapshot.size,
          active: 0, // Calculate based on recent activity
        },
        hosts: {
          total: hostsSnapshot.size,
          new: hostsSnapshot.size,
          verified: 0,
        },
        listings: {
          total: listingsSnapshot.size,
          new: listingsSnapshot.size,
          active: 0,
        },
        bookings: {
          total: bookingsSnapshot.size,
          confirmed: 0,
          completed: 0,
          cancelled: 0,
        },
        revenue: {
          total: 0,
          commissions: 0,
          hostEarnings: 0,
        },
      };

      // Process bookings data
      bookingsSnapshot.forEach(doc => {
        const booking = doc.data();
        switch (booking.status) {
          case 'confirmed':
            metrics.bookings.confirmed++;
            break;
          case 'completed':
            metrics.bookings.completed++;
            metrics.revenue.total += booking.totalAmount || 0;
            break;
          case 'cancelled':
            metrics.bookings.cancelled++;
            break;
        }
      });

      // Process commissions data
      commissionsSnapshot.forEach(doc => {
        const commission = doc.data();
        metrics.revenue.commissions += commission.amount || 0;
        metrics.revenue.hostEarnings += commission.hostEarnings || 0;
      });

      // Process hosts data
      hostsSnapshot.forEach(doc => {
        const host = doc.data();
        if (host.hostVerified) {
          metrics.hosts.verified++;
        }
      });

      // Process listings data
      listingsSnapshot.forEach(doc => {
        const listing = doc.data();
        if (listing.status === 'active') {
          metrics.listings.active++;
        }
      });

      // Get top performers
      const topHosts = await getTopHosts(start, end);
      const topListings = await getTopListings(start, end);
      const recentActivity = await getRecentActivity();

      return {
        success: true,
        dashboard: {
          period: {
            start: start.toISOString(),
            end: end.toISOString(),
          },
          metrics,
          topHosts,
          topListings,
          recentActivity,
          generatedAt: new Date().toISOString(),
        },
      };
    } catch (error) {
      console.error('Error generating dashboard data:', error);
      throw new functions.https.HttpsError('internal', 'Failed to generate dashboard data');
    }
  }
);

// Export booking data
export const exportBookingData = functions.https.onCall(
  async (data: ExportQuery, context) => {
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
          'Only admins can export data'
        );
      }

      const { type, startDate, endDate, format } = data;
      const db = admin.firestore();

      const start = new Date(startDate);
      const end = new Date(endDate);

      let collection = '';
      let dateField = 'createdAt';

      switch (type) {
        case 'bookings':
          collection = 'bookings';
          break;
        case 'users':
          collection = 'users';
          break;
        case 'earnings':
          collection = 'commissions';
          dateField = 'calculatedAt';
          break;
        case 'listings':
          collection = 'listings';
          break;
        default:
          throw new functions.https.HttpsError('invalid-argument', 'Invalid export type');
      }

      // Get data
      const snapshot = await db
        .collection(collection)
        .where(dateField, '>=', start)
        .where(dateField, '<=', end)
        .get();

      const exportData = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));

      // Format data based on requested format
      let formattedData: string;
      let contentType: string;

      if (format === 'csv') {
        formattedData = convertToCSV(exportData);
        contentType = 'text/csv';
      } else {
        formattedData = JSON.stringify(exportData, null, 2);
        contentType = 'application/json';
      }

      // Save export file to Cloud Storage
      const bucket = admin.storage().bucket();
      const fileName = `exports/${type}_${startDate}_${endDate}.${format}`;
      const file = bucket.file(fileName);

      await file.save(formattedData, {
        metadata: {
          contentType,
        },
      });

      // Generate signed URL for download
      const [url] = await file.getSignedUrl({
        action: 'read',
        expires: Date.now() + 24 * 60 * 60 * 1000, // 24 hours
      });

      return {
        success: true,
        downloadUrl: url,
        fileName,
        recordCount: exportData.length,
      };
    } catch (error) {
      console.error('Error exporting data:', error);
      throw new functions.https.HttpsError('internal', 'Failed to export data');
    }
  }
);

// Generate reports
export const generateReports = functions.https.onCall(
  async (data: { reportType: string; period: string }, context) => {
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
          'Only admins can generate reports'
        );
      }

      const { reportType, period } = data;
      const db = admin.firestore();

      // Generate report based on type
      let report: any;

      switch (reportType) {
        case 'revenue':
          report = await generateRevenueReport(period);
          break;
        case 'hosts':
          report = await generateHostsReport(period);
          break;
        case 'bookings':
          report = await generateBookingsReport(period);
          break;
        default:
          throw new functions.https.HttpsError('invalid-argument', 'Invalid report type');
      }

      // Save report
      const reportRef = await db.collection('reports').add({
        type: reportType,
        period,
        data: report,
        generatedBy: context.auth.uid,
        generatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        reportId: reportRef.id,
        report,
      };
    } catch (error) {
      console.error('Error generating reports:', error);
      throw new functions.https.HttpsError('internal', 'Failed to generate reports');
    }
  }
);

// Manage users
export const manageUsers = functions.https.onCall(
  async (data: UserManagementAction, context) => {
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
          'Only admins can manage users'
        );
      }

      const { userId, action, reason } = data;
      const db = admin.firestore();

      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User not found');
      }

      const updateData: any = {
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: context.auth.uid,
      };

      switch (action) {
        case 'suspend':
          updateData.status = 'suspended';
          updateData.suspendedAt = admin.firestore.FieldValue.serverTimestamp();
          updateData.suspensionReason = reason;
          break;
        case 'activate':
          updateData.status = 'active';
          updateData.activatedAt = admin.firestore.FieldValue.serverTimestamp();
          break;
        case 'promote':
          updateData.role = 'admin';
          updateData.promotedAt = admin.firestore.FieldValue.serverTimestamp();
          break;
        case 'demote':
          updateData.role = 'user';
          updateData.demotedAt = admin.firestore.FieldValue.serverTimestamp();
          break;
        case 'delete':
          // Soft delete
          updateData.deleted = true;
          updateData.deletedAt = admin.firestore.FieldValue.serverTimestamp();
          updateData.deletionReason = reason;
          break;
      }

      await userDoc.ref.update(updateData);

      // Log admin action
      await db.collection('adminActions').add({
        adminId: context.auth.uid,
        targetUserId: userId,
        action,
        reason,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        action,
        userId,
        updatedAt: new Date(),
      };
    } catch (error) {
      console.error('Error managing user:', error);
      throw new functions.https.HttpsError('internal', 'Failed to manage user');
    }
  }
);

// Helper functions
const getTopHosts = async (start: Date, end: Date) => {
  const db = admin.firestore();
  
  // This would require aggregation - simplified for now
  const hostsSnapshot = await db
    .collection('users')
    .where('role', '==', 'host')
    .limit(10)
    .get();

  return hostsSnapshot.docs.map(doc => ({
    id: doc.id,
    name: doc.data().displayName,
    earnings: 0, // Calculate from bookings
    bookings: 0, // Calculate from bookings
  }));
};

const getTopListings = async (start: Date, end: Date) => {
  const db = admin.firestore();
  
  const listingsSnapshot = await db
    .collection('listings')
    .where('status', '==', 'active')
    .limit(10)
    .get();

  return listingsSnapshot.docs.map(doc => ({
    id: doc.id,
    title: doc.data().title,
    bookings: 0, // Calculate from bookings
    revenue: 0, // Calculate from bookings
  }));
};

const getRecentActivity = async () => {
  const db = admin.firestore();
  
  const activitiesSnapshot = await db
    .collection('bookings')
    .orderBy('createdAt', 'desc')
    .limit(20)
    .get();

  return activitiesSnapshot.docs.map(doc => ({
    id: doc.id,
    type: 'booking',
    description: `New booking created`,
    timestamp: doc.data().createdAt,
  }));
};

const generateRevenueReport = async (period: string) => {
  // Implementation for revenue report
  return {
    totalRevenue: 0,
    commissions: 0,
    hostEarnings: 0,
    period,
  };
};

const generateHostsReport = async (period: string) => {
  // Implementation for hosts report
  return {
    totalHosts: 0,
    activeHosts: 0,
    newHosts: 0,
    period,
  };
};

const generateBookingsReport = async (period: string) => {
  // Implementation for bookings report
  return {
    totalBookings: 0,
    confirmedBookings: 0,
    completedBookings: 0,
    period,
  };
};

const convertToCSV = (data: any[]): string => {
  if (data.length === 0) return '';
  
  const headers = Object.keys(data[0]);
  const csvContent = [
    headers.join(','),
    ...data.map(row => 
      headers.map(header => {
        const value = row[header];
        return typeof value === 'string' ? `"${value.replace(/"/g, '""')}"` : value;
      }).join(',')
    )
  ].join('\n');
  
  return csvContent;
};

export const adminFunctions = {
  generateDashboardData,
  exportBookingData,
  generateReports,
  manageUsers,
};