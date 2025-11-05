import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/utils/exceptions.dart';
import 'package:salas_beats/utils/formatters.dart';

enum PaymentStatus {
  pending,
  processing,
  succeeded,
  failed,
  canceled,
  refunded,
  partiallyRefunded,
}

enum PaymentMethod {
  card,
  applePay,
  googlePay,
  bankTransfer,
  wallet,
}

enum RefundReason {
  requestedByCustomer,
  duplicate,
  fraudulent,
  other,
}

class PaymentIntent {
  
  const PaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
    required this.created, this.description,
    this.metadata,
    this.confirmedAt,
    this.paymentMethodId,
    this.receiptUrl,
    this.failureReason,
  });
  
  factory PaymentIntent.fromJson(Map<String, dynamic> json) => PaymentIntent(
      id: json['id'] as String? ?? '',
      clientSecret: json['client_secret'] as String? ?? '',
      amount: (json['amount'] as int?) ?? 0,
      currency: json['currency'] as String? ?? 'usd',
      status: _parsePaymentStatus(json['status'] as String?),
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      created: DateTime.fromMillisecondsSinceEpoch(((json['created'] as int?) ?? 0) * 1000),
      confirmedAt: json['confirmed_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((json['confirmed_at'] as int) * 1000)
          : null,
      paymentMethodId: json['payment_method'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      failureReason: json['last_payment_error']?['message'] as String?,
    );
  final String id;
  final String clientSecret;
  final int amount;
  final String currency;
  final PaymentStatus status;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime created;
  final DateTime? confirmedAt;
  final String? paymentMethodId;
  final String? receiptUrl;
  final String? failureReason;
  
  Map<String, dynamic> toJson() => {
      'id': id,
      'client_secret': clientSecret,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'description': description,
      'metadata': metadata,
      'created': created.millisecondsSinceEpoch ~/ 1000,
      'confirmed_at': confirmedAt?.millisecondsSinceEpoch != null ? confirmedAt!.millisecondsSinceEpoch ~/ 1000 : null,
      'payment_method': paymentMethodId,
      'receipt_url': receiptUrl,
      'failure_reason': failureReason,
    };
  
  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'requires_payment_method':
      case 'requires_confirmation':
      case 'requires_action':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'succeeded':
        return PaymentStatus.succeeded;
      case 'requires_capture':
        return PaymentStatus.succeeded;
      case 'canceled':
        return PaymentStatus.canceled;
      default:
        return PaymentStatus.failed;
    }
  }
  
  bool get isSuccessful => status == PaymentStatus.succeeded;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCanceled => status == PaymentStatus.canceled;
  
  double get amountInDollars => amount / 100.0;
}

class PaymentMethodData {
  
  const PaymentMethodData({
    required this.id,
    required this.type,
    required this.created, this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.fingerprint,
    this.country,
    this.isDefault = false,
    this.billingDetails,
  });
  
  factory PaymentMethodData.fromJson(Map<String, dynamic> json) {
    final card = json['card'] as Map<String, dynamic>?;
    
    return PaymentMethodData(
      id: json['id'] as String? ?? '',
      type: _parsePaymentMethod(json['type'] as String?),
      last4: card?['last4'] as String?,
      brand: card?['brand'] as String?,
      expiryMonth: card?['exp_month']?.toString(),
      expiryYear: card?['exp_year']?.toString(),
      fingerprint: card?['fingerprint'] as String?,
      country: card?['country'] as String?,
      created: DateTime.fromMillisecondsSinceEpoch(((json['created'] as int?) ?? 0) * 1000),
      billingDetails: json['billing_details'] as Map<String, dynamic>?,
    );
  }
  final String id;
  final PaymentMethod type;
  final String? last4;
  final String? brand;
  final String? expiryMonth;
  final String? expiryYear;
  final String? fingerprint;
  final String? country;
  final bool isDefault;
  final DateTime created;
  final Map<String, dynamic>? billingDetails;
  
  Map<String, dynamic> toJson() => {
      'id': id,
      'type': type.name,
      'last4': last4,
      'brand': brand,
      'exp_month': expiryMonth,
      'exp_year': expiryYear,
      'fingerprint': fingerprint,
      'country': country,
      'is_default': isDefault,
      'created': created.millisecondsSinceEpoch ~/ 1000,
      'billing_details': billingDetails,
    };
  
  static PaymentMethod _parsePaymentMethod(String? type) {
    switch (type?.toLowerCase()) {
      case 'card':
        return PaymentMethod.card;
      case 'apple_pay':
        return PaymentMethod.applePay;
      case 'google_pay':
        return PaymentMethod.googlePay;
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return PaymentMethod.card;
    }
  }
  
  String get displayName {
    switch (type) {
      case PaymentMethod.card:
        return '${brand?.toUpperCase() ?? 'Card'} •••• $last4';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }
  
  String get iconAsset {
    switch (type) {
      case PaymentMethod.card:
        switch (brand?.toLowerCase()) {
          case 'visa':
            return 'assets/icons/visa.svg';
          case 'mastercard':
            return 'assets/icons/mastercard.svg';
          case 'amex':
            return 'assets/icons/amex.svg';
          default:
            return 'assets/icons/credit_card.svg';
        }
      case PaymentMethod.applePay:
        return 'assets/icons/apple_pay.svg';
      case PaymentMethod.googlePay:
        return 'assets/icons/google_pay.svg';
      case PaymentMethod.bankTransfer:
        return 'assets/icons/bank.svg';
      case PaymentMethod.wallet:
        return 'assets/icons/wallet.svg';
    }
  }
}

class RefundData {
  
  const RefundData({
    required this.id,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
    required this.reason,
    required this.status, required this.created, this.description,
    this.receiptNumber,
    this.metadata,
  });
  
  factory RefundData.fromJson(Map<String, dynamic> json) => RefundData(
      id: json['id'] as String? ?? '',
      paymentIntentId: json['payment_intent'] as String? ?? '',
      amount: (json['amount'] as int?) ?? 0,
      currency: json['currency'] as String? ?? 'usd',
      reason: _parseRefundReason(json['reason'] as String?),
      description: json['description'] as String?,
      status: PaymentIntent._parsePaymentStatus(json['status'] as String?),
      created: DateTime.fromMillisecondsSinceEpoch(((json['created'] as int?) ?? 0) * 1000),
      receiptNumber: json['receipt_number'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  final String id;
  final String paymentIntentId;
  final int amount;
  final String currency;
  final RefundReason reason;
  final String? description;
  final PaymentStatus status;
  final DateTime created;
  final String? receiptNumber;
  final Map<String, dynamic>? metadata;
  
  Map<String, dynamic> toJson() => {
      'id': id,
      'payment_intent': paymentIntentId,
      'amount': amount,
      'currency': currency,
      'reason': reason.name,
      'description': description,
      'status': status.name,
      'created': created.millisecondsSinceEpoch ~/ 1000,
      'receipt_number': receiptNumber,
      'metadata': metadata,
    };
  
  static RefundReason _parseRefundReason(String? reason) {
    switch (reason?.toLowerCase()) {
      case 'requested_by_customer':
        return RefundReason.requestedByCustomer;
      case 'duplicate':
        return RefundReason.duplicate;
      case 'fraudulent':
        return RefundReason.fraudulent;
      default:
        return RefundReason.other;
    }
  }
  
  double get amountInDollars => amount / 100.0;
}

class PaymentConfiguration {
  
  const PaymentConfiguration({
    required this.publishableKey,
    required this.merchantId,
    this.merchantDisplayName,
    this.countryCode,
    this.testMode = false,
    this.applePay,
    this.googlePay,
  });
  final String publishableKey;
  final String merchantId;
  final String? merchantDisplayName;
  final String? countryCode;
  final bool testMode;
  final Map<String, dynamic>? applePay;
  final Map<String, dynamic>? googlePay;
}

class PaymentManager {
  
  PaymentManager._();
  static PaymentManager? _instance;
  static PaymentManager get instance => _instance ??= PaymentManager._();
  
  bool _isInitialized = false;
  PaymentConfiguration? _configuration;
  
  // Getters
  bool get isInitialized => _isInitialized;
  PaymentConfiguration? get configuration => _configuration;
  
  // Initialize payment manager
  Future<void> initialize(PaymentConfiguration config) async {
    try {
      _configuration = config;
      
      // Initialize Stripe
      Stripe.publishableKey = config.publishableKey;
      Stripe.merchantIdentifier = config.merchantId;
      
      if (config.testMode) {
        Stripe.stripeAccountId = null; // Use test mode
      }
      
      // Configure Apple Pay
      if (Platform.isIOS && config.applePay != null) {
        await Stripe.instance.applySettings();
      }
      
      _isInitialized = true;
      debugPrint('PaymentManager initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize PaymentManager: $e');
      throw PaymentException.paymentFailed('Failed to initialize payments: $e');
    }
  }
  
  // Create payment intent
  Future<PaymentIntent> createPaymentIntent({
    required int amount,
    required String currency,
    String? description,
    Map<String, dynamic>? metadata,
    String? customerId,
    bool captureMethod = true,
  }) async {
    try {
      final response = await _makeApiCall(
        'POST',
        '/payment_intents',
        data: {
          'amount': amount,
          'currency': currency.toLowerCase(),
          'description': description,
          'metadata': metadata,
          'customer': customerId,
          'capture_method': captureMethod ? 'automatic' : 'manual',
          'automatic_payment_methods': {
            'enabled': true,
          },
        },
      );
      
      return PaymentIntent.fromJson(response);
    } catch (e) {
      debugPrint('Failed to create payment intent: $e');
      throw PaymentException.paymentFailed('Failed to create payment intent: $e');
    }
  }
  
  // Confirm payment
  Future<PaymentIntent> confirmPayment({
    required String paymentIntentClientSecret,
    PaymentMethodParams? paymentMethodParams,
    PaymentMethodOptions? options,
  }) async {
    try {
      final result = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
        data: paymentMethodParams,
        options: options,
      );
      
      if (result.status == PaymentIntentsStatus.Succeeded) {
        // Get updated payment intent
        final paymentIntent = await getPaymentIntent(result.id);
        return paymentIntent;
      } else {
        throw PaymentException.paymentFailed(
          'Payment confirmation failed: ${result.status}',
        );
      }
    } catch (e) {
      debugPrint('Failed to confirm payment: $e');
      if (e is StripeException) {
        throw PaymentException.paymentFailed(
          'Payment failed: ${e.error.localizedMessage ?? e.error.message}',
        );
      }
      throw PaymentException.paymentFailed('Payment confirmation failed: $e');
    }
  }
  
  // Get payment intent
  Future<PaymentIntent> getPaymentIntent(String paymentIntentId) async {
    try {
      final response = await _makeApiCall(
        'GET',
        '/payment_intents/$paymentIntentId',
      );
      
      return PaymentIntent.fromJson(response);
    } catch (e) {
      debugPrint('Failed to get payment intent: $e');
      throw PaymentException.paymentFailed('Failed to get payment intent: $e');
    }
  }
  
  // Create setup intent for saving payment method
  Future<String> createSetupIntent({
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _makeApiCall(
        'POST',
        '/setup_intents',
        data: {
          'customer': customerId,
          'metadata': metadata,
          'automatic_payment_methods': {
            'enabled': true,
          },
        },
      );
      
      return response['client_secret'] as String;
    } catch (e) {
      debugPrint('Failed to create setup intent: $e');
      throw PaymentException.paymentFailed('Failed to create setup intent: $e');
    }
  }
  
  // Confirm setup intent
  Future<void> confirmSetupIntent({
    required String setupIntentClientSecret,
    PaymentMethodParams? paymentMethodParams,
  }) async {
    try {
      await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: setupIntentClientSecret,
        params: paymentMethodParams!,
      );
    } catch (e) {
      debugPrint('Failed to confirm setup intent: $e');
      if (e is StripeException) {
        throw PaymentException.paymentFailed(
          'Setup failed: ${e.error.localizedMessage ?? e.error.message}',
        );
      }
      throw PaymentException.paymentFailed('Setup intent confirmation failed: $e');
    }
  }
  
  // Get customer payment methods
  Future<List<PaymentMethodData>> getCustomerPaymentMethods(String customerId) async {
    try {
      final response = await _makeApiCall(
        'GET',
        '/customers/$customerId/payment_methods',
        queryParams: {'type': 'card'},
      );
      
      final data = response['data'] as List<dynamic>? ?? [];
      return data.map((json) => PaymentMethodData.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Failed to get payment methods: $e');
      throw PaymentException.paymentFailed('Failed to get payment methods: $e');
    }
  }
  
  // Detach payment method
  Future<void> detachPaymentMethod(String paymentMethodId) async {
    try {
      await _makeApiCall(
        'POST',
        '/payment_methods/$paymentMethodId/detach',
      );
    } catch (e) {
      debugPrint('Failed to detach payment method: $e');
      throw PaymentException.paymentFailed('Failed to detach payment method: $e');
    }
  }
  
  // Create refund
  Future<RefundData> createRefund({
    required String paymentIntentId,
    int? amount,
    RefundReason reason = RefundReason.requestedByCustomer,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _makeApiCall(
        'POST',
        '/refunds',
        data: {
          'payment_intent': paymentIntentId,
          if (amount != null) 'amount': amount,
          'reason': reason.name,
          'metadata': {
            'description': description,
            ...?metadata,
          },
        },
      );
      
      return RefundData.fromJson(response);
    } catch (e) {
      debugPrint('Failed to create refund: $e');
      throw PaymentException.paymentFailed('Failed to create refund: $e');
    }
  }
  
  // Get refund
  Future<RefundData> getRefund(String refundId) async {
    try {
      final response = await _makeApiCall(
        'GET',
        '/refunds/$refundId',
      );
      
      return RefundData.fromJson(response);
    } catch (e) {
      debugPrint('Failed to get refund: $e');
      throw PaymentException.paymentFailed('Failed to get refund: $e');
    }
  }
  
  // Check if Apple Pay is available
  Future<bool> isApplePaySupported() async {
    try {
      // TODO: Implement Apple Pay support check for flutter_stripe 10.2.0
      return false; // Temporarily return false
    } catch (e) {
      debugPrint('Failed to check Apple Pay support: $e');
      return false;
    }
  }
  
  // Check if Google Pay is available
  Future<bool> isGooglePaySupported() async {
    try {
      return await Stripe.instance.isGooglePaySupported(
        const IsGooglePaySupportedParams(),
      );
    } catch (e) {
      debugPrint('Failed to check Google Pay support: $e');
      return false;
    }
  }
  
  // Present Apple Pay
  Future<PaymentIntent> presentApplePay({
    required int amount,
    required String currency,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create payment intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        description: description,
        metadata: metadata,
      );
      
      // TODO: Implement Apple Pay with correct flutter_stripe methods
      // Present Apple Pay - temporarily commented out
      // await Stripe.instance.presentApplePay(
      //   params: ApplePayPresentParams(
      //     cartItems: [
      //       ApplePayCartSummaryItem.immediate(
      //         label: description ?? 'Payment',
      //         amount: (amount / 100).toStringAsFixed(2),
      //       ),
      //     ],
      //     country: _configuration?.countryCode ?? 'US',
      //     currency: currency.toUpperCase(),
      //   ),
      // );
      
      // Confirm payment - temporarily commented out
      // await Stripe.instance.confirmApplePayPayment(
      //   paymentIntent.clientSecret,
      // );
      
      // Temporary implementation - just return the payment intent
      throw PaymentException.paymentFailed('Apple Pay not yet implemented');
      // return paymentIntent;
      
      return await getPaymentIntent(paymentIntent.id);
    } catch (e) {
      debugPrint('Apple Pay failed: $e');
      if (e is StripeException) {
        throw PaymentException.paymentFailed(
          'Apple Pay failed: ${e.error.localizedMessage ?? e.error.message}',
        );
      }
      throw PaymentException.paymentFailed('Apple Pay failed: $e');
    }
  }
  
  // Present Google Pay
  Future<PaymentIntent> presentGooglePay({
    required int amount,
    required String currency,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create payment intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        description: description,
        metadata: metadata,
      );
      
      // Present Google Pay
      await Stripe.instance.initGooglePay(
        GooglePayInitParams(
          testEnv: _configuration?.testMode ?? false,
          merchantName: _configuration?.merchantDisplayName ?? 'Salas & Beats',
          countryCode: _configuration?.countryCode ?? 'US',
        ),
      );
      
      await Stripe.instance.presentGooglePay(
        PresentGooglePayParams(
          clientSecret: paymentIntent.clientSecret,
        ),
      );
      
      return await getPaymentIntent(paymentIntent.id);
    } catch (e) {
      debugPrint('Google Pay failed: $e');
      if (e is StripeException) {
        throw PaymentException.paymentFailed(
          'Google Pay failed: ${e.error.localizedMessage ?? e.error.message}',
        );
      }
      throw PaymentException.paymentFailed('Google Pay failed: $e');
    }
  }
  
  // Make API call to backend
  Future<Map<String, dynamic>> _makeApiCall(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiUrl}$endpoint');
      final uriWithQuery = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getAuthToken()}',
      };
      
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uriWithQuery, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uriWithQuery,
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uriWithQuery,
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uriWithQuery, headers: headers);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw PaymentException.apiError(
          'API call failed: ${errorData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException.networkError('Network error: $e');
    }
  }
  
  // Get authentication token
  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const AuthException('Debe iniciar sesión para realizar esta operación', code: 'unauthenticated');
    }
    try {
      // Force refresh to ensure token validity when used for backend auth
      final String? token = await user.getIdToken(true);
      if ((token?.isEmpty ?? true)) {
        throw const AuthException('Token de autenticación inválido', code: 'invalid-token');
      }
      return token!;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      throw AuthException('Error obteniendo token de autenticación', originalError: e);
    }
  }
}

// Payment utilities
class PaymentUtils {
  // Format amount for display
  static String formatAmount(int amountCents, String currency) {
    final amount = amountCents / 100;
    return Formatters.formatCurrency(amount);
  }
  
  // Convert amount to cents
  static int amountToCents(double amount) => (amount * 100).round();
  
  // Calculate commission
  static int calculateCommission(int amount, double commissionRate) => (amount * commissionRate).round();
  
  // Calculate host payout
  static int calculateHostPayout(int amount, double commissionRate) {
    final commission = calculateCommission(amount, commissionRate);
    return amount - commission;
  }
  
  // Validate card number
  static bool isValidCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return false;
    }
    
    // Luhn algorithm
    var sum = 0;
    var alternate = false;
    
    for (var i = cleanNumber.length - 1; i >= 0; i--) {
      var digit = int.parse(cleanNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
  
  // Get card brand from number
  static String getCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    
    if (cleanNumber.startsWith('4')) {
      return 'visa';
    } else if (cleanNumber.startsWith(RegExp('^5[1-5]'))) {
      return 'mastercard';
    } else if (cleanNumber.startsWith(RegExp('^3[47]'))) {
      return 'amex';
    } else if (cleanNumber.startsWith('6011') || 
               cleanNumber.startsWith(RegExp('^65'))) {
      return 'discover';
    } else if (cleanNumber.startsWith(RegExp('^30[0-5]')) ||
               cleanNumber.startsWith('36') ||
               cleanNumber.startsWith('38')) {
      return 'diners';
    } else if (cleanNumber.startsWith(RegExp('^35(2[89]|[3-8][0-9])'))) {
      return 'jcb';
    }
    
    return 'unknown';
  }
  
  // Validate expiry date
  static bool isValidExpiryDate(String month, String year) {
    try {
      final monthInt = int.parse(month);
      final yearInt = int.parse(year);
      
      if (monthInt < 1 || monthInt > 12) {
        return false;
      }
      
      final now = DateTime.now();
      final currentYear = now.year % 100; // Get last 2 digits
      final currentMonth = now.month;
      
      if (yearInt < currentYear) {
        return false;
      }
      
      if (yearInt == currentYear && monthInt < currentMonth) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Validate CVV
  static bool isValidCVV(String cvv, String cardBrand) {
    if (cardBrand.toLowerCase() == 'amex') {
      return cvv.length == 4 && RegExp(r'^\d{4}$').hasMatch(cvv);
    } else {
      return cvv.length == 3 && RegExp(r'^\d{3}$').hasMatch(cvv);
    }
  }
  
  // Format card number for display
  static String formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    
    for (var i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanNumber[i]);
    }
    
    return buffer.toString();
  }
  
  // Mask card number
  static String maskCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    
    if (cleanNumber.length < 4) {
      return '*' * cleanNumber.length;
    }
    
    final lastFour = cleanNumber.substring(cleanNumber.length - 4);
    final masked = '*' * (cleanNumber.length - 4);
    
    return formatCardNumber(masked + lastFour);
  }
  
  // Create payment method params for card
  static PaymentMethodParams createCardPaymentMethodParams({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    BillingDetails? billingDetails,
  }) => PaymentMethodParams.card(
      paymentMethodData: stripe.PaymentMethodData(
        billingDetails: billingDetails,
      ),
    );
  
  // Get payment status color
  static Color getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.succeeded:
        return const Color(0xFF4CAF50); // Green
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return const Color(0xFFFF9800); // Orange
      case PaymentStatus.failed:
        return const Color(0xFFF44336); // Red
      case PaymentStatus.canceled:
        return const Color(0xFF9E9E9E); // Grey
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        return const Color(0xFF2196F3); // Blue
    }
  }
  
  // Get payment status text
  static String getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.succeeded:
        return 'Succeeded';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.canceled:
        return 'Canceled';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }
}