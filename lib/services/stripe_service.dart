import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StripeService {
  factory StripeService() => _instance;
  StripeService._internal();
  static final StripeService _instance = StripeService._internal();
  
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stripe Connect - Onboarding de anfitriones
  Future<StripeConnectResult> createConnectAccount({
    required String email,
    required String businessType,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      // Validaciones de entrada
      if (email.trim().isEmpty) {
        throw ArgumentError('El email es obligatorio');
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
        throw ArgumentError('Formato de email inválido');
      }
      if (businessType.trim().isEmpty) {
        throw ArgumentError('El tipo de negocio es obligatorio');
      }
      if (!['individual', 'company'].contains(businessType.toLowerCase())) {
        throw ArgumentError('Tipo de negocio inválido. Debe ser "individual" o "company"');
      }
      
      final user = _auth.currentUser;
      if (user == null) {
        throw StateError('Usuario no autenticado');
      }
      
      final callable = _functions.httpsCallable('createStripeConnectAccount');
      final result = await callable.call({
        'email': email.trim().toLowerCase(),
        'businessType': businessType.toLowerCase(),
        'userId': user.uid,
        'additionalInfo': additionalInfo ?? {},
      });
      
      final data = result.data as Map<String, dynamic>?;
      if (data == null) {
        throw StateError('Respuesta inválida del servidor');
      }
      
      return StripeConnectResult(
        accountId: data['accountId'] as String,
        onboardingUrl: data['onboardingUrl'] as String?,
        success: data['success'] as bool? ?? false,
        message: data['message'] as String?,
      );
      
    } on ArgumentError catch (e) {
      throw ArgumentError('Datos inválidos: ${e.message}');
    } on StateError catch (e) {
      throw StateError('Estado inválido: ${e.message}');
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Error de Stripe Connect: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear cuenta de Stripe Connect: ${e.toString()}');
    }
  }
  
  Future<ConnectAccountStatus> getConnectAccountStatus(String accountId) async {
    try {
      // Validaciones de entrada
      if (accountId.trim().isEmpty) {
        throw ArgumentError('El ID de cuenta es obligatorio');
      }
      if (!accountId.startsWith('acct_')) {
        throw ArgumentError('Formato de ID de cuenta Stripe inválido');
      }
      
      final callable = _functions.httpsCallable('getConnectAccountStatus');
      final result = await callable.call({
        'accountId': accountId.trim(),
      });
      
      final data = result.data as Map<String, dynamic>?;
      if (data == null) {
        throw StateError('Respuesta inválida del servidor');
      }
      
      return ConnectAccountStatus(
        accountId: accountId,
        isActive: data['isActive'] as bool? ?? false,
        requiresOnboarding: data['requiresOnboarding'] as bool? ?? true,
        canReceivePayments: data['canReceivePayments'] as bool? ?? false,
        requirements: List<String>.from(data['requirements'] as Iterable? ?? []),
        onboardingUrl: data['onboardingUrl'] as String?,
      );
      
    } on ArgumentError catch (e) {
      throw ArgumentError('Datos inválidos: ${e.message}');
    } on StateError catch (e) {
      throw StateError('Estado inválido: ${e.message}');
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Error de Stripe: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al obtener estado de cuenta: ${e.toString()}');
    }
  }
  
  Future<String> createOnboardingLink(String accountId) async {
    try {
      final callable = _functions.httpsCallable('createOnboardingLink');
      final result = await callable.call({
        'accountId': accountId,
      });
      
      final data = result.data as Map<String, dynamic>;
      return data['url'] as String;
      
    } catch (e) {
      throw Exception('Error al crear enlace de onboarding: $e');
    }
  }
  
  // Pagos y reservas
  Future<PaymentIntentResult> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
    required String hostAccountId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validaciones de entrada
      if (bookingId.trim().isEmpty) {
        throw ArgumentError('El ID de reserva es obligatorio');
      }
      if (amount <= 0) {
        throw ArgumentError('El monto debe ser mayor a 0');
      }
      if (amount > 999999.99) {
        throw ArgumentError('El monto excede el límite máximo permitido');
      }
      if (currency.trim().isEmpty) {
        throw ArgumentError('La moneda es obligatoria');
      }
      if (!['usd', 'eur', 'mxn'].contains(currency.toLowerCase())) {
        throw ArgumentError('Moneda no soportada: $currency');
      }
      if (hostAccountId.trim().isEmpty) {
        throw ArgumentError('El ID de cuenta del anfitrión es obligatorio');
      }
      if (!hostAccountId.startsWith('acct_')) {
        throw ArgumentError('Formato de ID de cuenta Stripe inválido');
      }
      
      final user = _auth.currentUser;
      if (user == null) {
        throw StateError('Usuario no autenticado');
      }
      
      final callable = _functions.httpsCallable('createPaymentIntent');
      final result = await callable.call({
        'bookingId': bookingId.trim(),
        'amount': (amount * 100).round(), // Convertir a centavos
        'currency': currency.toLowerCase(),
        'hostAccountId': hostAccountId,
        'customerId': user.uid,
        'metadata': metadata ?? {},
      });
      
      final data = result.data as Map<String, dynamic>;
      
      return PaymentIntentResult(
        paymentIntentId: data['paymentIntentId'] as String,
        clientSecret: data['clientSecret'] as String,
        amount: (data['amount'] as double) / 100, // Convertir de centavos
        currency: data['currency'] as String,
        status: data['status'] as String,
      );
      
    } catch (e) {
      throw Exception('Error al crear intención de pago: $e');
    }
  }
  
  Future<bool> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final callable = _functions.httpsCallable('confirmPayment');
      final result = await callable.call({
        'paymentIntentId': paymentIntentId,
        'paymentMethodId': paymentMethodId,
      });
      
      final data = result.data as Map<String, dynamic>;
      return data['success'] as bool? ?? false;
      
    } catch (e) {
      throw Exception('Error al confirmar pago: $e');
    }
  }
  
  Future<RefundResult> refundPayment({
    required String paymentIntentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final callable = _functions.httpsCallable('refundPayment');
      final result = await callable.call({
        'paymentIntentId': paymentIntentId,
        'amount': amount != null ? (amount * 100).round() : null,
        'reason': reason,
      });
      
      final data = result.data as Map<String, dynamic>;
      
      return RefundResult(
        refundId: data['refundId'] as String,
        amount: (data['amount'] as double) / 100,
        status: data['status'] as String,
        reason: data['reason'] as String?,
      );
      
    } catch (e) {
      throw Exception('Error al procesar reembolso: $e');
    }
  }
  
  // Métodos de pago del cliente
  Future<List<PaymentMethod>> getCustomerPaymentMethods() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      
      final callable = _functions.httpsCallable('getCustomerPaymentMethods');
      final result = await callable.call({
        'customerId': user.uid,
      });
      
      final data = result.data as Map<String, dynamic>;
      final methods = data['paymentMethods'] as List;
      
      return methods.map((method) => PaymentMethod.fromMap(method as Map<String, dynamic>)).toList();
      
    } catch (e) {
      throw Exception('Error al obtener métodos de pago: $e');
    }
  }
  
  Future<PaymentMethod> attachPaymentMethod({
    required String paymentMethodId,
    bool setAsDefault = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      
      final callable = _functions.httpsCallable('attachPaymentMethod');
      final result = await callable.call({
        'paymentMethodId': paymentMethodId,
        'customerId': user.uid,
        'setAsDefault': setAsDefault,
      });
      
      final data = result.data as Map<String, dynamic>;
      return PaymentMethod.fromMap(data['paymentMethod'] as Map<String, dynamic>);
      
    } catch (e) {
      throw Exception('Error al agregar método de pago: $e');
    }
  }
  
  Future<bool> detachPaymentMethod(String paymentMethodId) async {
    try {
      final callable = _functions.httpsCallable('detachPaymentMethod');
      final result = await callable.call({
        'paymentMethodId': paymentMethodId,
      });
      
      final data = result.data as Map<String, dynamic>;
      return data['success'] as bool? ?? false;
      
    } catch (e) {
      throw Exception('Error al eliminar método de pago: $e');
    }
  }
  
  // Reportes y analytics para anfitriones
  Future<HostEarnings> getHostEarnings({
    required String hostId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final callable = _functions.httpsCallable('getHostEarnings');
      final result = await callable.call({
        'hostId': hostId,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      });
      
      final data = result.data as Map<String, dynamic>;
      
      return HostEarnings(
        totalEarnings: (data['totalEarnings'] as double?)?.toDouble() ?? 0.0,
        pendingEarnings: (data['pendingEarnings'] as double?)?.toDouble() ?? 0.0,
        availableEarnings: (data['availableEarnings'] as double?)?.toDouble() ?? 0.0,
        totalBookings: data['totalBookings'] as int? ?? 0,
        platformFees: (data['platformFees'] as double?)?.toDouble() ?? 0.0,
        payouts: (data['payouts'] as List? ?? [])
            .map((payout) => Payout.fromMap(payout as Map<String, dynamic>))
            .toList(),
      );
      
    } catch (e) {
      throw Exception('Error al obtener ganancias: $e');
    }
  }
  
  Future<bool> requestPayout({
    required String hostAccountId,
    required double amount,
  }) async {
    try {
      final callable = _functions.httpsCallable('requestPayout');
      final result = await callable.call({
        'hostAccountId': hostAccountId,
        'amount': (amount * 100).round(),
      });
      
      final data = result.data as Map<String, dynamic>;
      return (data['success'] as bool?) ?? false;
      
    } catch (e) {
      throw Exception('Error al solicitar pago: $e');
    }
  }
  
  // Webhooks y eventos
  Future<void> handleWebhookEvent(Map<String, dynamic> event) async {
    try {
      final callable = _functions.httpsCallable('handleStripeWebhook');
      await callable.call({
        'event': event,
      });
      
    } catch (e) {
      throw Exception('Error al procesar webhook: $e');
    }
  }
  
  // Utilidades
  String formatAmount(double amount, String currency) {
    switch (currency.toLowerCase()) {
      case 'usd':
        return '\$${amount.toStringAsFixed(2)}';
      case 'eur':
        return '€${amount.toStringAsFixed(2)}';
      case 'mxn':
        return '\$${amount.toStringAsFixed(2)} MXN';
      default:
        return '${amount.toStringAsFixed(2)} ${currency.toUpperCase()}';
    }
  }
  
  double calculatePlatformFee(double amount, {double feePercentage = 0.05}) => amount * feePercentage;
  
  double calculateHostEarnings(double amount, {double feePercentage = 0.05}) => amount - calculatePlatformFee(amount, feePercentage: feePercentage);
}

// Modelos de datos
class StripeConnectResult {
  
  StripeConnectResult({
    required this.accountId,
    required this.success, this.onboardingUrl,
    this.message,
  });
  final String accountId;
  final String? onboardingUrl;
  final bool success;
  final String? message;
}

class ConnectAccountStatus {
  
  ConnectAccountStatus({
    required this.accountId,
    required this.isActive,
    required this.requiresOnboarding,
    required this.canReceivePayments,
    required this.requirements,
    this.onboardingUrl,
  });
  final String accountId;
  final bool isActive;
  final bool requiresOnboarding;
  final bool canReceivePayments;
  final List<String> requirements;
  final String? onboardingUrl;
}

class PaymentIntentResult {
  
  PaymentIntentResult({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
  });
  final String paymentIntentId;
  final String clientSecret;
  final double amount;
  final String currency;
  final String status;
}

class RefundResult {
  
  RefundResult({
    required this.refundId,
    required this.amount,
    required this.status,
    this.reason,
  });
  final String refundId;
  final double amount;
  final String status;
  final String? reason;
}

class PaymentMethod {
  
  PaymentMethod({
    required this.id,
    required this.type,
    this.cardBrand,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
  });
  
  factory PaymentMethod.fromMap(Map<String, dynamic> map) => PaymentMethod(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      cardBrand: map['card']?['brand'] as String?,
      last4: map['card']?['last4'] as String?,
      expiryMonth: map['card']?['exp_month'] as int?,
      expiryYear: map['card']?['exp_year'] as int?,
      isDefault: (map['isDefault'] as bool?) ?? false,
    );
  final String id;
  final String type;
  final String? cardBrand;
  final String? last4;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;
}

class HostEarnings {
  
  HostEarnings({
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.availableEarnings,
    required this.totalBookings,
    required this.platformFees,
    required this.payouts,
  });
  final double totalEarnings;
  final double pendingEarnings;
  final double availableEarnings;
  final int totalBookings;
  final double platformFees;
  final List<Payout> payouts;
}

class Payout {
  
  Payout({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.arrivalDate,
  });
  
  factory Payout.fromMap(Map<String, dynamic> map) => Payout(
      id: (map['id'] as String?) ?? '',
      amount: (map['amount'] as double?) ?? 0.0,
      currency: (map['currency'] as String?) ?? '',
      status: (map['status'] as String?) ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created'] as int?) ?? 0 * 1000),
      arrivalDate: map['arrival_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((map['arrival_date'] as int?) ?? 0 * 1000)
          : null,
    );
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime? arrivalDate;
}

// Enums
enum PaymentStatus {
  pending,
  processing,
  succeeded,
  failed,
  canceled,
}

enum RefundStatus {
  pending,
  succeeded,
  failed,
  canceled,
}

enum PayoutStatus {
  pending,
  inTransit,
  paid,
  failed,
  canceled,
}