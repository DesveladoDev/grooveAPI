import 'dart:async';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'logging_service.dart';

/// Advanced analytics service for detailed conversion tracking and business intelligence
class AdvancedAnalyticsService {
  static final AdvancedAnalyticsService _instance = AdvancedAnalyticsService._internal();
  factory AdvancedAnalyticsService() => _instance;
  AdvancedAnalyticsService._internal() {
    // Avoid accessing FirebaseAnalytics.instance before Firebase is initialized
    if (Firebase.apps.isNotEmpty) {
      _analytics = FirebaseAnalytics.instance;
    }
  }

  // Lazy-initialized to prevent early Firebase access
  late FirebaseAnalytics _analytics;
  
  // Helper to cast dynamic maps to Object for FirebaseAnalytics parameters (drop nulls)
  Map<String, Object>? _toObjectParams(Map<String, dynamic>? src) {
    if (src == null) return null;
    final out = <String, Object>{};
    src.forEach((k, v) {
      if (v == null) return; // drop nulls to satisfy Map<String, Object>
      if (v is String) {
        out[k] = v;
      } else if (v is bool) {
        out[k] = v;
      } else if (v is num) {
        out[k] = v;
      } else if (v is Map || v is List) {
        // Encode complex structures as JSON strings to keep parameters simple
        out[k] = jsonEncode(v);
      } else {
        out[k] = v.toString();
      }
    });
    return out;
  }
  
  SharedPreferences? _prefs;
  final Map<String, ConversionFunnelTracker> _activeFunnels = {};
  final Map<String, UserJourneyTracker> _activeJourneys = {};
  
  /// Initialize the advanced analytics service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadActiveFunnels();
      await _loadActiveJourneys();
      
      LoggingService.info(
        'Advanced Analytics Service initialized',
        category: LogCategory.analytics,
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initialize Advanced Analytics Service',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Start tracking a conversion funnel
  Future<void> startConversionFunnel(String funnelName, {
    Map<String, dynamic>? initialContext,
  }) async {
    try {
      final funnel = ConversionFunnelTracker(
        name: funnelName,
        startTime: DateTime.now(),
        initialContext: initialContext ?? {},
      );
      
      _activeFunnels[funnelName] = funnel;
      await _saveActiveFunnels();
      
      await _analytics.logEvent(
        name: 'funnel_started',
        parameters: <String, Object>{
          'funnel_name': funnelName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?_toObjectParams(initialContext),
        },
      );
      
      LoggingService.info(
        'Started conversion funnel: $funnelName',
        category: LogCategory.analytics,
        context: LogContext(metadata: {
          'funnel_name': funnelName,
          'context': initialContext,
        }),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to start conversion funnel: $funnelName',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track a step in a conversion funnel
  Future<void> trackFunnelStep(String funnelName, String stepName, {
    Map<String, dynamic>? stepData,
    bool isConversion = false,
  }) async {
    try {
      final funnel = _activeFunnels[funnelName];
      if (funnel == null) {
        LoggingService.warning(
          'Attempted to track step for non-existent funnel: $funnelName',
          category: LogCategory.analytics,
        );
        return;
      }

      final step = FunnelStep(
        name: stepName,
        timestamp: DateTime.now(),
        data: stepData ?? {},
        isConversion: isConversion,
      );

      funnel.addStep(step);
      await _saveActiveFunnels();

      await _analytics.logEvent(
        name: 'funnel_step',
        parameters: <String, Object>{
          'funnel_name': funnelName,
          'step_name': stepName,
          'step_index': funnel.steps.length,
          'time_from_start': DateTime.now().difference(funnel.startTime).inSeconds,
          'is_conversion': isConversion,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?_toObjectParams(stepData),
        },
      );

      if (isConversion) {
        await _completeFunnel(funnelName);
      }

      LoggingService.info(
        'Tracked funnel step: $funnelName -> $stepName',
        category: LogCategory.analytics,
        context: LogContext(metadata: {
          'funnel_name': funnelName,
          'step_name': stepName,
          'is_conversion': isConversion,
          'step_data': stepData,
        }),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track funnel step: $funnelName -> $stepName',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Complete a conversion funnel
  Future<void> _completeFunnel(String funnelName) async {
    try {
      final funnel = _activeFunnels[funnelName];
      if (funnel == null) return;

      funnel.complete();
      
      await _analytics.logEvent(
        name: 'funnel_completed',
        parameters: <String, Object>{
          'funnel_name': funnelName,
          'total_steps': funnel.steps.length,
          'total_duration': funnel.totalDuration?.inSeconds ?? 0,
          'conversion_rate': 1.0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      _activeFunnels.remove(funnelName);
      await _saveActiveFunnels();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to complete funnel: $funnelName',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Abandon a conversion funnel
  Future<void> abandonFunnel(String funnelName, String reason) async {
    try {
      final funnel = _activeFunnels[funnelName];
      if (funnel == null) return;

      await _analytics.logEvent(
        name: 'funnel_abandoned',
        parameters: <String, Object>{
          'funnel_name': funnelName,
          'abandon_reason': reason,
          'steps_completed': funnel.steps.length,
          'time_spent': DateTime.now().difference(funnel.startTime).inSeconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      _activeFunnels.remove(funnelName);
      await _saveActiveFunnels();

      LoggingService.info(
        'Abandoned funnel: $funnelName',
        category: LogCategory.analytics,
        context: LogContext(metadata: {'funnel_name': funnelName, 'reason': reason}),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to abandon funnel: $funnelName',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Start tracking a user journey
  Future<void> startUserJourney(String journeyId, String journeyType, {
    Map<String, dynamic>? context,
  }) async {
    try {
      final journey = UserJourneyTracker(
        id: journeyId,
        type: journeyType,
        startTime: DateTime.now(),
        context: context ?? {},
      );

      _activeJourneys[journeyId] = journey;
      await _saveActiveJourneys();

      await _analytics.logEvent(
        name: 'user_journey_started',
        parameters: <String, Object>{
          'journey_id': journeyId,
          'journey_type': journeyType,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?_toObjectParams(context),
        },
      );

      LoggingService.info(
        'Started user journey: $journeyId ($journeyType)',
        category: LogCategory.analytics,
        context: LogContext(metadata: {'journey_id': journeyId, 'journey_type': journeyType}),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to start user journey: $journeyId',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track a touchpoint in a user journey
  Future<void> trackJourneyTouchpoint(String journeyId, String touchpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final journey = _activeJourneys[journeyId];
      if (journey == null) {
        LoggingService.warning(
          'Attempted to track touchpoint for non-existent journey: $journeyId',
          category: LogCategory.analytics,
        );
        return;
      }

      final touchpointData = JourneyTouchpoint(
        name: touchpoint,
        timestamp: DateTime.now(),
        data: data ?? {},
      );

      journey.addTouchpoint(touchpointData);
      await _saveActiveJourneys();

      await _analytics.logEvent(
        name: 'journey_touchpoint',
        parameters: <String, Object>{
          'journey_id': journeyId,
          'journey_type': journey.type,
          'touchpoint': touchpoint,
          'touchpoint_index': journey.touchpoints.length,
          'time_from_start': DateTime.now().difference(journey.startTime).inSeconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?_toObjectParams(data),
        },
      );

      LoggingService.info(
        'Tracked journey touchpoint: $journeyId -> $touchpoint',
        category: LogCategory.analytics,
        context: LogContext(metadata: {
          'journey_id': journeyId,
          'touchpoint': touchpoint,
          'data': data,
        }),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track journey touchpoint: $journeyId -> $touchpoint',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Complete a user journey
  Future<void> completeUserJourney(String journeyId, String outcome, {
    Map<String, dynamic>? finalData,
  }) async {
    try {
      final journey = _activeJourneys[journeyId];
      if (journey == null) return;

      journey.complete(outcome, finalData);

      await _analytics.logEvent(
        name: 'user_journey_completed',
        parameters: <String, Object>{
          'journey_id': journeyId,
          'journey_type': journey.type,
          'outcome': outcome,
          'total_touchpoints': journey.touchpoints.length,
          'total_duration': journey.totalDuration?.inSeconds ?? 0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          ...?_toObjectParams(finalData),
        },
      );

      _activeJourneys.remove(journeyId);
      await _saveActiveJourneys();

      LoggingService.info(
        'Completed user journey: $journeyId with outcome: $outcome',
        category: LogCategory.analytics,
        context: LogContext(metadata: {
          'journey_id': journeyId,
          'outcome': outcome,
          'final_data': finalData,
        }),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to complete user journey: $journeyId',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Track custom business event
  Future<void> trackBusinessEvent(String eventName, {
    Map<String, dynamic>? properties,
    double? value,
    String? currency,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?properties,
      };

      if (value != null) {
        parameters['value'] = value;
      }
      if (currency != null) {
        parameters['currency'] = currency;
      }

      await _analytics.logEvent(
        name: 'business_event_$eventName',
        parameters: <String, Object>{
          ...?_toObjectParams(parameters),
        },
      );

      LoggingService.info(
        'Tracked business event: $eventName',
        category: LogCategory.analytics,
        context: LogContext(metadata: {
          'event_name': eventName,
          'properties': properties,
          'value': value,
          'currency': currency,
        }),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to track business event: $eventName',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get analytics summary
  Future<AnalyticsSummary> getAnalyticsSummary() async {
    try {
      return AnalyticsSummary(
        activeFunnels: _activeFunnels.length,
        activeJourneys: _activeJourneys.length,
        funnelNames: _activeFunnels.keys.toList(),
        journeyTypes: _activeJourneys.values.map((j) => j.type).toSet().toList(),
        oldestFunnelAge: _activeFunnels.values.isEmpty
            ? null
            : _activeFunnels.values
                .map((f) => DateTime.now().difference(f.startTime))
                .reduce((a, b) => a > b ? a : b),
        oldestJourneyAge: _activeJourneys.values.isEmpty
            ? null
            : _activeJourneys.values
                .map((j) => DateTime.now().difference(j.startTime))
                .reduce((a, b) => a > b ? a : b),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to get analytics summary',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
      return AnalyticsSummary.empty();
    }
  }

  /// Save active funnels to persistent storage
  Future<void> _saveActiveFunnels() async {
    try {
      final funnelsJson = _activeFunnels.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await _prefs?.setString('active_funnels', jsonEncode(funnelsJson));
    } catch (e) {
      LoggingService.error(
        'Failed to save active funnels',
        category: LogCategory.analytics,
        error: e,
      );
    }
  }

  /// Load active funnels from persistent storage
  Future<void> _loadActiveFunnels() async {
    try {
      final funnelsString = _prefs?.getString('active_funnels');
      if (funnelsString != null) {
        final funnelsJson = jsonDecode(funnelsString) as Map<String, dynamic>;
        _activeFunnels.clear();
        funnelsJson.forEach((key, value) {
          _activeFunnels[key] = ConversionFunnelTracker.fromJson(
            Map<String, dynamic>.from(value as Map),
          );
        });
      }
    } catch (e) {
      LoggingService.error(
        'Failed to load active funnels',
        category: LogCategory.analytics,
        error: e,
      );
    }
  }

  /// Save active journeys to persistent storage
  Future<void> _saveActiveJourneys() async {
    try {
      final journeysJson = _activeJourneys.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await _prefs?.setString('active_journeys', jsonEncode(journeysJson));
    } catch (e) {
      LoggingService.error(
        'Failed to save active journeys',
        category: LogCategory.analytics,
        error: e,
      );
    }
  }

  /// Load active journeys from persistent storage
  Future<void> _loadActiveJourneys() async {
    try {
      final journeysString = _prefs?.getString('active_journeys');
      if (journeysString != null) {
        final journeysJson = jsonDecode(journeysString) as Map<String, dynamic>;
        _activeJourneys.clear();
        journeysJson.forEach((key, value) {
          _activeJourneys[key] = UserJourneyTracker.fromJson(
            Map<String, dynamic>.from(value as Map),
          );
        });
      }
    } catch (e) {
      LoggingService.error(
        'Failed to load active journeys',
        category: LogCategory.analytics,
        error: e,
      );
    }
  }

  /// Clean up old funnels and journeys
  Future<void> cleanup() async {
    try {
      final now = DateTime.now();
      final maxAge = const Duration(hours: 24);

      // Clean up old funnels
      final oldFunnels = _activeFunnels.entries
          .where((entry) => now.difference(entry.value.startTime) > maxAge)
          .map((entry) => entry.key)
          .toList();

      for (final funnelName in oldFunnels) {
        await abandonFunnel(funnelName, 'timeout');
      }

      // Clean up old journeys
      final oldJourneys = _activeJourneys.entries
          .where((entry) => now.difference(entry.value.startTime) > maxAge)
          .map((entry) => entry.key)
          .toList();

      for (final journeyId in oldJourneys) {
        await completeUserJourney(journeyId, 'timeout');
      }

      LoggingService.info(
        'Cleaned up ${oldFunnels.length} old funnels and ${oldJourneys.length} old journeys',
        category: LogCategory.analytics,
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to cleanup old analytics data',
        category: LogCategory.analytics,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Conversion funnel tracker
class ConversionFunnelTracker {
  final String name;
  final DateTime startTime;
  final Map<String, dynamic> initialContext;
  final List<FunnelStep> steps = [];
  DateTime? endTime;
  bool isCompleted = false;

  ConversionFunnelTracker({
    required this.name,
    required this.startTime,
    required this.initialContext,
  });

  void addStep(FunnelStep step) {
    steps.add(step);
  }

  void complete() {
    endTime = DateTime.now();
    isCompleted = true;
  }

  Duration? get totalDuration => endTime?.difference(startTime);

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime.millisecondsSinceEpoch,
        'initialContext': initialContext,
        'steps': steps.map((s) => s.toJson()).toList(),
        'endTime': endTime?.millisecondsSinceEpoch,
        'isCompleted': isCompleted,
      };

  factory ConversionFunnelTracker.fromJson(Map<String, dynamic> json) {
    final tracker = ConversionFunnelTracker(
      name: json['name'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      initialContext: Map<String, dynamic>.from(json['initialContext'] as Map),
    );
    
    tracker.steps.addAll(
      (json['steps'] as List)
          .map((s) => FunnelStep.fromJson(Map<String, dynamic>.from(s as Map))),
    );
    
    if (json['endTime'] != null) {
      tracker.endTime = DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int);
    }
    
    tracker.isCompleted = (json['isCompleted'] as bool?) ?? false;
    
    return tracker;
  }
}

/// Funnel step
class FunnelStep {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final bool isConversion;

  FunnelStep({
    required this.name,
    required this.timestamp,
    required this.data,
    this.isConversion = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'data': data,
        'isConversion': isConversion,
      };

  factory FunnelStep.fromJson(Map<String, dynamic> json) => FunnelStep(
        name: json['name'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        data: Map<String, dynamic>.from(json['data'] as Map),
        isConversion: (json['isConversion'] as bool?) ?? false,
      );
}

/// User journey tracker
class UserJourneyTracker {
  final String id;
  final String type;
  final DateTime startTime;
  final Map<String, dynamic> context;
  final List<JourneyTouchpoint> touchpoints = [];
  DateTime? endTime;
  String? outcome;
  Map<String, dynamic>? finalData;

  UserJourneyTracker({
    required this.id,
    required this.type,
    required this.startTime,
    required this.context,
  });

  void addTouchpoint(JourneyTouchpoint touchpoint) {
    touchpoints.add(touchpoint);
  }

  void complete(String journeyOutcome, Map<String, dynamic>? data) {
    endTime = DateTime.now();
    outcome = journeyOutcome;
    finalData = data;
  }

  Duration? get totalDuration => endTime?.difference(startTime);

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'startTime': startTime.millisecondsSinceEpoch,
        'context': context,
        'touchpoints': touchpoints.map((t) => t.toJson()).toList(),
        'endTime': endTime?.millisecondsSinceEpoch,
        'outcome': outcome,
        'finalData': finalData,
      };

  factory UserJourneyTracker.fromJson(Map<String, dynamic> json) {
    final tracker = UserJourneyTracker(
      id: json['id'] as String,
      type: json['type'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      context: Map<String, dynamic>.from(json['context'] as Map),
    );
    
    tracker.touchpoints.addAll(
      (json['touchpoints'] as List)
          .map((t) => JourneyTouchpoint.fromJson(Map<String, dynamic>.from(t as Map))),
    );
    
    if (json['endTime'] != null) {
      tracker.endTime = DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int);
    }
    
    tracker.outcome = json['outcome'] as String?;
    tracker.finalData = json['finalData'] != null
        ? Map<String, dynamic>.from(json['finalData'] as Map)
        : null;
    
    return tracker;
  }
}

/// Journey touchpoint
class JourneyTouchpoint {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  JourneyTouchpoint({
    required this.name,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'data': data,
      };

  factory JourneyTouchpoint.fromJson(Map<String, dynamic> json) =>
      JourneyTouchpoint(
        name: json['name'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        data: Map<String, dynamic>.from(json['data'] as Map),
      );
}

/// Analytics summary
class AnalyticsSummary {
  final int activeFunnels;
  final int activeJourneys;
  final List<String> funnelNames;
  final List<String> journeyTypes;
  final Duration? oldestFunnelAge;
  final Duration? oldestJourneyAge;

  AnalyticsSummary({
    required this.activeFunnels,
    required this.activeJourneys,
    required this.funnelNames,
    required this.journeyTypes,
    this.oldestFunnelAge,
    this.oldestJourneyAge,
  });

  factory AnalyticsSummary.empty() => AnalyticsSummary(
        activeFunnels: 0,
        activeJourneys: 0,
        funnelNames: [],
        journeyTypes: [],
      );
}