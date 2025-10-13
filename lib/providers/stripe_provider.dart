import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:salas_beats/models/user_model.dart';
import 'package:salas_beats/services/auth_service.dart';
import 'package:salas_beats/services/stripe_service.dart';

class StripeProvider extends ChangeNotifier {
  final StripeService _stripeService = StripeService();
  final AuthService _authService = AuthService();
  
  // Estado de Stripe Connect
  ConnectAccountStatus? _connectAccountStatus;
  bool _isLoadingConnectStatus = false;
  String? _connectAccountId;
  
  // Estado de métodos de pago
  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _defaultPaymentMethod;
  bool _isLoadingPaymentMethods = false;
  
  // Estado de ganancias del anfitrión
  HostEarnings? _hostEarnings;
  bool _isLoadingEarnings = false;
  
  // Estado de pagos
  PaymentIntentResult? _currentPaymentIntent;
  bool _isProcessingPayment = false;
  
  // Getters
  ConnectAccountStatus? get connectAccountStatus => _connectAccountStatus;
  bool get isLoadingConnectStatus => _isLoadingConnectStatus;
  String? get connectAccountId => _connectAccountId;
  bool get isConnectAccountActive => _connectAccountStatus?.isActive ?? false;
  bool get canReceivePayments => _connectAccountStatus?.canReceivePayments ?? false;
  
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  PaymentMethod? get defaultPaymentMethod => _defaultPaymentMethod;
  bool get isLoadingPaymentMethods => _isLoadingPaymentMethods;
  bool get hasPaymentMethods => _paymentMethods.isNotEmpty;
  
  HostEarnings? get hostEarnings => _hostEarnings;
  bool get isLoadingEarnings => _isLoadingEarnings;
  
  PaymentIntentResult? get currentPaymentIntent => _currentPaymentIntent;
  bool get isProcessingPayment => _isProcessingPayment;
  
  // Stripe Connect - Onboarding de anfitriones
  Future<StripeConnectResult> createConnectAccount({
    required String email,
    required String businessType,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final result = await _stripeService.createConnectAccount(
        email: email,
        businessType: businessType,
        additionalInfo: additionalInfo,
      );
      
      if (result.success) {
        _connectAccountId = result.accountId;
        await _updateUserConnectAccount(result.accountId);
        await loadConnectAccountStatus();
      }
      
      return result;
      
    } catch (e) {
      throw Exception('Error al crear cuenta de Stripe Connect: $e');
    }
  }
  
  Future<void> loadConnectAccountStatus() async {
    if (_connectAccountId == null) {
      await _loadConnectAccountId();
    }
    
    if (_connectAccountId == null) return;
    
    _isLoadingConnectStatus = true;
    notifyListeners();
    
    try {
      _connectAccountStatus = await _stripeService.getConnectAccountStatus(_connectAccountId!);
    } catch (e) {
      debugPrint('Error al cargar estado de cuenta Connect: $e');
    } finally {
      _isLoadingConnectStatus = false;
      notifyListeners();
    }
  }
  
  Future<String?> createOnboardingLink() async {
    if (_connectAccountId == null) return null;
    
    try {
      return await _stripeService.createOnboardingLink(_connectAccountId!);
    } catch (e) {
      debugPrint('Error al crear enlace de onboarding: $e');
      return null;
    }
  }
  
  // Métodos de pago
  Future<void> loadPaymentMethods() async {
    _isLoadingPaymentMethods = true;
    notifyListeners();
    
    try {
      _paymentMethods = await _stripeService.getCustomerPaymentMethods();
      if (_paymentMethods.isNotEmpty) {
        _defaultPaymentMethod = _paymentMethods.firstWhere(
          (method) => method.isDefault,
          orElse: () => _paymentMethods.first,
        );
      } else {
        _defaultPaymentMethod = null;
      }
    } catch (e) {
      debugPrint('Error al cargar métodos de pago: $e');
      _paymentMethods = [];
      _defaultPaymentMethod = null;
    } finally {
      _isLoadingPaymentMethods = false;
      notifyListeners();
    }
  }
  
  Future<PaymentMethod> addPaymentMethod({
    required String paymentMethodId,
    bool setAsDefault = false,
  }) async {
    try {
      final paymentMethod = await _stripeService.attachPaymentMethod(
        paymentMethodId: paymentMethodId,
        setAsDefault: setAsDefault,
      );
      
      await loadPaymentMethods();
      return paymentMethod;
      
    } catch (e) {
      throw Exception('Error al agregar método de pago: $e');
    }
  }
  
  Future<bool> removePaymentMethod(String paymentMethodId) async {
    try {
      final success = await _stripeService.detachPaymentMethod(paymentMethodId);
      
      if (success) {
        await loadPaymentMethods();
      }
      
      return success;
      
    } catch (e) {
      debugPrint('Error al eliminar método de pago: $e');
      return false;
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
      _currentPaymentIntent = await _stripeService.createPaymentIntent(
        bookingId: bookingId,
        amount: amount,
        currency: currency,
        hostAccountId: hostAccountId,
        metadata: metadata,
      );
      
      notifyListeners();
      return _currentPaymentIntent!;
      
    } catch (e) {
      throw Exception('Error al crear intención de pago: $e');
    }
  }
  
  Future<bool> processPayment({
    required String paymentMethodId,
  }) async {
    if (_currentPaymentIntent == null) {
      throw Exception('No hay intención de pago activa');
    }
    
    _isProcessingPayment = true;
    notifyListeners();
    
    try {
      final success = await _stripeService.confirmPayment(
        paymentIntentId: _currentPaymentIntent!.paymentIntentId,
        paymentMethodId: paymentMethodId,
      );
      
      if (success) {
        _currentPaymentIntent = null;
      }
      
      return success;
      
    } catch (e) {
      throw Exception('Error al procesar pago: $e');
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }
  
  Future<RefundResult> refundPayment({
    required String paymentIntentId,
    double? amount,
    String? reason,
  }) async {
    try {
      return await _stripeService.refundPayment(
        paymentIntentId: paymentIntentId,
        amount: amount,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Error al procesar reembolso: $e');
    }
  }
  
  // Ganancias del anfitrión
  Future<void> loadHostEarnings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userData = await _authService.getCurrentUserData();
    if (userData == null || userData.role != 'host') return;
    
    _isLoadingEarnings = true;
    notifyListeners();
    
    try {
      _hostEarnings = await _stripeService.getHostEarnings(
        hostId: userData.id,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Error al cargar ganancias: $e');
      _hostEarnings = null;
    } finally {
      _isLoadingEarnings = false;
      notifyListeners();
    }
  }
  
  Future<bool> requestPayout(double amount) async {
    if (_connectAccountId == null) {
      throw Exception('No hay cuenta de Stripe Connect configurada');
    }
    
    try {
      final success = await _stripeService.requestPayout(
        hostAccountId: _connectAccountId!,
        amount: amount,
      );
      
      if (success) {
        await loadHostEarnings();
      }
      
      return success;
      
    } catch (e) {
      throw Exception('Error al solicitar pago: $e');
    }
  }
  
  // Utilidades
  String formatAmount(double amount, String currency) => _stripeService.formatAmount(amount, currency);
  
  double calculatePlatformFee(double amount) => _stripeService.calculatePlatformFee(amount);
  
  double calculateHostEarnings(double amount) => _stripeService.calculateHostEarnings(amount);
  
  // Métodos privados
  Future<void> _loadConnectAccountId() async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData != null) {
        // Buscar información de host en Firestore
        final hostDoc = await FirebaseFirestore.instance
            .collection('hosts')
            .doc(userData.id)
            .get();
        if (hostDoc.exists) {
          final hostData = hostDoc.data();
          _connectAccountId = hostData?['stripeAccountId'] as String?;
        }
      }
    } catch (e) {
      debugPrint('Error al cargar ID de cuenta Connect: $e');
    }
  }
  
  Future<void> _updateUserConnectAccount(String accountId) async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData != null) {
        // Actualizar información de host en Firestore
        await FirebaseFirestore.instance
            .collection('hosts')
            .doc(userData.id)
            .set({
          'userId': userData.id,
          'stripeAccountId': accountId,
          'kycStatus': 'pending',
          'rating': 0.0,
          'reviewCount': 0,
          'stats': {
            'totalBookings': 0,
            'totalEarnings': 0.0,
            'averageRating': 0.0,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        }, SetOptions(merge: true),);
        
        // Actualizar rol de usuario
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userData.id)
            .update({
          'role': 'host',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error al actualizar cuenta de usuario: $e');
    }
  }
  
  // Limpiar estado
  void clearPaymentIntent() {
    _currentPaymentIntent = null;
    notifyListeners();
  }
  
  void clearState() {
    _connectAccountStatus = null;
    _connectAccountId = null;
    _paymentMethods = [];
    _defaultPaymentMethod = null;
    _hostEarnings = null;
    _currentPaymentIntent = null;
    _isLoadingConnectStatus = false;
    _isLoadingPaymentMethods = false;
    _isLoadingEarnings = false;
    _isProcessingPayment = false;
    notifyListeners();
  }
  
  // Inicialización
  Future<void> initialize() async {
    await _loadConnectAccountId();
    await Future.wait([
      loadConnectAccountStatus(),
      loadPaymentMethods(),
    ]);
    
    final userData = await _authService.getCurrentUserData();
    if (userData?.role == UserRole.host) {
      await loadHostEarnings();
    }
  }
}

// Extensiones para facilitar el uso
extension StripeProviderExtensions on StripeProvider {
  bool get needsOnboarding => 
      connectAccountStatus?.requiresOnboarding ?? true;
  
  bool get hasActiveConnectAccount => 
      connectAccountStatus?.isActive ?? false;
  
  List<String> get connectRequirements => 
      connectAccountStatus?.requirements ?? [];
  
  bool get hasConnectRequirements => connectRequirements.isNotEmpty;
  
  double get totalAvailableEarnings => 
      hostEarnings?.availableEarnings ?? 0.0;
  
  double get totalPendingEarnings => 
      hostEarnings?.pendingEarnings ?? 0.0;
  
  int get totalBookingsCount => 
      hostEarnings?.totalBookings ?? 0;
  
  bool get canRequestPayout => 
      hasActiveConnectAccount && totalAvailableEarnings > 0;
}

// Clase para manejar errores específicos de Stripe
class StripeError extends Error {
  
  StripeError({
    required this.message,
    this.code,
    this.type,
  });
  final String message;
  final String? code;
  final String? type;
  
  @override
  String toString() => 'StripeError: $message${code != null ? ' (Code: $code)' : ''}';
}

// Enums para estados
enum ConnectOnboardingStatus {
  notStarted,
  inProgress,
  completed,
  requiresAction,
}

enum PaymentMethodType {
  card,
  bankAccount,
  wallet,
}

enum EarningsFilter {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}