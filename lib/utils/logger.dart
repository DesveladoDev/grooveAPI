import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel {
  verbose(0, 'VERBOSE', '🔍'),
  debug(1, 'DEBUG', '🐛'),
  info(2, 'INFO', 'ℹ️'),
  warning(3, 'WARNING', '⚠️'),
  error(4, 'ERROR', '❌'),
  fatal(5, 'FATAL', '💀');
  
  const LogLevel(this.priority, this.name, this.emoji);
  
  final int priority;
  final String name;
  final String emoji;
  
  bool operator >=(LogLevel other) => priority >= other.priority;
  bool operator <=(LogLevel other) => priority <= other.priority;
  bool operator >(LogLevel other) => priority > other.priority;
  bool operator <(LogLevel other) => priority < other.priority;
}

class LogEntry {
  
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.data,
    this.stackTrace,
    this.fileName,
    this.lineNumber,
    this.functionName,
  });
  
  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      tag: json['tag'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      stackTrace: json['stack_trace'] as String?,
      fileName: json['file_name'] as String?,
      lineNumber: json['line_number'] as int?,
      functionName: json['function_name'] as String?,
    );
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? data;
  final String? stackTrace;
  final String? fileName;
  final int? lineNumber;
  final String? functionName;
  
  String get formattedMessage {
    final buffer = StringBuffer();
    
    // Timestamp
    buffer.write('[${DateFormat('HH:mm:ss.SSS').format(timestamp)}] ');
    
    // Level with emoji
    buffer.write('${level.emoji} ${level.name} ');
    
    // Tag
    if (tag != null) {
      buffer.write('[$tag] ');
    }
    
    // File and line info
    if (fileName != null) {
      final shortFileName = fileName!.split('/').last;
      buffer.write('($shortFileName');
      if (lineNumber != null) {
        buffer.write(':$lineNumber');
      }
      if (functionName != null) {
        buffer.write(' in $functionName');
      }
      buffer.write(') ');
    }
    
    // Message
    buffer.write(message);
    
    // Data
    if (data != null && data!.isNotEmpty) {
      buffer.write('\n  Data: ${_formatData(data!)}');
    }
    
    // Stack trace
    if (stackTrace != null) {
      buffer.write('\n  Stack trace:\n$stackTrace');
    }
    
    return buffer.toString();
  }
  
  String _formatData(Map<String, dynamic> data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }
  
  Map<String, dynamic> toJson() => {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'tag': tag,
      'data': data,
      'stack_trace': stackTrace,
      'file_name': fileName,
      'line_number': lineNumber,
      'function_name': functionName,
    };
}

class LogFilter {
  
  const LogFilter({
    this.minLevel,
    this.maxLevel,
    this.tags,
    this.excludeTags,
    this.messagePattern,
    this.startTime,
    this.endTime,
  });
  final LogLevel? minLevel;
  final LogLevel? maxLevel;
  final List<String>? tags;
  final List<String>? excludeTags;
  final String? messagePattern;
  final DateTime? startTime;
  final DateTime? endTime;
  
  bool matches(LogEntry entry) {
    // Level filter
    if (minLevel != null && entry.level < minLevel!) return false;
    if (maxLevel != null && entry.level > maxLevel!) return false;
    
    // Tag filter
    if (tags != null && tags!.isNotEmpty) {
      if (entry.tag == null || !tags!.contains(entry.tag)) return false;
    }
    
    // Exclude tags filter
    if (excludeTags != null && excludeTags!.isNotEmpty) {
      if (entry.tag != null && excludeTags!.contains(entry.tag)) return false;
    }
    
    // Message pattern filter
    if (messagePattern != null && messagePattern!.isNotEmpty) {
      if (!entry.message.toLowerCase().contains(messagePattern!.toLowerCase())) {
        return false;
      }
    }
    
    // Time range filter
    if (startTime != null && entry.timestamp.isBefore(startTime!)) return false;
    if (endTime != null && entry.timestamp.isAfter(endTime!)) return false;
    
    return true;
  }
}

class LogOutput {
  
  const LogOutput({
    required this.name,
    this.enabled = true,
    this.minLevel = LogLevel.debug,
  });
  final String name;
  final bool enabled;
  final LogLevel minLevel;
  
  Future<void> write(LogEntry entry) async {
    if (!enabled || entry.level < minLevel) return;
    await _writeEntry(entry);
  }
  
  Future<void> _writeEntry(LogEntry entry) async {
    // Override in subclasses
  }
  
  Future<void> flush() async {
    // Override in subclasses
  }
  
  Future<void> close() async {
    // Override in subclasses
  }
}

class ConsoleLogOutput extends LogOutput {
  ConsoleLogOutput({
    super.enabled,
    super.minLevel,
  }) : super(
          name: 'console',
        );
  
  @override
  Future<void> _writeEntry(LogEntry entry) async {
    if (kDebugMode) {
      debugPrint(entry.formattedMessage);
    }
  }
}

class FileLogOutput extends LogOutput {
  
  FileLogOutput({
    required this.fileName,
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.maxFiles = 5,
    super.enabled,
    super.minLevel = LogLevel.info,
  }) : super(
          name: 'file',
        );
  final String fileName;
  final int maxFileSize;
  final int maxFiles;
  File? _logFile;
  IOSink? _sink;
  int _currentFileSize = 0;
  
  Future<void> _initializeFile() async {
    if (_logFile != null) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');
      
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }
      
      _logFile = File('${logsDir.path}/$fileName');
      
      if (await _logFile!.exists()) {
        _currentFileSize = await _logFile!.length();
      }
      
      _sink = _logFile!.openWrite(mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to initialize log file: $e');
    }
  }
  
  @override
  Future<void> _writeEntry(LogEntry entry) async {
    try {
      await _initializeFile();
      
      if (_sink == null) return;
      
      final logLine = '${entry.formattedMessage}\n';
      final lineBytes = utf8.encode(logLine);
      
      // Check if we need to rotate the file
      if (_currentFileSize + lineBytes.length > maxFileSize) {
        await _rotateFile();
      }
      
      _sink!.write(logLine);
      _currentFileSize += lineBytes.length;
    } catch (e) {
      debugPrint('Failed to write log entry to file: $e');
    }
  }
  
  Future<void> _rotateFile() async {
    try {
      await _sink?.close();
      
      if (_logFile != null && await _logFile!.exists()) {
        final directory = _logFile!.parent;
        final baseName = fileName.split('.').first;
        final extension = fileName.split('.').last;
        
        // Rotate existing files
        for (var i = maxFiles - 1; i > 0; i--) {
          final oldFile = File('${directory.path}/$baseName.$i.$extension');
          final newFile = File('${directory.path}/$baseName.${i + 1}.$extension');
          
          if (await oldFile.exists()) {
            if (i == maxFiles - 1) {
              await oldFile.delete();
            } else {
              await oldFile.rename(newFile.path);
            }
          }
        }
        
        // Move current file to .1
        final rotatedFile = File('${directory.path}/$baseName.1.$extension');
        await _logFile!.rename(rotatedFile.path);
      }
      
      // Create new file
      _logFile = File('${_logFile!.parent.path}/$fileName');
      _sink = _logFile!.openWrite();
      _currentFileSize = 0;
    } catch (e) {
      debugPrint('Failed to rotate log file: $e');
    }
  }
  
  @override
  Future<void> flush() async {
    await _sink?.flush();
  }
  
  @override
  Future<void> close() async {
    await _sink?.close();
    _sink = null;
    _logFile = null;
  }
  
  Future<List<String>> getLogFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');
      
      if (!await logsDir.exists()) return [];
      
      final files = await logsDir.list().toList();
      return files
          .whereType<File>()
          .map((f) => f.path)
          .where((path) => path.contains(fileName.split('.').first))
          .toList();
    } catch (e) {
      debugPrint('Failed to get log files: $e');
      return [];
    }
  }
  
  Future<String> readLogFile([String? filePath]) async {
    try {
      final file = filePath != null ? File(filePath) : _logFile;
      if (file == null || !await file.exists()) return '';
      
      return await file.readAsString();
    } catch (e) {
      debugPrint('Failed to read log file: $e');
      return '';
    }
  }
}

class MemoryLogOutput extends LogOutput {
  
  MemoryLogOutput({
    this.maxEntries = 1000,
    super.enabled,
    super.minLevel,
  }) : super(
          name: 'memory',
        );
  final int maxEntries;
  final List<LogEntry> _entries = [];
  
  @override
  Future<void> _writeEntry(LogEntry entry) async {
    _entries.add(entry);
    
    // Remove old entries if we exceed the limit
    while (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
  }
  
  List<LogEntry> getEntries([LogFilter? filter]) {
    if (filter == null) return List.from(_entries);
    
    return _entries.where(filter.matches).toList();
  }
  
  void clear() {
    _entries.clear();
  }
  
  int get entryCount => _entries.length;
}

class Logger {
  
  Logger._();
  static Logger? _instance;
  static Logger get instance => _instance ??= Logger._();
  
  final List<LogOutput> _outputs = [];
  LogLevel _minLevel = LogLevel.debug;
  bool _enabled = true;
  String? _globalTag;
  
  // Getters
  LogLevel get minLevel => _minLevel;
  bool get enabled => _enabled;
  String? get globalTag => _globalTag;
  List<LogOutput> get outputs => List.from(_outputs);
  
  // Initialize logger
  Future<void> initialize({
    LogLevel minLevel = LogLevel.debug,
    bool enabled = true,
    String? globalTag,
    List<LogOutput>? outputs,
  }) async {
    _minLevel = minLevel;
    _enabled = enabled;
    _globalTag = globalTag;
    
    // Clear existing outputs
    for (final output in _outputs) {
      await output.close();
    }
    _outputs.clear();
    
    // Add default outputs if none provided
    if (outputs == null || outputs.isEmpty) {
      _outputs.addAll([
        ConsoleLogOutput(
          
        ),
        FileLogOutput(
          fileName: 'app.log',
        ),
        MemoryLogOutput(
          maxEntries: 500,
        ),
      ]);
    } else {
      _outputs.addAll(outputs);
    }
    
    debugPrint('Logger initialized with ${_outputs.length} outputs');
  }
  
  // Add output
  void addOutput(LogOutput output) {
    _outputs.add(output);
  }
  
  // Remove output
  void removeOutput(String name) {
    _outputs.removeWhere((output) => output.name == name);
  }
  
  // Set minimum log level
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }
  
  // Enable/disable logging
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }
  
  // Set global tag
  void setGlobalTag(String? tag) {
    _globalTag = tag;
  }
  
  // Log with specific level
  Future<void> log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? data,
    String? stackTrace,
    String? fileName,
    int? lineNumber,
    String? functionName,
  }) async {
    if (!_enabled || level < _minLevel) return;
    
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag ?? _globalTag,
      data: data,
      stackTrace: stackTrace,
      fileName: fileName,
      lineNumber: lineNumber,
      functionName: functionName,
    );
    
    // Write to all outputs
    for (final output in _outputs) {
      try {
        await output.write(entry);
      } catch (e) {
        debugPrint('Failed to write to output ${output.name}: $e');
      }
    }
  }
  
  // Convenience methods
  Future<void> verbose(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) async {
    await log(
      LogLevel.verbose,
      message,
      tag: tag,
      data: data,
    );
  }
  
  Future<void> debug(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) async {
    await log(
      LogLevel.debug,
      message,
      tag: tag,
      data: data,
    );
  }
  
  Future<void> info(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) async {
    await log(
      LogLevel.info,
      message,
      tag: tag,
      data: data,
    );
  }
  
  Future<void> warning(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) async {
    await log(
      LogLevel.warning,
      message,
      tag: tag,
      data: data,
    );
  }
  
  Future<void> error(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
    error,
    StackTrace? stackTrace,
  }) async {
    await log(
      LogLevel.error,
      message,
      tag: tag,
      data: {
        ...?data,
        if (error != null) 'error': error.toString(),
      },
      stackTrace: stackTrace?.toString(),
    );
  }
  
  Future<void> fatal(
    String message, {
    String? tag,
    Map<String, dynamic>? data,
    error,
    StackTrace? stackTrace,
  }) async {
    await log(
      LogLevel.fatal,
      message,
      tag: tag,
      data: {
        ...?data,
        if (error != null) 'error': error.toString(),
      },
      stackTrace: stackTrace?.toString(),
    );
  }
  
  // Log with automatic caller info
  Future<void> logWithCaller(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? data,
  }) async {
    final stackTrace = StackTrace.current;
    final frames = stackTrace.toString().split('\n');
    
    String? fileName;
    int? lineNumber;
    String? functionName;
    
    if (frames.length > 1) {
      final frame = frames[1];
      final match = RegExp(r'#\d+\s+(.+?)\s+\((.+?):(\d+):(\d+)\)').firstMatch(frame);
      
      if (match != null) {
        functionName = match.group(1);
        fileName = match.group(2);
        lineNumber = int.tryParse(match.group(3) ?? '');
      }
    }
    
    await log(
      level,
      message,
      tag: tag,
      data: data,
      fileName: fileName,
      lineNumber: lineNumber,
      functionName: functionName,
    );
  }
  
  // Flush all outputs
  Future<void> flush() async {
    for (final output in _outputs) {
      try {
        await output.flush();
      } catch (e) {
        debugPrint('Failed to flush output ${output.name}: $e');
      }
    }
  }
  
  // Close all outputs
  Future<void> close() async {
    for (final output in _outputs) {
      try {
        await output.close();
      } catch (e) {
        debugPrint('Failed to close output ${output.name}: $e');
      }
    }
    _outputs.clear();
  }
  
  // Get memory logs
  List<LogEntry> getMemoryLogs([LogFilter? filter]) {
    final memoryOutput = _outputs
        .whereType<MemoryLogOutput>()
        .firstOrNull;
    
    return memoryOutput?.getEntries(filter) ?? [];
  }
  
  // Clear memory logs
  void clearMemoryLogs() {
    final memoryOutput = _outputs
        .whereType<MemoryLogOutput>()
        .firstOrNull;
    
    memoryOutput?.clear();
  }
  
  // Get log files
  Future<List<String>> getLogFiles() async {
    final fileOutput = _outputs
        .whereType<FileLogOutput>()
        .firstOrNull;
    
    return await fileOutput?.getLogFiles() ?? [];
  }
  
  // Read log file
  Future<String> readLogFile([String? filePath]) async {
    final fileOutput = _outputs
        .whereType<FileLogOutput>()
        .firstOrNull;
    
    return await fileOutput?.readLogFile(filePath) ?? '';
  }
  
  // Export logs
  Future<String> exportLogs({
    LogFilter? filter,
    bool includeMemoryLogs = true,
    bool includeFileLogs = true,
  }) async {
    final buffer = StringBuffer();
    
    buffer.writeln('=== LOG EXPORT ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Filter: ${filter != null ? 'Applied' : 'None'}');
    buffer.writeln();
    
    if (includeMemoryLogs) {
      buffer.writeln('=== MEMORY LOGS ===');
      final memoryLogs = getMemoryLogs(filter);
      for (final entry in memoryLogs) {
        buffer.writeln(entry.formattedMessage);
      }
      buffer.writeln();
    }
    
    if (includeFileLogs) {
      buffer.writeln('=== FILE LOGS ===');
      final logFiles = await getLogFiles();
      for (final filePath in logFiles) {
        buffer.writeln('--- File: $filePath ---');
        final content = await readLogFile(filePath);
        buffer.writeln(content);
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }
}

// Global logger functions
Future<void> logVerbose(
  String message, {
  String? tag,
  Map<String, dynamic>? data,
}) async {
  await Logger.instance.verbose(message, tag: tag, data: data);
}

Future<void> logDebug(
  String message, {
  String? tag,
  Map<String, dynamic>? data,
}) async {
  await Logger.instance.debug(message, tag: tag, data: data);
}

Future<void> logInfo(
  String message, {
  String? tag,
  Map<String, dynamic>? data,
}) async {
  await Logger.instance.info(message, tag: tag, data: data);
}

Future<void> logWarning(
  String message, {
  String? tag,
  Map<String, dynamic>? data,
}) async {
  await Logger.instance.warning(message, tag: tag, data: data);
}

Future<void> logError(
  String message, {
  String? tag,
  Map<String, dynamic>? data,
  error,
  StackTrace? stackTrace,
}) async {
  await Logger.instance.error(
    message,
    tag: tag,
    data: data,
    error: error,
    stackTrace: stackTrace,
  );
}

Future<void> logFatal(
  String message, {
  String? tag,
  Map<String, dynamic>? data,
  error,
  StackTrace? stackTrace,
}) async {
  await Logger.instance.fatal(
    message,
    tag: tag,
    data: data,
    error: error,
    stackTrace: stackTrace,
  );
}

// Extension for easier logging
extension LoggerExtension on Object {
  Future<void> logDebug(String message, {Map<String, dynamic>? data}) async {
    await Logger.instance.debug(
      message,
      tag: runtimeType.toString(),
      data: data,
    );
  }
  
  Future<void> logInfo(String message, {Map<String, dynamic>? data}) async {
    await Logger.instance.info(
      message,
      tag: runtimeType.toString(),
      data: data,
    );
  }
  
  Future<void> logWarning(String message, {Map<String, dynamic>? data}) async {
    await Logger.instance.warning(
      message,
      tag: runtimeType.toString(),
      data: data,
    );
  }
  
  Future<void> logError(
    String message, {
    Map<String, dynamic>? data,
    error,
    StackTrace? stackTrace,
  }) async {
    await Logger.instance.error(
      message,
      tag: runtimeType.toString(),
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }
}