import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'logging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'advanced_analytics_service.dart';

/// Business Intelligence service for tracking custom business events and metrics
class BusinessIntelligenceService {
  static final BusinessIntelligenceService _instance = BusinessIntelligenceService._internal();
  factory BusinessIntelligenceService() => _instance;
  BusinessIntelligenceService._internal() {
    // Avoid accessing FirebaseAnalytics.instance before Firebase is initialized
    if (Firebase.apps.isNotEmpty) {
      _analytics = FirebaseAnalytics.instance;
    }
  }

  // Lazy-initialized to prevent early Firebase access
  late FirebaseAnalytics _analytics;
  final LoggingService _logger = LoggingService();
  final AdvancedAnalyticsService _advancedAnalytics = AdvancedAnalyticsService();

  /// Initialize the business intelligence service
  Future<void> initialize() async {
    try {
      _logger.log(
        LogLevel.info,
        'Business Intelligence Service initialized',
        category: LogCategory.system,
      );
    } catch (e, stackTrace) {
      _logger.log(
        LogLevel.error,
        'Failed to initialize Business Intelligence Service',
        category: LogCategory.system,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================================
  // BOOKING INTELLIGENCE
  // ============================================================================

  /// Track booking funnel progression
  Future<void> trackBookingFunnel(BookingFunnelStep step, {
    String? studioId,
    String? serviceType,
    double? price,
    DateTime? selectedDate,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      const funnelName = 'booking_conversion';
      
      switch (step) {
        case BookingFunnelStep.searchInitiated:
          await _advancedAnalytics.startConversionFunnel(funnelName, initialContext: {
            'studio_id': studioId,
            'service_type': serviceType,
            'search_timestamp': DateTime.now().millisecondsSinceEpoch,
            ...?additionalData,
          });
          break;
          
        case BookingFunnelStep.studioViewed:
          await _advancedAnalytics.trackFunnelStep(funnelName, 'studio_viewed', stepData: {
            'studio_id': studioId,
            'service_type': serviceType,
            ...?additionalData,
          });
          break;
          
        case BookingFunnelStep.dateSelected:
          await _advancedAnalytics.trackFunnelStep(funnelName, 'date_selected', stepData: {
            'studio_id': studioId,
            'selected_date': selectedDate?.millisecondsSinceEpoch,
            'price': price,
            ...?additionalData,
          });
          break;
          
        case BookingFunnelStep.paymentInitiated:
          await _advancedAnalytics.trackFunnelStep(funnelName, 'payment_initiated', stepData: {
            'studio_id': studioId,
            'price': price,
            'payment_method': additionalData?['payment_method'],
            ...?additionalData,
          });
          break;
          
        case BookingFunnelStep.bookingCompleted:
          await _advancedAnalytics.trackFunnelStep(funnelName, 'booking_completed', 
            stepData: {
              'studio_id': studioId,
              'price': price,
              'booking_id': additionalData?['booking_id'],
              ...?additionalData,
            },
            isConversion: true,
          );
          break;
      }

      await _trackCustomEvent('booking_funnel_step', {
        'step': step.name,
        'studio_id': studioId,
        'service_type': serviceType,
        'price': price,
        'selected_date': selectedDate?.millisecondsSinceEpoch,
        ...?additionalData,
      });
    } catch (e, stackTrace) {
      _logger.log(
        LogLevel.error,
        'Failed to track booking funnel step: ${step.name}',
        category: LogCategory.booking,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track booking abandonment
  Future<void> trackBookingAbandonment(String reason, {
    String? studioId,
    String? lastStep,
    double? price,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _advancedAnalytics.abandonFunnel('booking_conversion', reason);
      
      await _trackCustomEvent('booking_abandoned', {
        'abandonment_reason': reason,
        'studio_id': studioId,
        'last_step': lastStep,
        'price': price,
        'abandonment_timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?context,
      });
    } catch (e, stackTrace) {
      _logger.log(
        LogLevel.error,
        'Failed to track booking abandonment',
        category: LogCategory.booking,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track booking modification
  Future<void> trackBookingModification(BookingModificationType type, {
    required String bookingId,
    String? studioId,
    DateTime? oldDate,
    DateTime? newDate,
    double? oldPrice,
    double? newPrice,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _trackCustomEvent('booking_modified', {
        'modification_type': type.name,
        'booking_id': bookingId,
        'studio_id': studioId,
        'old_date': oldDate?.millisecondsSinceEpoch,
        'new_date': newDate?.millisecondsSinceEpoch,
        'old_price': oldPrice,
        'new_price': newPrice,
        'price_difference': (newPrice != null && oldPrice != null) ? newPrice - oldPrice : null,
        'modification_timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalData,
      });
    } catch (e, stackTrace) {
      _logger.log(
        LogLevel.error,
        'Failed to track booking modification',
        category: LogCategory.booking,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================================
  // REVENUE INTELLIGENCE
  // ============================================================================

  /// Track revenue events
  Future<void> trackRevenue(RevenueEvent event, {
    required double amount,
    required String currency,
    String? bookingId,
    String? studioId,
    String? paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _trackCustomEvent('revenue_event', {
        'event_type': event.name,
        'amount': amount,
        'currency': currency,
        'booking_id': bookingId,
        'studio_id': studioId,
        'payment_method': paymentMethod,
        'revenue_timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?metadata,
      });

      // Track in Firebase Analytics with value
      await _analytics.logEvent(
        name: 'purchase',
        parameters: {
          'value': amount,
          'currency': currency,
          'transaction_id': bookingId,
          'item_category': 'studio_booking',
          'payment_type': paymentMethod,
          ...?metadata,
        },
      );
    } catch (e, stackTrace) {
      _logger.log(
        LogLevel.error,
        'Failed to track revenue event: ${event.name}',
        category: LogCategory.payment,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track refund
  Future<void> trackRefund({
    required String bookingId,
    required double refundAmount,
    required String currency,
    required String reason,
    String? studioId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _trackCustomEvent('refund_processed', {
        'booking_id': bookingId,
        'refund_amount': refundAmount,
        'currency': currency,
        'refund_reason': reason,
        'studio_id': studioId,
        'refund_timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?additionalData,
      });

      await _analytics.logEvent(
        name: 'refund',
        parameters: <String, Object>{
          'value': refundAmount,
          'currency': currency,
          'transaction_id': bookingId,
          'refund_reason': reason,
          ...?_toObjectParams(additionalData),
        },
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track refund',
        category: LogCategory.payment,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================================
  // USER BEHAVIOR INTELLIGENCE
  // ============================================================================

  /// Track user engagement
  Future<void> trackUserEngagement(EngagementEvent event, {
    String? userId,
    String? screenName,
    Duration? sessionDuration,
    int? interactionCount,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _trackCustomEvent('user_engagement', {
        'engagement_type': event.name,
        'user_id': userId,
        'screen_name': screenName,
        'session_duration_seconds': sessionDuration?.inSeconds,
        'interaction_count': interactionCount,
        'engagement_timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?context,
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track user engagement: ${event.name}',
        category: LogCategory.ui,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track search behavior
  Future<void> trackSearchBehavior({
    required String searchQuery,
    required int resultsCount,
    String? selectedFilter,
    String? sortOrder,
    int? resultClickPosition,
    String? selectedStudioId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      await _trackCustomEvent('search_behavior', {
        'search_query': searchQuery,
        'results_count': resultsCount,
        'selected_filter': selectedFilter,
        'sort_order': sortOrder,
        'result_click_position': resultClickPosition,
        'selected_studio_id': selectedStudioId,
        'applied_filters': filters,
        'search_timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      await _analytics.logEvent(
        name: 'search',
        parameters: <String, Object>{
          'search_term': searchQuery,
          'number_of_results': resultsCount,
          if (filters != null) 'filters': jsonEncode(filters),
          if (selectedFilter != null) 'selected_filter': selectedFilter,
          if (sortOrder != null) 'sort_order': sortOrder,
          if (resultClickPosition != null) 'result_click_position': resultClickPosition,
          if (selectedStudioId != null) 'selected_studio_id': selectedStudioId,
        },
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track search behavior',
        category: LogCategory.search,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track content interaction
  Future<void> trackContentInteraction(ContentInteractionType type, {
    required String contentId,
    String? contentType,
    String? contentCategory,
    Duration? timeSpent,
    double? scrollDepth,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _trackCustomEvent('content_interaction', {
        'interaction_type': type.name,
        'content_id': contentId,
        'content_type': contentType,
        'content_category': contentCategory,
        'time_spent_seconds': timeSpent?.inSeconds,
        'scroll_depth_percentage': scrollDepth,
        'interaction_timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?metadata,
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track content interaction: ${type.name}',
        category: LogCategory.ui,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================================
  // STUDIO OWNER INTELLIGENCE
  // ============================================================================

  /// Track studio performance metrics
  Future<void> trackStudioPerformance({
    required String studioId,
    required StudioMetricType metricType,
    required double value,
    String? period,
    Map<String, dynamic>? breakdown,
  }) async {
    try {
      await _trackCustomEvent('studio_performance', {
        'studio_id': studioId,
        'metric_type': metricType.name,
        'metric_value': value,
        'period': period,
        'breakdown': breakdown,
        'measurement_timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track studio performance: ${metricType.name}',
        category: LogCategory.performance,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track studio owner actions
  Future<void> trackStudioOwnerAction(StudioOwnerAction action, {
    required String studioId,
    String? targetId,
    Map<String, dynamic>? actionData,
  }) async {
    try {
      await _trackCustomEvent('studio_owner_action', {
        'action_type': action.name,
        'studio_id': studioId,
        'target_id': targetId,
        'action_data': actionData,
        'action_timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track studio owner action: ${action.name}',
        category: LogCategory.user,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================================
  // COHORT AND RETENTION INTELLIGENCE
  // ============================================================================

  /// Track user cohort data
  Future<void> trackUserCohort({
    required String userId,
    required DateTime registrationDate,
    String? acquisitionChannel,
    String? referralSource,
    Map<String, dynamic>? cohortData,
  }) async {
    try {
      final cohortWeek = _getCohortWeek(registrationDate);
      
      await _trackCustomEvent('user_cohort', {
        'user_id': userId,
        'registration_date': registrationDate.millisecondsSinceEpoch,
        'cohort_week': cohortWeek,
        'acquisition_channel': acquisitionChannel,
        'referral_source': referralSource,
        'days_since_registration': DateTime.now().difference(registrationDate).inDays,
        ...?cohortData,
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track user cohort',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track retention milestone
  Future<void> trackRetentionMilestone({
    required String userId,
    required RetentionMilestone milestone,
    required DateTime registrationDate,
    Map<String, dynamic>? milestoneData,
  }) async {
    try {
      final daysSinceRegistration = DateTime.now().difference(registrationDate).inDays;
      
      await _trackCustomEvent('retention_milestone', {
        'user_id': userId,
        'milestone': milestone.name,
        'days_since_registration': daysSinceRegistration,
        'registration_date': registrationDate.millisecondsSinceEpoch,
        'milestone_timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?milestoneData,
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track retention milestone: ${milestone.name}',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================================
  // A/B TESTING INTELLIGENCE
  // ============================================================================

  /// Track A/B test participation
  Future<void> trackABTestParticipation({
    required String testName,
    required String variant,
    String? userId,
    Map<String, dynamic>? testContext,
  }) async {
    try {
      await _trackCustomEvent('ab_test_participation', {
        'test_name': testName,
        'variant': variant,
        'user_id': userId,
        'participation_timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?testContext,
      });

      // Set user property for Firebase Analytics
      await _analytics.setUserProperty(
        name: 'ab_test_$testName',
        value: variant,
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track A/B test participation: $testName',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track A/B test conversion
  Future<void> trackABTestConversion({
    required String testName,
    required String variant,
    required String conversionEvent,
    double? conversionValue,
    Map<String, dynamic>? conversionData,
  }) async {
    try {
      await _trackCustomEvent('ab_test_conversion', {
        'test_name': testName,
        'variant': variant,
        'conversion_event': conversionEvent,
        'conversion_value': conversionValue,
        'conversion_timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?conversionData,
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track A/B test conversion: $testName',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Track custom event with standardized format
  Future<void> _trackCustomEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      // Add standard metadata
      final enrichedParameters = {
        ...parameters,
        'app_version': '1.0.0', // TODO: Get from package info
        'platform': 'flutter',
        'event_id': _generateEventId(),
      };

      await _analytics.logEvent(
        name: eventName,
        parameters: enrichedParameters,
      );

      await _advancedAnalytics.trackBusinessEvent(eventName, properties: enrichedParameters);
    } catch (e, stackTrace) {
      _logger.log(
        LogLevel.error,
        'Failed to track custom event: $eventName',
        category: LogCategory.system,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Generate unique event ID
  String _generateEventId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '${timestamp}_$random';
  }

  /// Get cohort week for user registration
  String _getCohortWeek(DateTime registrationDate) {
    final weekStart = registrationDate.subtract(Duration(days: registrationDate.weekday - 1));
    return '${weekStart.year}-W${_getWeekOfYear(weekStart)}';
  }

  /// Get week of year
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }
}

// ============================================================================
// ENUMS AND TYPES
// ============================================================================

enum BookingFunnelStep {
  searchInitiated,
  studioViewed,
  dateSelected,
  paymentInitiated,
  bookingCompleted,
}

enum BookingModificationType {
  dateChange,
  cancellation,
  serviceChange,
  priceChange,
}

enum RevenueEvent {
  bookingPayment,
  subscriptionPayment,
  additionalService,
  tip,
  refund,
}

enum EngagementEvent {
  sessionStart,
  sessionEnd,
  screenView,
  featureUsed,
  deepEngagement,
}

enum ContentInteractionType {
  view,
  click,
  share,
  favorite,
  comment,
  rate,
}

enum StudioMetricType {
  bookingCount,
  revenue,
  averageRating,
  responseTime,
  cancellationRate,
  repeatCustomerRate,
}

enum StudioOwnerAction {
  profileUpdate,
  availabilityUpdate,
  priceUpdate,
  serviceAdd,
  serviceRemove,
  photoUpload,
  messageReply,
}

enum RetentionMilestone {
  day1,
  day7,
  day30,
  day90,
  day180,
  day365,
}