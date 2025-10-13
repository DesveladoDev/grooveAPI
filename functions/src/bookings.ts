import * as functions from 'firebase-functions';
import { admin } from './index';

interface BookingRequest {
  listingId: string;
  userId: string;
  startDate: string;
  endDate: string;
  startTime: string;
  endTime: string;
  guests: number;
  totalAmount: number;
  specialRequests?: string;
}

interface AvailabilityCheck {
  listingId: string;
  date: string;
  startTime: string;
  endTime: string;
}

// Create booking
export const createBooking = functions.https.onCall(
  async (data: BookingRequest, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const {
        listingId,
        userId,
        startDate,
        endDate,
        startTime,
        endTime,
        guests,
        totalAmount,
        specialRequests,
      } = data;

      const db = admin.firestore();

      // Validate listing exists
      const listingDoc = await db.collection('listings').doc(listingId).get();
      if (!listingDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Listing not found');
      }

      const listing = listingDoc.data();
      
      // Check availability
      const isAvailable = await checkTimeSlotAvailability({
        listingId,
        date: startDate,
        startTime,
        endTime,
      });

      if (!isAvailable) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Time slot is not available'
        );
      }

      // Validate guest count
      if (guests > listing?.maxGuests) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          `Maximum ${listing.maxGuests} guests allowed`
        );
      }

      // Create booking
      const bookingRef = db.collection('bookings').doc();
      const bookingData = {
        id: bookingRef.id,
        listingId,
        userId,
        hostId: listing?.hostId,
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        startTime,
        endTime,
        guests,
        totalAmount,
        specialRequests: specialRequests || '',
        status: 'pending',
        paymentStatus: 'pending',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await bookingRef.set(bookingData);

      // Update listing stats
      await db.collection('listings').doc(listingId).update({
        'stats.totalBookings': admin.firestore.FieldValue.increment(1),
        'stats.pendingBookings': admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        bookingId: bookingRef.id,
        booking: bookingData,
      };
    } catch (error) {
      console.error('Error creating booking:', error);
      throw new functions.https.HttpsError('internal', 'Failed to create booking');
    }
  }
);

// Update booking status
export const updateBookingStatus = functions.https.onCall(
  async (data: { bookingId: string; status: string; reason?: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { bookingId, status, reason } = data;
      const db = admin.firestore();

      // Get booking
      const bookingDoc = await db.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Booking not found');
      }

      const booking = bookingDoc.data();
      const currentStatus = booking?.status;

      // Validate status transition
      const validTransitions: Record<string, string[]> = {
        pending: ['confirmed', 'cancelled'],
        confirmed: ['completed', 'cancelled'],
        completed: [],
        cancelled: [],
      };

      if (!validTransitions[currentStatus]?.includes(status)) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          `Cannot change status from ${currentStatus} to ${status}`
        );
      }

      // Update booking
      const updateData: any = {
        status,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (reason) {
        updateData.statusReason = reason;
      }

      if (status === 'confirmed') {
        updateData.confirmedAt = admin.firestore.FieldValue.serverTimestamp();
      } else if (status === 'completed') {
        updateData.completedAt = admin.firestore.FieldValue.serverTimestamp();
      } else if (status === 'cancelled') {
        updateData.cancelledAt = admin.firestore.FieldValue.serverTimestamp();
      }

      await bookingDoc.ref.update(updateData);

      // Update listing stats
      const listingUpdates: any = {};
      
      if (currentStatus === 'pending') {
        listingUpdates['stats.pendingBookings'] = admin.firestore.FieldValue.increment(-1);
      }
      
      if (status === 'confirmed') {
        listingUpdates['stats.confirmedBookings'] = admin.firestore.FieldValue.increment(1);
      } else if (status === 'completed') {
        listingUpdates['stats.completedBookings'] = admin.firestore.FieldValue.increment(1);
        listingUpdates['stats.totalRevenue'] = admin.firestore.FieldValue.increment(booking?.totalAmount || 0);
      } else if (status === 'cancelled') {
        listingUpdates['stats.cancelledBookings'] = admin.firestore.FieldValue.increment(1);
      }

      if (Object.keys(listingUpdates).length > 0) {
        await db.collection('listings').doc(booking?.listingId).update(listingUpdates);
      }

      return {
        success: true,
        status,
        updatedAt: new Date(),
      };
    } catch (error) {
      console.error('Error updating booking status:', error);
      throw new functions.https.HttpsError('internal', 'Failed to update booking status');
    }
  }
);

// Cancel booking
export const cancelBooking = functions.https.onCall(
  async (data: { bookingId: string; reason: string; refundAmount?: number }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { bookingId, reason, refundAmount } = data;
      const db = admin.firestore();

      // Get booking
      const bookingDoc = await db.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Booking not found');
      }

      const booking = bookingDoc.data();
      
      // Check if booking can be cancelled
      if (booking?.status === 'completed' || booking?.status === 'cancelled') {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Booking cannot be cancelled'
        );
      }

      // Calculate refund amount based on cancellation policy
      const calculatedRefundAmount = refundAmount || calculateRefundAmount(booking);

      // Update booking
      await bookingDoc.ref.update({
        status: 'cancelled',
        cancelReason: reason,
        refundAmount: calculatedRefundAmount,
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Process refund if applicable
      if (calculatedRefundAmount > 0 && booking?.paymentIntentId) {
        // This would trigger the refund process
        // Implementation depends on payment processing setup
      }

      return {
        success: true,
        refundAmount: calculatedRefundAmount,
        cancelledAt: new Date(),
      };
    } catch (error) {
      console.error('Error cancelling booking:', error);
      throw new functions.https.HttpsError('internal', 'Failed to cancel booking');
    }
  }
);

// Check availability
export const checkAvailability = functions.https.onCall(
  async (data: AvailabilityCheck, context) => {
    try {
      const { listingId, date, startTime, endTime } = data;
      
      const isAvailable = await checkTimeSlotAvailability({
        listingId,
        date,
        startTime,
        endTime,
      });

      return {
        success: true,
        available: isAvailable,
        date,
        startTime,
        endTime,
      };
    } catch (error) {
      console.error('Error checking availability:', error);
      throw new functions.https.HttpsError('internal', 'Failed to check availability');
    }
  }
);

// Process booking payment
export const processBookingPayment = functions.https.onCall(
  async (data: { bookingId: string; paymentIntentId: string }, context) => {
    try {
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { bookingId, paymentIntentId } = data;
      const db = admin.firestore();

      // Update booking with payment info
      await db.collection('bookings').doc(bookingId).update({
        paymentIntentId,
        paymentStatus: 'processing',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        paymentIntentId,
      };
    } catch (error) {
      console.error('Error processing booking payment:', error);
      throw new functions.https.HttpsError('internal', 'Failed to process payment');
    }
  }
);

// Helper functions
const checkTimeSlotAvailability = async (data: AvailabilityCheck): Promise<boolean> => {
  try {
    const { listingId, date, startTime, endTime } = data;
    const db = admin.firestore();

    const targetDate = new Date(date);
    const dayStart = new Date(targetDate);
    dayStart.setHours(0, 0, 0, 0);
    const dayEnd = new Date(targetDate);
    dayEnd.setHours(23, 59, 59, 999);

    // Check for overlapping bookings
    const overlappingBookings = await db
      .collection('bookings')
      .where('listingId', '==', listingId)
      .where('startDate', '>=', dayStart)
      .where('startDate', '<=', dayEnd)
      .where('status', 'in', ['confirmed', 'pending'])
      .get();

    for (const doc of overlappingBookings.docs) {
      const booking = doc.data();
      
      // Check time overlap
      if (timesOverlap(startTime, endTime, booking.startTime, booking.endTime)) {
        return false;
      }
    }

    return true;
  } catch (error) {
    console.error('Error checking availability:', error);
    return false;
  }
};

const timesOverlap = (start1: string, end1: string, start2: string, end2: string): boolean => {
  const parseTime = (time: string): number => {
    const [hours, minutes] = time.split(':').map(Number);
    return hours * 60 + minutes;
  };

  const start1Minutes = parseTime(start1);
  const end1Minutes = parseTime(end1);
  const start2Minutes = parseTime(start2);
  const end2Minutes = parseTime(end2);

  return start1Minutes < end2Minutes && end1Minutes > start2Minutes;
};

const calculateRefundAmount = (booking: any): number => {
  const now = new Date();
  const bookingDate = booking.startDate.toDate();
  const hoursUntilBooking = (bookingDate.getTime() - now.getTime()) / (1000 * 60 * 60);

  // Cancellation policy: 
  // - More than 24 hours: 100% refund
  // - 12-24 hours: 50% refund
  // - Less than 12 hours: No refund
  if (hoursUntilBooking > 24) {
    return booking.totalAmount;
  } else if (hoursUntilBooking > 12) {
    return booking.totalAmount * 0.5;
  } else {
    return 0;
  }
};

export const bookingFunctions = {
  createBooking,
  updateBookingStatus,
  cancelBooking,
  checkAvailability,
  processBookingPayment,
};