import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:salas_beats/utils/helpers.dart';
import 'package:salas_beats/utils/power_mode.dart';

enum AnalyticsEvent {
  // User events
  userSignUp,
  userSignIn,
  userSignOut,
  userProfileUpdate,
  userOnboarding,
  
  // Listing events
  listingView,
  listingSearch,
  listingFilter,
  listingFavorite,
  listingShare,
  listingCreate,
  listingUpdate,
  listingDelete,
  
  // Booking events
  bookingStart,
  bookingComplete,
  bookingCancel,
  bookingModify,
  bookingReview,
  
  // Payment events
  paymentStart,
  paymentComplete,
  paymentFailed,
  paymentRefund,
  
  // Navigation events
  screenView,
  buttonTap,
  linkTap,
  
  // Feature usage
  featureUsed,
  tutorialStart,
  tutorialComplete,
  
  // Error events
  errorOccurred,
  crashReported,
  
  // Performance events
  performanceTrace,
  networkRequest,
  
  // Business events
  revenue,
  conversion,
  retention,
}

enum UserProperty {
  userId,
  userType,
  signUpMethod,
  deviceType,
  appVersion,
  platform,
  language,
  country,
  city,
  isHost,
  isGuest,
  subscriptionStatus,
  totalBookings,
  totalListings,
  accountAge,
  lastActiveDate,
}

class AnalyticsEventData {
  
  const AnalyticsEventData({
    required this.event,
    required this.parameters,
    required this.timestamp,
    this.userId,
    this.sessionId,
  });
  
  factory AnalyticsEventData.fromJson(Map<String, dynamic> json) => AnalyticsEventData(
      event: AnalyticsEvent.values.firstWhere(
        (e) => e.name == json['event'],
        orElse: () => AnalyticsEvent.featureUsed,
      ),
      parameters: (json['parameters'] as Map<String, dynamic>?) ?? {},
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['user_id'] as String?,
      sessionId: json['session_id'] as String?,
    );
  final AnalyticsEvent event;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  
  Map<String, dynamic> toJson() => {
      'event': event.name,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
      'session_id': sessionId,
    };
}

class PerformanceTrace {
  
  const PerformanceTrace({
    required this.name,
    required this.startTime,
    this.endTime,
    this.attributes = const {},
    this.metrics = const {},
  });
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> attributes;
  final Map<String, int> metrics;
  
  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }
  
  bool get isCompleted => endTime != null;
  
  PerformanceTrace copyWith({
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? attributes,
    Map<String, int>? metrics,
  }) => PerformanceTrace(
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attributes: attributes ?? this.attributes,
      metrics: metrics ?? this.metrics,
    );
}

class CrashReport {
  
  const CrashReport({
    required this.error,
    required this.timestamp, this.stackTrace,
    this.context = const {},
    this.userId,
    this.isFatal = false,
  });
  final String error;
  final String? stackTrace;
  final Map<String, dynamic> context;
  final DateTime timestamp;
  final String? userId;
  final bool isFatal;
  
  Map<String, dynamic> toJson() => {
      'error': error,
      'stack_trace': stackTrace,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
      'is_fatal': isFatal,
    };
}

class DeviceInfo {
  
  const DeviceInfo({
    required this.deviceId,
    required this.platform,
    required this.platformVersion,
    required this.deviceModel,
    required this.deviceBrand,
    required this.appVersion,
    required this.appBuildNumber,
    required this.language,
    required this.country,
    required this.screenWidth,
    required this.screenHeight,
    required this.devicePixelRatio,
  });
  final String deviceId;
  final String platform;
  final String platformVersion;
  final String deviceModel;
  final String deviceBrand;
  final String appVersion;
  final String appBuildNumber;
  final String language;
  final String country;
  final double screenWidth;
  final double screenHeight;
  final double devicePixelRatio;
  
  Map<String, dynamic> toJson() => {
      'device_id': deviceId,
      'platform': platform,
      'platform_version': platformVersion,
      'device_model': deviceModel,
      'device_brand': deviceBrand,
      'app_version': appVersion,
      'app_build_number': appBuildNumber,
      'language': language,
      'country': country,
      'screen_width': screenWidth,
      'screen_height': screenHeight,
      'device_pixel_ratio': devicePixelRatio,
    };
}

class AnalyticsManager {
  
  AnalyticsManager._();
  static AnalyticsManager? _instance;
  static AnalyticsManager get instance => _instance ??= AnalyticsManager._();
  
  // Initialized during `initialize()` to avoid early Firebase access
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;
  FirebasePerformance? _performance;
  
  bool _isInitialized = false;
  String? _currentUserId;
  String? _sessionId;
  DeviceInfo? _deviceInfo;
  final Map<String, dynamic> _activeTraces = {};
  final List<AnalyticsEventData> _eventQueue = [];
  Timer? _flushTimer;
  
  // Getters
  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentUserId;
  String? get sessionId => _sessionId;
  DeviceInfo? get deviceInfo => _deviceInfo;
  
  // Initialize analytics
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      // Initialize Firebase clients only after Firebase is ready
      // This avoids accessing Firebase.*.instance during class load
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;
      _performance = FirebasePerformance.instance;
      
      // Generate session ID
      _sessionId = Helpers.generateId();
      
      // Collect device info
      await _collectDeviceInfo();
      
      // Configure Firebase Analytics
      await _analytics.setAnalyticsCollectionEnabled(true);
      
      // Configure Crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      
      // Set up automatic crash reporting
      FlutterError.onError = (errorDetails) {
        _crashlytics.recordFlutterFatalError(errorDetails);
        recordCrash(
          CrashReport(
            error: errorDetails.exception.toString(),
            stackTrace: errorDetails.stack.toString(),
            context: {
              'library': errorDetails.library,
              'context': errorDetails.context?.toString(),
            },
            timestamp: DateTime.now(),
            userId: _currentUserId,
            isFatal: true,
          ),
        );
      };
      
      // Set up isolate error handling
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        recordCrash(
          CrashReport(
            error: error.toString(),
            stackTrace: stack.toString(),
            timestamp: DateTime.now(),
            userId: _currentUserId,
            isFatal: true,
          ),
        );
        return true;
      };
      
      // Start periodic flush timer
      _startFlushTimer();
      
      _isInitialized = true;
      debugPrint('AnalyticsManager initialized successfully');
      
      // Track app start
      trackEvent(AnalyticsEvent.screenView, {
        'screen_name': 'app_start',
        'session_id': _sessionId,
      });
    } catch (e) {
      debugPrint('Failed to initialize AnalyticsManager: $e');
      throw Exception('Failed to initialize analytics: $e');
    }
  }
  
  // Collect device information
  Future<void> _collectDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      var deviceId = '';
      var platform = '';
      var platformVersion = '';
      var deviceModel = '';
      var deviceBrand = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
        platform = 'Android';
        platformVersion = androidInfo.version.release;
        deviceModel = androidInfo.model;
        deviceBrand = androidInfo.brand;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        platform = 'iOS';
        platformVersion = iosInfo.systemVersion;
        deviceModel = iosInfo.model;
        deviceBrand = 'Apple';
      }
      
      _deviceInfo = DeviceInfo(
        deviceId: deviceId,
        platform: platform,
        platformVersion: platformVersion,
        deviceModel: deviceModel,
        deviceBrand: deviceBrand,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
        language: Platform.localeName.split('_').first,
        country: Platform.localeName.split('_').last,
        screenWidth: 0, // Will be set when available
        screenHeight: 0, // Will be set when available
        devicePixelRatio: 1, // Will be set when available
      );
    } catch (e) {
      debugPrint('Failed to collect device info: $e');
    }
  }
  
  // Set user ID
  Future<void> setUserId(String? userId) async {
    try {
      _currentUserId = userId;
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId ?? '');
      
      if (userId != null) {
        trackEvent(AnalyticsEvent.userSignIn, {
          'user_id': userId,
          'method': 'unknown',
        });
      }
    } catch (e) {
      debugPrint('Failed to set user ID: $e');
    }
  }
  
  // Set user properties
  Future<void> setUserProperty(UserProperty property, String? value) async {
    try {
      await _analytics.setUserProperty(
        name: property.name,
        value: value,
      );
      
      await _crashlytics.setCustomKey(property.name, value ?? '');
    } catch (e) {
      debugPrint('Failed to set user property: $e');
    }
  }
  
  // Set multiple user properties
  Future<void> setUserProperties(Map<UserProperty, String?> properties) async {
    for (final entry in properties.entries) {
      await setUserProperty(entry.key, entry.value);
    }
  }
  
  // Track event
  Future<void> trackEvent(
    AnalyticsEvent event, 
    Map<String, dynamic> parameters,
  ) async {
    try {
      // Add common parameters
      final enrichedParameters = {
        ...parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _sessionId,
        'user_id': _currentUserId,
        'platform': _deviceInfo?.platform,
        'app_version': _deviceInfo?.appVersion,
      };
      
      // Track with Firebase Analytics
      await _analytics.logEvent(
        name: event.name,
        parameters: _sanitizeParameters(enrichedParameters),
      );
      
      // Add to event queue for custom analytics
      final eventData = AnalyticsEventData(
        event: event,
        parameters: enrichedParameters,
        timestamp: DateTime.now(),
        userId: _currentUserId,
        sessionId: _sessionId,
      );
      
      _eventQueue.add(eventData);
      
      debugPrint('Tracked event: ${event.name} with parameters: $enrichedParameters');
    } catch (e) {
      debugPrint('Failed to track event: $e');
    }
  }
  
  // Track screen view
  Future<void> trackScreenView(
    String screenName, {
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(AnalyticsEvent.screenView, {
      'screen_name': screenName,
      'screen_class': screenClass ?? screenName,
      ...?parameters,
    });
    
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }
  
  // Track user signup
  Future<void> trackUserSignUp({
    required String method,
    String? userId,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(AnalyticsEvent.userSignUp, {
      'method': method,
      'user_id': userId ?? _currentUserId,
      ...?parameters,
    });
    
    await _analytics.logSignUp(signUpMethod: method);
  }
  
  // Track user login
  Future<void> trackUserLogin({
    required String method,
    String? userId,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(AnalyticsEvent.userSignIn, {
      'method': method,
      'user_id': userId ?? _currentUserId,
      ...?parameters,
    });
    
    await _analytics.logLogin(loginMethod: method);
  }
  
  // Track listing view
  Future<void> trackListingView(
    String listingId, {
    String? category,
    double? price,
    String? location,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(AnalyticsEvent.listingView, {
      'listing_id': listingId,
      'category': category,
      'price': price,
      'location': location,
      ...?parameters,
    });
    
    await _analytics.logViewItem(
      currency: 'USD',
      value: price,
      parameters: {
        'item_id': listingId,
        'item_category': category ?? '',
        'item_location': location ?? '',
      },
    );
  }
  
  // Track search
  Future<void> trackSearch(
    String searchTerm, {
    String? category,
    String? location,
    int? resultCount,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(AnalyticsEvent.listingSearch, {
      'search_term': searchTerm,
      'category': category,
      'location': location,
      'result_count': resultCount,
      ...?parameters,
    });
    
    await _analytics.logSearch(
      searchTerm: searchTerm,
      destination: location,
      travelClass: category,
    );
  }
  
  // Track booking
  Future<void> trackBooking(
    String bookingId, {
    required String listingId,
    required double amount,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(AnalyticsEvent.bookingComplete, {
      'booking_id': bookingId,
      'listing_id': listingId,
      'amount': amount,
      'currency': currency,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      ...?parameters,
    });
    
    await _analytics.logPurchase(
      currency: currency,
      value: amount,
      parameters: {
        'transaction_id': bookingId,
        'item_id': listingId,
        'start_date': startDate?.toIso8601String() ?? '',
        'end_date': endDate?.toIso8601String() ?? '',
      },
    );
  }
  
  // Track revenue
  Future<void> trackRevenue(
    double amount, {
    required String currency,
    String? transactionId,
    String? source,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(AnalyticsEvent.revenue, {
      'amount': amount,
      'currency': currency,
      'transaction_id': transactionId,
      'source': source,
      ...?parameters,
    });
  }
  
  // Start performance trace
  Future<dynamic> startTrace(String traceName) async {
    try {
      final trace = _performance.newTrace(traceName);
      await trace.start();
      _activeTraces[traceName] = trace;
      
      debugPrint('Started performance trace: $traceName');
      return trace;
    } catch (e) {
      debugPrint('Failed to start trace: $e');
      rethrow;
    }
  }
  
  // Stop performance trace
  Future<void> stopTrace(
    String traceName, {
    Map<String, String>? attributes,
    Map<String, int>? metrics,
  }) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        // Add attributes
        if (attributes != null) {
          for (final entry in attributes.entries) {
            trace.putAttribute(entry.key, entry.value);
          }
        }
        
        // Add metrics
        if (metrics != null) {
          for (final entry in metrics.entries) {
            trace.putMetric(entry.key, entry.value);
          }
        }
        
        await trace.stop();
        _activeTraces.remove(traceName);
        
        debugPrint('Stopped performance trace: $traceName');
      }
    } catch (e) {
      debugPrint('Failed to stop trace: $e');
    }
  }
  
  // Record crash
  Future<void> recordCrash(CrashReport crashReport) async {
    try {
      await _crashlytics.recordError(
        crashReport.error,
        crashReport.stackTrace != null 
            ? StackTrace.fromString(crashReport.stackTrace!)
            : null,
        fatal: crashReport.isFatal,
        information: crashReport.context.entries
            .map((e) => '${e.key}: ${e.value}')
            .toList(),
      );
      
      // Track as analytics event
      await trackEvent(AnalyticsEvent.crashReported, {
        'error': crashReport.error,
        'is_fatal': crashReport.isFatal,
        'context': crashReport.context,
      });
      
      debugPrint('Recorded crash: ${crashReport.error}');
    } catch (e) {
      debugPrint('Failed to record crash: $e');
    }
  }
  
  // Record non-fatal error
  Future<void> recordError(
    error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        information: context?.entries
            .map((e) => '${e.key}: ${e.value}')
            .toList() ?? [],
      );
      
      await trackEvent(AnalyticsEvent.errorOccurred, {
        'error': error.toString(),
        'context': context,
      });
      
      debugPrint('Recorded error: $error');
    } catch (e) {
      debugPrint('Failed to record error: $e');
    }
  }
  
  // Set custom crash key
  Future<void> setCrashKey(String key, value) async {
    try {
      await _crashlytics.setCustomKey(key, value as Object);
    } catch (e) {
      debugPrint('Failed to set crash key: $e');
    }
  }
  
  // Flush events to server
  Future<void> flushEvents() async {
    try {
      if (_eventQueue.isEmpty) return;
      
      final events = List<AnalyticsEventData>.from(_eventQueue);
      _eventQueue.clear();
      
      // Send events to custom analytics endpoint
      await _sendEventsToServer(events);
      
      debugPrint('Flushed ${events.length} analytics events');
    } catch (e) {
      debugPrint('Failed to flush events: $e');
      // Re-add events to queue on failure
      // _eventQueue.addAll(events);
    }
  }
  
  // Send events to server
  Future<void> _sendEventsToServer(List<AnalyticsEventData> events) async {
    // Implementation depends on your analytics backend
    // This is a placeholder for custom analytics
    debugPrint('Sending ${events.length} events to analytics server');
  }
  
  // Start flush timer
  void _startFlushTimer() {
    _flushTimer?.cancel();
    final interval = PowerModeManager.instance
        .adjustedInterval(const Duration(minutes: 5), lowPowerFactor: 3.0);
    _flushTimer = Timer.periodic(interval, (_) => flushEvents());
  }
  
  // Sanitize parameters for Firebase Analytics
  Map<String, Object> _sanitizeParameters(Map<String, dynamic> parameters) {
    final sanitized = <String, Object>{};
    
    for (final entry in parameters.entries) {
      final key = entry.key.replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');
      final value = entry.value;
      
      if (value is String) {
        sanitized[key] = value.length > 100 ? value.substring(0, 100) : value;
      } else if (value is num) {
        sanitized[key] = value;
      } else if (value is bool) {
        sanitized[key] = value;
      } else if (value != null) {
        sanitized[key] = value.toString();
      }
    }
    
    return sanitized;
  }
  
  // Dispose resources
  void dispose() {
    _flushTimer?.cancel();
    flushEvents();
  }
}

// Analytics utilities
class AnalyticsUtils {
  // Track user journey
  static Future<void> trackUserJourney(
    String journeyName,
    String step, {
    Map<String, dynamic>? parameters,
  }) async {
    await AnalyticsManager.instance.trackEvent(
      AnalyticsEvent.featureUsed,
      {
        'journey_name': journeyName,
        'journey_step': step,
        ...?parameters,
      },
    );
  }
  
  // Track feature usage
  static Future<void> trackFeatureUsage(
    String featureName, {
    String? action,
    Map<String, dynamic>? parameters,
  }) async {
    await AnalyticsManager.instance.trackEvent(
      AnalyticsEvent.featureUsed,
      {
        'feature_name': featureName,
        'action': action,
        ...?parameters,
      },
    );
  }
  
  // Track button tap
  static Future<void> trackButtonTap(
    String buttonName, {
    String? screenName,
    Map<String, dynamic>? parameters,
  }) async {
    await AnalyticsManager.instance.trackEvent(
      AnalyticsEvent.buttonTap,
      {
        'button_name': buttonName,
        'screen_name': screenName,
        ...?parameters,
      },
    );
  }
  
  // Track conversion
  static Future<void> trackConversion(
    String conversionType,
    double value, {
    String? currency,
    Map<String, dynamic>? parameters,
  }) async {
    await AnalyticsManager.instance.trackEvent(
      AnalyticsEvent.conversion,
      {
        'conversion_type': conversionType,
        'value': value,
        'currency': currency ?? 'USD',
        ...?parameters,
      },
    );
  }
  
  // Track retention
  static Future<void> trackRetention(
    int daysSinceInstall,
    int daysSinceLastUse, {
    Map<String, dynamic>? parameters,
  }) async {
    await AnalyticsManager.instance.trackEvent(
      AnalyticsEvent.retention,
      {
        'days_since_install': daysSinceInstall,
        'days_since_last_use': daysSinceLastUse,
        ...?parameters,
      },
    );
  }
  
  // Create timed operation
  static Future<T> timedOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    final trace = await AnalyticsManager.instance.startTrace(operationName);
    
    try {
      final result = await operation();
      
      await AnalyticsManager.instance.stopTrace(
        operationName,
        attributes: {
          'status': 'success',
          ...?attributes,
        },
      );
      
      return result;
    } catch (e) {
      await AnalyticsManager.instance.stopTrace(
        operationName,
        attributes: {
          'status': 'error',
          'error': e.toString(),
          ...?attributes,
        },
      );
      
      await AnalyticsManager.instance.recordError(e);
      rethrow;
    }
  }
  
  // Get analytics summary
  static Map<String, dynamic> getAnalyticsSummary() {
    final manager = AnalyticsManager.instance;
    
    return {
      'is_initialized': manager.isInitialized,
      'user_id': manager.currentUserId,
      'session_id': manager.sessionId,
      'device_info': manager.deviceInfo?.toJson(),
      'active_traces': manager._activeTraces.keys.toList(),
      'queued_events': manager._eventQueue.length,
    };
  }
}