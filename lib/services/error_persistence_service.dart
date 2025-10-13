import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastErrorInfo {
  final String message;
  final String? library;
  final String? context;
  final String stackTrace;
  final DateTime timestamp;

  LastErrorInfo({
    required this.message,
    required this.stackTrace,
    required this.timestamp,
    this.library,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'library': library,
        'context': context,
        'stackTrace': stackTrace,
        'timestamp': timestamp.toIso8601String(),
      };

  static LastErrorInfo fromJson(Map<String, dynamic> json) => LastErrorInfo(
        message: json['message'] as String? ?? '',
        library: json['library'] as String?,
        context: json['context'] as String?,
        stackTrace: json['stackTrace'] as String? ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      );
}

class ErrorPersistenceService {
  static const _key = 'last_error_info';

  /// Guarda el último error de forma persistente.
  static Future<void> save(FlutterErrorDetails details) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final info = LastErrorInfo(
        message: details.exceptionAsString(),
        library: details.library,
        context: details.context?.toDescription(),
        stackTrace: (details.stack ?? StackTrace.current).toString(),
        timestamp: DateTime.now(),
      );
      await prefs.setString(_key, jsonEncode(info.toJson()));
    } catch (_) {
      // Silenciar errores de persistencia para no interferir con el flujo de la app.
    }
  }

  /// Obtiene el último error guardado.
  static Future<LastErrorInfo?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      return LastErrorInfo.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  /// Limpia el último error.
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}