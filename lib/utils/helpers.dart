import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:permission_handler/permission_handler.dart';
import 'package:salas_beats/config/app_constants.dart';
import 'package:salas_beats/utils/formatters.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  // Random ID generation
  static String generateId({int length = 20}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
  
  // Generate booking reference
  static String generateBookingReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'SB${timestamp.substring(timestamp.length - 6)}$random';
  }
  
  // Generate hash
  static String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Color utilities
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
  
  static String colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  
  static Color darkenColor(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  static Color lightenColor(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  // Device utilities
  static bool isTablet(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.size.shortestSide >= 600;
  }
  
  static bool isLandscape(BuildContext context) => MediaQuery.of(context).orientation == Orientation.landscape;
  
  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  
  static double getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  
  static double getScreenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  static EdgeInsets getSafeAreaPadding(BuildContext context) => MediaQuery.of(context).padding;
  
  // Haptic feedback
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }
  
  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }
  
  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }
  
  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }
  
  // Clipboard utilities
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
  
  static Future<String?> getFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }
  
  // URL utilities
  static Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }
  
  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&'),
    );
    
    return launchUrl(uri);
  }
  
  static Future<bool> launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    return launchUrl(uri);
  }
  
  static Future<bool> launchSMS(String phoneNumber, {String? message}) async {
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      query: message != null ? 'body=${Uri.encodeComponent(message)}' : null,
    );
    
    return launchUrl(uri);
  }
  
  static Future<bool> launchWhatsApp(String phoneNumber, {String? message}) async {
    final cleanNumber = Formatters.cleanPhoneNumber(phoneNumber);
    final encodedMessage = message != null ? Uri.encodeComponent(message) : '';
    final url = 'https://wa.me/$cleanNumber?text=$encodedMessage';
    
    return launchURL(url);
  }
  
  // Share utilities
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }
  
  static Future<void> shareFile(String filePath, {String? text}) async {
    await Share.shareXFiles([picker.XFile(filePath)], text: text);
  }
  
  static Future<void> shareFiles(List<String> filePaths, {String? text}) async {
    final xFiles = filePaths.map(picker.XFile.new).toList();
    await Share.shareXFiles(xFiles, text: text);
  }
  
  // Image utilities
  static Future<picker.XFile?> pickImageFromGallery() async {
    final imagePicker = picker.ImagePicker();
    return imagePicker.pickImage(
      source: picker.ImageSource.gallery,
      maxWidth: AppConstants.maxImageWidth.toDouble(),
      maxHeight: AppConstants.maxImageHeight.toDouble(),
      imageQuality: AppConstants.imageQuality,
    );
  }
  
  static Future<picker.XFile?> pickImageFromCamera() async {
    final imagePicker = picker.ImagePicker();
    return imagePicker.pickImage(
      source: picker.ImageSource.camera,
      maxWidth: AppConstants.maxImageWidth.toDouble(),
      maxHeight: AppConstants.maxImageHeight.toDouble(),
      imageQuality: AppConstants.imageQuality,
    );
  }
  
  static Future<List<picker.XFile>?> pickMultipleImages() async {
    final imagePicker = picker.ImagePicker();
    return imagePicker.pickMultiImage(
      maxWidth: AppConstants.maxImageWidth.toDouble(),
      maxHeight: AppConstants.maxImageHeight.toDouble(),
      imageQuality: AppConstants.imageQuality,
    );
  }
  
  // Permission utilities
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  static Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }
  
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
  
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
  
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  // Location utilities
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;
      
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }
  
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }
  
  // Validation utilities
  static bool isValidEmail(String email) => RegExp(AppConstants.emailPattern).hasMatch(email);
  
  static bool isValidPhone(String phone) => RegExp(AppConstants.phonePattern).hasMatch(phone);
  
  static bool isValidPassword(String password) => RegExp(AppConstants.passwordPattern).hasMatch(password);
  
  static bool isValidUrl(String url) {
    // Simple URL validation pattern
    const urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
    return RegExp(urlPattern).hasMatch(url);
  }
  
  // Date utilities
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }
  
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
  
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
  
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }
  
  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
  
  static DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  
  static DateTime startOfWeek(DateTime date) => date.subtract(Duration(days: date.weekday - 1));
  
  static DateTime endOfWeek(DateTime date) => startOfWeek(date).add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  
  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);
  
  static DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  
  static List<DateTime> getDaysInMonth(DateTime date) {
    final start = startOfMonth(date);
    final end = endOfMonth(date);
    final days = <DateTime>[];
    
    for (var day = start; day.isBefore(end) || day.isAtSameMomentAs(end); day = day.add(const Duration(days: 1))) {
      days.add(day);
    }
    
    return days;
  }
  
  static List<DateTime> getWeekDays(DateTime date) {
    final start = startOfWeek(date);
    final days = <DateTime>[];
    
    for (var i = 0; i < 7; i++) {
      days.add(start.add(Duration(days: i)));
    }
    
    return days;
  }
  
  // Format date utility
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    switch (format) {
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'dd MMM yyyy':
        final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
        return '${date.day} ${months[date.month - 1]} ${date.year}';
      case 'MMMM dd, yyyy':
        final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      default:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
  
  // Time utilities
  static TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
  
  static String timeOfDayToString(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  
  static DateTime combineDateTime(DateTime date, TimeOfDay time) => DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  
  static bool isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (startMinutes <= endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Crosses midnight
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }
  
  // List utilities
  static List<T> removeDuplicates<T>(List<T> list) => list.toSet().toList();
  
  static List<T> shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }
  
  static List<List<T>> chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, (i + size).clamp(0, list.length)));
    }
    return chunks;
  }
  
  // Map utilities
  static Map<K, V> removeNullValues<K, V>(Map<K, V?> map) {
    final result = <K, V>{};
    map.forEach((key, value) {
      if (value != null) {
        result[key] = value;
      }
    });
    return result;
  }
  
  // String utilities
  static String removeAccents(String text) {
    const accents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    const withoutAccents = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeeCcIIIIiiiiUUUUuuuuyNn';
    
    var result = text;
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], withoutAccents[i]);
    }
    return result;
  }
  
  static String slugify(String text) => removeAccents(text)
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  
  static String extractInitials(String name, {int maxLength = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .where((word) => word.isNotEmpty)
        .take(maxLength)
        .map((word) => word[0].toUpperCase())
        .join();
    return initials;
  }
  
  // Number utilities
  static double roundToDecimals(double value, int decimals) {
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }
  
  static int randomInt(int min, int max) => min + Random().nextInt(max - min + 1);
  
  static double randomDouble(double min, double max) => min + Random().nextDouble() * (max - min);
  
  // File utilities
  static String getFileExtension(String fileName) => fileName.split('.').last.toLowerCase();
  
  static String getFileName(String filePath) => filePath.split('/').last;
  
  static String getFileNameWithoutExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      parts.removeLast();
    }
    return parts.join('.');
  }
  
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }
  
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv'].contains(extension);
  }
  
  static bool isAudioFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a'].contains(extension);
  }
  
  // Error handling utilities
  static String getErrorMessage(error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'Ha ocurrido un error inesperado';
  }
  
  static void logError(String message, [error, StackTrace? stackTrace]) {
    debugPrint('ERROR: $message');
    if (error != null) debugPrint('Error details: $error');
    if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
  }
  
  // Debounce utility
  static Timer? _debounceTimer;
  
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
  
  // Throttle utility
  static DateTime? _lastThrottleTime;
  
  static void throttle(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) >= delay) {
      _lastThrottleTime = now;
      callback();
    }
  }
  
  // Platform utilities
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  
  // Network utilities
  static bool isValidIPAddress(String ip) => RegExp(r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$').hasMatch(ip);
  
  // Currency utilities
  static double calculateTax(double amount, double taxRate) => amount * (taxRate / 100);
  
  static double calculateTotal(double amount, double taxRate) => amount + calculateTax(amount, taxRate);
  
  static double calculateCommission(double amount, double commissionRate) => amount * (commissionRate / 100);
  
  static double calculateDiscount(double amount, double discountRate) => amount * (discountRate / 100);
  
  static double applyDiscount(double amount, double discountRate) => amount - calculateDiscount(amount, discountRate);
  
  // Search utilities
  static List<T> searchList<T>(
    List<T> list,
    String query,
    String Function(T) getSearchText,
  ) {
    if (query.isEmpty) return list;
    
    final normalizedQuery = removeAccents(query.toLowerCase());
    
    return list.where((item) {
      final searchText = removeAccents(getSearchText(item).toLowerCase());
      return searchText.contains(normalizedQuery);
    }).toList();
  }
  
  // Sort utilities
  static List<T> sortList<T>(
    List<T> list,
    Comparable Function(T) getComparable, {
    bool ascending = true,
  }) {
    final sorted = List<T>.from(list);
    sorted.sort((a, b) {
      final comparison = getComparable(a).compareTo(getComparable(b));
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }
}

// Extension methods
extension ListExtensions<T> on List<T> {
  List<T> get withoutDuplicates => Helpers.removeDuplicates(this);
  List<T> get shuffled => Helpers.shuffle(this);
  List<List<T>> chunk(int size) => Helpers.chunk(this, size);
  
  List<T> search(String query, String Function(T) getSearchText) => Helpers.searchList(this, query, getSearchText);
  
  List<T> sortBy(Comparable Function(T) getComparable, {bool ascending = true}) => Helpers.sortList(this, getComparable, ascending: ascending);
}

extension StringExtensions on String {
  String get withoutAccents => Helpers.removeAccents(this);
  String get slugified => Helpers.slugify(this);
  String get initials => Helpers.extractInitials(this);
  String get fileExtension => Helpers.getFileExtension(this);
  String get fileName => Helpers.getFileName(this);
  String get fileNameWithoutExtension => Helpers.getFileNameWithoutExtension(this);
  
  bool get isValidEmail => Helpers.isValidEmail(this);
  bool get isValidPhone => Helpers.isValidPhone(this);
  bool get isValidPassword => Helpers.isValidPassword(this);
  bool get isValidURL => Helpers.isValidUrl(this);
  bool get isImageFile => Helpers.isImageFile(this);
  bool get isVideoFile => Helpers.isVideoFile(this);
  bool get isAudioFile => Helpers.isAudioFile(this);
  bool get isValidIP => Helpers.isValidIPAddress(this);
}

extension DateTimeExtensions on DateTime {
  bool get isToday => Helpers.isToday(this);
  bool get isTomorrow => Helpers.isTomorrow(this);
  bool get isYesterday => Helpers.isYesterday(this);
  bool get isThisWeek => Helpers.isThisWeek(this);
  bool get isThisMonth => Helpers.isThisMonth(this);
  bool get isThisYear => Helpers.isThisYear(this);
  
  DateTime get startOfDay => Helpers.startOfDay(this);
  DateTime get endOfDay => Helpers.endOfDay(this);
  DateTime get startOfWeek => Helpers.startOfWeek(this);
  DateTime get endOfWeek => Helpers.endOfWeek(this);
  DateTime get startOfMonth => Helpers.startOfMonth(this);
  DateTime get endOfMonth => Helpers.endOfMonth(this);
  
  List<DateTime> get daysInMonth => Helpers.getDaysInMonth(this);
  List<DateTime> get weekDays => Helpers.getWeekDays(this);
}

extension DoubleExtensions on double {
  double roundToDecimals(int decimals) => Helpers.roundToDecimals(this, decimals);
  double calculateTax(double taxRate) => Helpers.calculateTax(this, taxRate);
  double calculateTotal(double taxRate) => Helpers.calculateTotal(this, taxRate);
  double calculateCommission(double commissionRate) => Helpers.calculateCommission(this, commissionRate);
  double calculateDiscount(double discountRate) => Helpers.calculateDiscount(this, discountRate);
  double applyDiscount(double discountRate) => Helpers.applyDiscount(this, discountRate);
}