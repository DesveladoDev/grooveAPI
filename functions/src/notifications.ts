import * as functions from 'firebase-functions';
import { admin } from './index';
import * as nodemailer from 'nodemailer';

interface NotificationData {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, any>;
  type: 'booking' | 'payment' | 'host' | 'general';
}

interface EmailData {
  to: string;
  subject: string;
  html: string;
  from?: string;
}

// Configure email transporter
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.password,
  },
});

// Send booking confirmation notification
export const sendBookingConfirmation = functions.https.onCall(
  async (data: { bookingId: string; userId: string; hostId: string }) => {
    try {
      const { bookingId, userId, hostId } = data;
      const db = admin.firestore();

      // Get booking details
      const bookingDoc = await db.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Booking not found');
      }

      const booking = bookingDoc.data();
      
      // Get user and host details
      const [userDoc, hostDoc, listingDoc] = await Promise.all([
        db.collection('users').doc(userId).get(),
        db.collection('users').doc(hostId).get(),
        db.collection('listings').doc(booking?.listingId).get(),
      ]);

      const user = userDoc.data();
      const host = hostDoc.data();
      const listing = listingDoc.data();

      // Send push notification to user
      await sendPushNotification({
        userId,
        title: '¡Reserva confirmada!',
        body: `Tu reserva en ${listing?.title} ha sido confirmada`,
        data: {
          type: 'booking_confirmed',
          bookingId,
          listingId: booking?.listingId,
        },
        type: 'booking',
      });

      // Send push notification to host
      await sendPushNotification({
        userId: hostId,
        title: 'Nueva reserva',
        body: `${user?.displayName} ha reservado ${listing?.title}`,
        data: {
          type: 'new_booking',
          bookingId,
          userId,
        },
        type: 'booking',
      });

      // Send confirmation emails
      await Promise.all([
        sendBookingConfirmationEmail(user, host, listing, booking),
        sendNewBookingEmailToHost(user, host, listing, booking),
      ]);

      return { success: true };
    } catch (error) {
      console.error('Error sending booking confirmation:', error);
      throw new functions.https.HttpsError('internal', 'Failed to send notifications');
    }
  }
);

// Send payment notification
export const sendPaymentNotification = functions.https.onCall(
  async (data: { userId: string; amount: number; status: string; bookingId: string }) => {
    try {
      const { userId, amount, status, bookingId } = data;
      
      let title = '';
      let body = '';
      
      switch (status) {
        case 'succeeded':
          title = 'Pago procesado';
          body = `Tu pago de $${amount} ha sido procesado exitosamente`;
          break;
        case 'failed':
          title = 'Error en el pago';
          body = `No pudimos procesar tu pago de $${amount}. Intenta nuevamente`;
          break;
        case 'refunded':
          title = 'Reembolso procesado';
          body = `Tu reembolso de $${amount} ha sido procesado`;
          break;
      }

      await sendPushNotification({
        userId,
        title,
        body,
        data: {
          type: 'payment_update',
          bookingId,
          amount: amount.toString(),
          status,
        },
        type: 'payment',
      });

      return { success: true };
    } catch (error) {
      console.error('Error sending payment notification:', error);
      throw new functions.https.HttpsError('internal', 'Failed to send payment notification');
    }
  }
);

// Send host notification
export const sendHostNotification = functions.https.onCall(
  async (data: { hostId: string; type: string; data: Record<string, any> }) => {
    try {
      const { hostId, type, data: notificationData } = data;
      
      let title = '';
      let body = '';
      
      switch (type) {
        case 'account_activated':
          title = '¡Cuenta activada!';
          body = 'Tu cuenta de anfitrión ha sido activada. Ya puedes recibir pagos';
          break;
        case 'payout_sent':
          title = 'Pago enviado';
          body = `Se ha enviado un pago de $${notificationData.amount} a tu cuenta`;
          break;
        case 'new_review':
          title = 'Nueva reseña';
          body = `Has recibido una nueva reseña de ${notificationData.guestName}`;
          break;
        case 'listing_approved':
          title = 'Listado aprobado';
          body = `Tu listado "${notificationData.listingTitle}" ha sido aprobado`;
          break;
      }

      await sendPushNotification({
        userId: hostId,
        title,
        body,
        data: {
          type,
          ...notificationData,
        },
        type: 'host',
      });

      return { success: true };
    } catch (error) {
      console.error('Error sending host notification:', error);
      throw new functions.https.HttpsError('internal', 'Failed to send host notification');
    }
  }
);

// Send push notification
export const sendPushNotification = async (notificationData: NotificationData) => {
  try {
    const { userId, title, body, data, type } = notificationData;
    const db = admin.firestore();

    // Get user's FCM tokens
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new Error('User not found');
    }

    const user = userDoc.data();
    const fcmTokens = user?.fcmTokens || [];

    if (fcmTokens.length === 0) {
      console.log(`No FCM tokens found for user ${userId}`);
      return;
    }

    // Prepare notification payload
    const payload = {
      notification: {
        title,
        body,
        icon: 'ic_notification',
        sound: 'default',
      },
      data: {
        type,
        userId,
        ...data,
      },
    };

    // Send to all tokens
    const responses = await admin.messaging().sendToDevice(fcmTokens, payload);
    
    // Handle failed tokens
    const failedTokens: string[] = [];
    responses.results.forEach((result, index) => {
      if (result.error) {
        console.error(`Failed to send to token ${fcmTokens[index]}:`, result.error);
        failedTokens.push(fcmTokens[index]);
      }
    });

    // Remove failed tokens
    if (failedTokens.length > 0) {
      const validTokens = fcmTokens.filter(token => !failedTokens.includes(token));
      await db.collection('users').doc(userId).update({
        fcmTokens: validTokens,
      });
    }

    // Save notification to database
    await db.collection('notifications').add({
      userId,
      title,
      body,
      data,
      type,
      read: false,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Push notification sent to user ${userId}`);
  } catch (error) {
    console.error('Error sending push notification:', error);
    throw error;
  }
};

// Helper functions for email templates
const sendBookingConfirmationEmail = async (user: any, host: any, listing: any, booking: any) => {
  const emailData: EmailData = {
    to: user.email,
    subject: 'Confirmación de reserva - Salas & Beats',
    html: `
      <h2>¡Tu reserva ha sido confirmada!</h2>
      <p>Hola ${user.displayName},</p>
      <p>Tu reserva en <strong>${listing.title}</strong> ha sido confirmada.</p>
      <h3>Detalles de la reserva:</h3>
      <ul>
        <li><strong>Fecha:</strong> ${new Date(booking.startDate.toDate()).toLocaleDateString()}</li>
        <li><strong>Hora:</strong> ${booking.startTime} - ${booking.endTime}</li>
        <li><strong>Huéspedes:</strong> ${booking.guests}</li>
        <li><strong>Total:</strong> $${booking.totalAmount}</li>
      </ul>
      <h3>Información del anfitrión:</h3>
      <p><strong>Nombre:</strong> ${host.displayName}</p>
      <p><strong>Teléfono:</strong> ${host.phone}</p>
      <p>¡Esperamos que disfrutes tu experiencia!</p>
      <p>El equipo de Salas & Beats</p>
    `,
  };

  await sendEmail(emailData);
};

const sendNewBookingEmailToHost = async (user: any, host: any, listing: any, booking: any) => {
  const emailData: EmailData = {
    to: host.email,
    subject: 'Nueva reserva recibida - Salas & Beats',
    html: `
      <h2>¡Has recibido una nueva reserva!</h2>
      <p>Hola ${host.displayName},</p>
      <p>Has recibido una nueva reserva para <strong>${listing.title}</strong>.</p>
      <h3>Detalles de la reserva:</h3>
      <ul>
        <li><strong>Cliente:</strong> ${user.displayName}</li>
        <li><strong>Fecha:</strong> ${new Date(booking.startDate.toDate()).toLocaleDateString()}</li>
        <li><strong>Hora:</strong> ${booking.startTime} - ${booking.endTime}</li>
        <li><strong>Huéspedes:</strong> ${booking.guests}</li>
        <li><strong>Total:</strong> $${booking.totalAmount}</li>
      </ul>
      <p>Puedes contactar al cliente en: ${user.email}</p>
      <p>El equipo de Salas & Beats</p>
    `,
  };

  await sendEmail(emailData);
};

const sendEmail = async (emailData: EmailData) => {
  try {
    const mailOptions = {
      from: emailData.from || functions.config().email.from,
      to: emailData.to,
      subject: emailData.subject,
      html: emailData.html,
    };

    await transporter.sendMail(mailOptions);
    console.log(`Email sent to ${emailData.to}`);
  } catch (error) {
    console.error('Error sending email:', error);
    throw error;
  }
};

export const notificationFunctions = {
  sendBookingConfirmation,
  sendPaymentNotification,
  sendHostNotification,
  sendPushNotification,
};