import * as functions from 'firebase-functions';
import { admin } from './index';
import express from 'express';
import Stripe from 'stripe';

const stripe = new Stripe(functions.config().stripe.secret_key, { apiVersion: '2023-10-16' });

// Stripe webhook endpoint
export const stripeWebhook = functions.https.onRequest(async (req: functions.Request, res: functions.Response) => {
  const sig = req.headers['stripe-signature'] as string;
  const endpointSecret = functions.config().stripe.webhook_secret;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err);
    res.status(400).send(`Webhook Error: ${err}`);
    return;
  }

  try {
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentSucceeded(event.data.object as Stripe.PaymentIntent);
        break;
      case 'payment_intent.payment_failed':
        await handlePaymentFailed(event.data.object as Stripe.PaymentIntent);
        break;
      case 'account.updated':
        await handleAccountUpdated(event.data.object as Stripe.Account);
        break;
      case 'transfer.created':
        await handleTransferCreated(event.data.object as Stripe.Transfer);
        break;
      case 'payout.paid':
        await handlePayoutPaid(event.data.object as Stripe.Payout);
        break;
      case 'payout.failed':
        await handlePayoutFailed(event.data.object as Stripe.Payout);
        break;
      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Error processing webhook:', error);
    res.status(500).json({ error: 'Webhook processing failed' });
  }
});

// Handle successful payment
export const handlePaymentSucceeded = async (paymentIntent: Stripe.PaymentIntent) => {
  try {
    const db = admin.firestore();
    const paymentIntentId = paymentIntent.id;
    const bookingId = paymentIntent.metadata.bookingId;

    // Update payment record
    await db.collection('payments').doc(paymentIntentId).update({
      status: 'succeeded',
      succeededAt: admin.firestore.FieldValue.serverTimestamp(),
      stripeData: {
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
        charges: [],
      },
    });

    if (bookingId) {
      // Update booking status
      await db.collection('bookings').doc(bookingId).update({
        status: 'confirmed',
        paymentStatus: 'paid',
        confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Get booking details for notifications
      const bookingDoc = await db.collection('bookings').doc(bookingId).get();
      if (bookingDoc.exists) {
        const booking = bookingDoc.data();
        
        // Send confirmation notifications
        await sendBookingConfirmationNotifications(booking, paymentIntent);
        
        // Update listing availability
        await updateListingAvailability(booking);
      }
    }

    console.log(`Payment succeeded for PaymentIntent: ${paymentIntentId}`);
  } catch (error) {
    console.error('Error handling payment succeeded:', error);
    throw error;
  }
};

// Handle failed payment
export const handlePaymentFailed = async (paymentIntent: Stripe.PaymentIntent) => {
  try {
    const db = admin.firestore();
    const paymentIntentId = paymentIntent.id;
    const bookingId = paymentIntent.metadata.bookingId;

    // Update payment record
    await db.collection('payments').doc(paymentIntentId).update({
      status: 'failed',
      failedAt: admin.firestore.FieldValue.serverTimestamp(),
      failureReason: paymentIntent.last_payment_error?.message || 'Unknown error',
    });

    if (bookingId) {
      // Update booking status
      await db.collection('bookings').doc(bookingId).update({
        status: 'payment_failed',
        paymentStatus: 'failed',
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Get booking details for notifications
      const bookingDoc = await db.collection('bookings').doc(bookingId).get();
      if (bookingDoc.exists) {
        const booking = bookingDoc.data();
        
        // Send failure notifications
        await sendPaymentFailureNotifications(booking, paymentIntent);
      }
    }

    console.log(`Payment failed for PaymentIntent: ${paymentIntentId}`);
  } catch (error) {
    console.error('Error handling payment failed:', error);
    throw error;
  }
};

// Handle account updates
export const handleAccountUpdated = async (account: Stripe.Account) => {
  try {
    const db = admin.firestore();
    const accountId = account.id;

    // Find host with this Stripe account
    const hostsSnapshot = await db
      .collection('users')
      .where('stripeAccountId', '==', accountId)
      .limit(1)
      .get();

    if (!hostsSnapshot.empty) {
      const hostDoc = hostsSnapshot.docs[0];
      
      // Update host account status
      await hostDoc.ref.update({
        stripeAccountStatus: {
          chargesEnabled: account.charges_enabled,
          payoutsEnabled: account.payouts_enabled,
          detailsSubmitted: account.details_submitted,
          requirementsCurrentlyDue: account.requirements?.currently_due || [],
          requirementsEventuallyDue: account.requirements?.eventually_due || [],
          requirementsPastDue: account.requirements?.past_due || [],
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Send notification if account is fully activated
      if (account.charges_enabled && account.payouts_enabled) {
        await sendHostActivationNotification(hostDoc.id);
      }
    }

    console.log(`Account updated: ${accountId}`);
  } catch (error) {
    console.error('Error handling account update:', error);
    throw error;
  }
};

// Handle transfer created
const handleTransferCreated = async (transfer: Stripe.Transfer) => {
  try {
    const db = admin.firestore();
    
    // Log transfer for tracking
    await db.collection('transfers').doc(transfer.id).set({
      transferId: transfer.id,
      amount: transfer.amount / 100,
      currency: transfer.currency,
      destination: transfer.destination,
      sourceTransaction: transfer.source_transaction,
      metadata: transfer.metadata,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Transfer created: ${transfer.id}`);
  } catch (error) {
    console.error('Error handling transfer created:', error);
    throw error;
  }
};

// Handle payout paid
const handlePayoutPaid = async (payout: Stripe.Payout) => {
  try {
    const db = admin.firestore();
    
    // Update payout record
    await db.collection('payouts').doc(payout.id).set({
      payoutId: payout.id,
      amount: payout.amount / 100,
      currency: payout.currency,
      status: payout.status,
      arrivalDate: new Date(payout.arrival_date * 1000),
      method: payout.method,
      destination: payout.destination,
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Find host and send notification
    const hostsSnapshot = await db
      .collection('users')
      .where('stripeAccountId', '==', payout.destination)
      .limit(1)
      .get();

    if (!hostsSnapshot.empty) {
      const hostDoc = hostsSnapshot.docs[0];
      await sendPayoutNotification(hostDoc.id, payout);
    }

    console.log(`Payout paid: ${payout.id}`);
  } catch (error) {
    console.error('Error handling payout paid:', error);
    throw error;
  }
};

// Handle payout failed
const handlePayoutFailed = async (payout: Stripe.Payout) => {
  try {
    const db = admin.firestore();
    
    // Update payout record
    await db.collection('payouts').doc(payout.id).set({
      payoutId: payout.id,
      amount: payout.amount / 100,
      currency: payout.currency,
      status: payout.status,
      failureCode: payout.failure_code,
      failureMessage: payout.failure_message,
      failedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Find host and send notification
    const hostsSnapshot = await db
      .collection('users')
      .where('stripeAccountId', '==', payout.destination)
      .limit(1)
      .get();

    if (!hostsSnapshot.empty) {
      const hostDoc = hostsSnapshot.docs[0];
      await sendPayoutFailureNotification(hostDoc.id, payout);
    }

    console.log(`Payout failed: ${payout.id}`);
  } catch (error) {
    console.error('Error handling payout failed:', error);
    throw error;
  }
};

// Helper functions
const sendBookingConfirmationNotifications = async (booking: any, paymentIntent: Stripe.PaymentIntent) => {
  // Implementation for sending booking confirmation notifications
  console.log('Sending booking confirmation notifications...');
};

const updateListingAvailability = async (booking: any) => {
  // Implementation for updating listing availability
  console.log('Updating listing availability...');
};

const sendPaymentFailureNotifications = async (booking: any, paymentIntent: Stripe.PaymentIntent) => {
  // Implementation for sending payment failure notifications
  console.log('Sending payment failure notifications...');
};

const sendHostActivationNotification = async (hostId: string) => {
  // Implementation for sending host activation notification
  console.log('Sending host activation notification...');
};

const sendPayoutNotification = async (hostId: string, payout: Stripe.Payout) => {
  // Implementation for sending payout notification
  console.log('Sending payout notification...');
};

const sendPayoutFailureNotification = async (hostId: string, payout: Stripe.Payout) => {
  // Implementation for sending payout failure notification
  console.log('Sending payout failure notification...');
};

export const webhookFunctions = {
  stripeWebhook,
  handlePaymentSucceeded,
  handlePaymentFailed,
  handleAccountUpdated,
};