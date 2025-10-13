import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import express from 'express';
import cors from 'cors';
import Stripe from 'stripe';

// Initialize Firebase Admin
admin.initializeApp();

// Initialize Stripe
export const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: '2023-10-16',
});

// Express app for webhooks
const app = express();
app.use(cors({ origin: true }));
app.use(express.raw({ type: 'application/json' }));

// Import function modules
import { paymentFunctions } from './payments';
import { webhookFunctions } from './webhooks';
import { commissionFunctions } from './commissions';
import { notificationFunctions } from './notifications';
import { bookingFunctions } from './bookings';
import { hostFunctions } from './hosts';
import { adminFunctions } from './admin';

// Export all functions
export const {
  createPaymentIntent,
  confirmPayment,
  processRefund,
  capturePayment,
  calculatePaymentAmount,
} = paymentFunctions;

export const {
  stripeWebhook,
  handlePaymentSucceeded,
  handlePaymentFailed,
  handleAccountUpdated,
} = webhookFunctions;

export const {
  calculateCommission,
  processHostPayout,
  generateCommissionReport,
  updateCommissionRates,
} = commissionFunctions;

export const {
  sendBookingConfirmation,
  sendPaymentNotification,
  sendHostNotification,
  sendPushNotification,
} = notificationFunctions;

export const {
  createBooking,
  updateBookingStatus,
  cancelBooking,
  checkAvailability,
  processBookingPayment,
} = bookingFunctions;

export const {
  onboardHost,
  updateHostStatus,
  verifyHostAccount,
  calculateHostEarnings,
} = hostFunctions;

export const {
  generateDashboardData,
  exportBookingData,
  generateReports,
  manageUsers,
} = adminFunctions;

// Health check endpoint
export const healthCheck = functions.https.onRequest((req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// Scheduled functions
export const dailyCommissionCalculation = functions.pubsub
  .schedule('0 2 * * *') // Run at 2 AM daily
  .timeZone('America/Mexico_City')
  .onRun(async (context) => {
    console.log('Running daily commission calculation...');
    
    try {
      const db = admin.firestore();
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      yesterday.setHours(0, 0, 0, 0);
      
      const endOfYesterday = new Date(yesterday);
      endOfYesterday.setHours(23, 59, 59, 999);
      
      // Get completed bookings from yesterday
      const bookingsSnapshot = await db
        .collection('bookings')
        .where('status', '==', 'completed')
        .where('completedAt', '>=', yesterday)
        .where('completedAt', '<=', endOfYesterday)
        .get();
      
      const batch = db.batch();
      
      for (const doc of bookingsSnapshot.docs) {
        const booking = doc.data();
        
        // Calculate commission
        const commissionAmount = booking.totalAmount * 0.15; // 15% commission
        const hostEarnings = booking.totalAmount - commissionAmount;
        
        // Update booking with commission data
        batch.update(doc.ref, {
          commissionAmount,
          hostEarnings,
          commissionCalculatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        // Create commission record
        const commissionRef = db.collection('commissions').doc();
        batch.set(commissionRef, {
          bookingId: doc.id,
          hostId: booking.hostId,
          amount: commissionAmount,
          hostEarnings,
          totalAmount: booking.totalAmount,
          calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
          period: {
            year: yesterday.getFullYear(),
            month: yesterday.getMonth() + 1,
            day: yesterday.getDate(),
          },
        });
      }
      
      await batch.commit();
      console.log(`Processed ${bookingsSnapshot.size} bookings for commission calculation`);
      
    } catch (error) {
      console.error('Error in daily commission calculation:', error);
      throw error;
    }
  });

// Weekly reports
export const weeklyReports = functions.pubsub
  .schedule('0 9 * * 1') // Run at 9 AM every Monday
  .timeZone('America/Mexico_City')
  .onRun(async (context) => {
    console.log('Generating weekly reports...');
    
    try {
      const db = admin.firestore();
      const now = new Date();
      const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      
      // Generate host earnings reports
      const hostsSnapshot = await db
        .collection('users')
        .where('role', '==', 'host')
        .where('isActive', '==', true)
        .get();
      
      for (const hostDoc of hostsSnapshot.docs) {
        const hostId = hostDoc.id;
        
        // Calculate weekly earnings
        const commissionsSnapshot = await db
          .collection('commissions')
          .where('hostId', '==', hostId)
          .where('calculatedAt', '>=', weekAgo)
          .where('calculatedAt', '<=', now)
          .get();
        
        let totalEarnings = 0;
        let totalCommissions = 0;
        
        commissionsSnapshot.forEach(doc => {
          const commission = doc.data();
          totalEarnings += commission.hostEarnings || 0;
          totalCommissions += commission.amount || 0;
        });
        
        // Save weekly report
        await db.collection('reports').doc().set({
          type: 'weekly_host_earnings',
          hostId,
          period: {
            start: weekAgo,
            end: now,
            week: getWeekNumber(now),
            year: now.getFullYear(),
          },
          data: {
            totalEarnings,
            totalCommissions,
            bookingsCount: commissionsSnapshot.size,
          },
          generatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      
      console.log(`Generated weekly reports for ${hostsSnapshot.size} hosts`);
      
    } catch (error) {
      console.error('Error generating weekly reports:', error);
      throw error;
    }
  });

// Helper function to get week number
function getWeekNumber(date: Date): number {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
}

// Export Firestore and Stripe instances for use in other modules
export { admin, stripe };

// Export types
export interface BookingData {
  id: string;
  userId: string;
  hostId: string;
  listingId: string;
  startDate: Date;
  endDate: Date;
  guests: number;
  totalAmount: number;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  paymentIntentId?: string;
  commissionAmount?: number;
  hostEarnings?: number;
}

export interface CommissionData {
  bookingId: string;
  hostId: string;
  amount: number;
  hostEarnings: number;
  totalAmount: number;
  calculatedAt: Date;
  period: {
    year: number;
    month: number;
    day: number;
  };
}

export interface HostData {
  id: string;
  stripeAccountId?: string;
  onboardingComplete: boolean;
  payoutsEnabled: boolean;
  chargesEnabled: boolean;
  isActive: boolean;
}

export interface NotificationData {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, any>;
  type: 'booking' | 'payment' | 'host' | 'general';
}