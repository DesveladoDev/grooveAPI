import * as functions from 'firebase-functions';
import { admin, stripe } from './index';
import Stripe from 'stripe';

interface PaymentIntentData {
  amount: number;
  currency: string;
  hostAccountId: string;
  bookingId: string;
  userId: string;
  metadata?: Record<string, string>;
}

interface PaymentResult {
  success: boolean;
  paymentIntentId?: string;
  clientSecret?: string;
  error?: string;
}

// Create payment intent with application fee
export const createPaymentIntent = functions.https.onCall(
  async (data: PaymentIntentData, context) => {
    try {
      // Verify authentication
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { amount, currency, hostAccountId, bookingId, userId, metadata } = data;

      // Validate input
      if (!amount || !currency || !hostAccountId || !bookingId) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Missing required payment data'
        );
      }

      // Calculate application fee (15% commission)
      const applicationFeeAmount = Math.round(amount * 0.15);

      // Create payment intent
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount * 100), // Convert to cents
        currency: currency.toLowerCase(),
        application_fee_amount: applicationFeeAmount * 100,
        transfer_data: {
          destination: hostAccountId,
        },
        metadata: {
          bookingId,
          userId,
          hostAccountId,
          ...metadata,
        },
      });

      // Save payment intent to Firestore
      await admin.firestore().collection('payments').doc(paymentIntent.id).set({
        paymentIntentId: paymentIntent.id,
        bookingId,
        userId,
        hostAccountId,
        amount,
        currency,
        applicationFeeAmount,
        status: 'created',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        paymentIntentId: paymentIntent.id,
        clientSecret: paymentIntent.client_secret,
      };
    } catch (error) {
      console.error('Error creating payment intent:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to create payment intent'
      );
    }
  }
);

// Confirm payment
export const confirmPayment = functions.https.onCall(
  async (data: { paymentIntentId: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { paymentIntentId } = data;

      // Retrieve payment intent
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

      if (paymentIntent.status === 'succeeded') {
        // Update payment record
        await admin.firestore()
          .collection('payments')
          .doc(paymentIntentId)
          .update({
            status: 'succeeded',
            confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

        // Update booking status
        if (paymentIntent.metadata.bookingId) {
          await admin.firestore()
            .collection('bookings')
            .doc(paymentIntent.metadata.bookingId)
            .update({
              status: 'confirmed',
              paymentStatus: 'paid',
              confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }

        return { success: true, status: 'succeeded' };
      }

      return { success: false, status: paymentIntent.status };
    } catch (error) {
      console.error('Error confirming payment:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to confirm payment'
      );
    }
  }
);

// Process refund
export const processRefund = functions.https.onCall(
  async (data: { paymentIntentId: string; amount?: number; reason?: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { paymentIntentId, amount, reason } = data;

      // Create refund
      const refund = await stripe.refunds.create({
        payment_intent: paymentIntentId,
        amount: amount ? Math.round(amount * 100) : undefined,
        reason: reason as Stripe.RefundCreateParams.Reason,
        refund_application_fee: true,
      });

      // Update payment record
      await admin.firestore()
        .collection('payments')
        .doc(paymentIntentId)
        .update({
          refundId: refund.id,
          refundAmount: refund.amount / 100,
          refundStatus: refund.status,
          refundedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      // Update booking if applicable
      const paymentDoc = await admin.firestore()
        .collection('payments')
        .doc(paymentIntentId)
        .get();

      if (paymentDoc.exists) {
        const paymentData = paymentDoc.data();
        if (paymentData?.bookingId) {
          await admin.firestore()
            .collection('bookings')
            .doc(paymentData.bookingId)
            .update({
              status: 'cancelled',
              refundStatus: refund.status,
              cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
      }

      return {
        success: true,
        refundId: refund.id,
        amount: refund.amount / 100,
        status: refund.status,
      };
    } catch (error) {
      console.error('Error processing refund:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to process refund'
      );
    }
  }
);

// Capture payment (for manual capture)
export const capturePayment = functions.https.onCall(
  async (data: { paymentIntentId: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { paymentIntentId } = data;

      // Capture payment intent
      const paymentIntent = await stripe.paymentIntents.capture(paymentIntentId);

      // Update payment record
      await admin.firestore()
        .collection('payments')
        .doc(paymentIntentId)
        .update({
          status: 'captured',
          capturedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      return {
        success: true,
        status: paymentIntent.status,
      };
    } catch (error) {
      console.error('Error capturing payment:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to capture payment'
      );
    }
  }
);

// Calculate payment amount with fees
export const calculatePaymentAmount = functions.https.onCall(
  async (data: { baseAmount: number; currency: string }, context) => {
    try {
      const { baseAmount, currency } = data;

      // Platform commission (15%)
      const platformFee = baseAmount * 0.15;
      
      // Stripe processing fee (2.9% + $0.30)
      const stripeFee = (baseAmount * 0.029) + 0.30;
      
      // Total amount user pays
      const totalAmount = baseAmount + stripeFee;
      
      // Host receives
      const hostAmount = baseAmount - platformFee;

      return {
        success: true,
        breakdown: {
          baseAmount,
          platformFee,
          stripeFee,
          totalAmount,
          hostAmount,
          currency,
        },
      };
    } catch (error) {
      console.error('Error calculating payment amount:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to calculate payment amount'
      );
    }
  }
);

export const paymentFunctions = {
  createPaymentIntent,
  confirmPayment,
  processRefund,
  capturePayment,
  calculatePaymentAmount,
};