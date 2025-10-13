import 'package:intl/intl.dart';
import 'package:salas_beats/config/constants.dart';

class Formatters {
  // Date formatters
  static final DateFormat _dateFormat = DateFormat(AppConstants.dateFormat);
  static final DateFormat _timeFormat = DateFormat(AppConstants.timeFormat);
  static final DateFormat _dateTimeFormat = DateFormat(AppConstants.dateTimeFormat);
  static final DateFormat _apiDateFormat = DateFormat(AppConstants.apiDateFormat);
  static final DateFormat _apiDateTimeFormat = DateFormat(AppConstants.apiDateTimeFormat);
  
  // Currency formatter
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_ES',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );
  
  // Number formatters
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'es_ES');
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.00', 'es_ES');
  static final NumberFormat _percentFormat = NumberFormat.percentPattern('es_ES');
  
  // Date formatting methods
  static String formatDate(DateTime date) => _dateFormat.format(date);
  
  static String formatTime(DateTime time) => _timeFormat.format(time);
  
  static String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);
  
  static String formatApiDate(DateTime date) => _apiDateFormat.format(date);
  
  static String formatApiDateTime(DateTime dateTime) => _apiDateTimeFormat.format(dateTime);
  
  // Relative date formatting
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'hace 1 año' : 'hace $years años';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'hace 1 mes' : 'hace $months meses';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'hace 1 día' : 'hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? 'hace 1 hora' : 'hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? 'hace 1 minuto' : 'hace ${difference.inMinutes} minutos';
    } else {
      return 'ahora';
    }
  }
  
  // Future relative date formatting
  static String formatFutureRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'en 1 año' : 'en $years años';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'en 1 mes' : 'en $months meses';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'mañana' : 'en ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? 'en 1 hora' : 'en ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? 'en 1 minuto' : 'en ${difference.inMinutes} minutos';
    } else {
      return 'ahora';
    }
  }
  
  // Day of week formatting
  static String formatDayOfWeek(DateTime date) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[date.weekday - 1];
  }
  
  // Month formatting
  static String formatMonth(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[date.month - 1];
  }
  
  // Currency formatting methods
  static String formatCurrency(double amount) => _currencyFormat.format(amount);
  
  static String formatPrice(double price) => '${price.toStringAsFixed(2)}${AppConstants.currencySymbol}';
  
  static String formatPriceRange(double minPrice, double maxPrice) => '${formatPrice(minPrice)} - ${formatPrice(maxPrice)}';
  
  // Number formatting methods
  static String formatNumber(int number) => _numberFormat.format(number);
  
  static String formatDecimal(double number) => _decimalFormat.format(number);
  
  static String formatPercent(double value) => _percentFormat.format(value);
  
  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // Duration formatting
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else {
      return '${minutes}m';
    }
  }
  
  // Booking duration formatting
  static String formatBookingDuration(int hours) {
    if (hours == 1) {
      return '1 hora';
    } else if (hours < 24) {
      return '$hours horas';
    } else {
      final days = (hours / 24).floor();
      final remainingHours = hours % 24;
      
      if (remainingHours == 0) {
        return days == 1 ? '1 día' : '$days días';
      } else {
        return days == 1 
          ? '1 día y $remainingHours horas'
          : '$days días y $remainingHours horas';
      }
    }
  }
  
  // Distance formatting
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '${meters}m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }
  
  // Rating formatting
  static String formatRating(double rating) => rating.toStringAsFixed(1);
  
  static String formatRatingWithCount(double rating, int count) => '${formatRating(rating)} (${formatNumber(count)} reseñas)';
  
  // Phone number formatting
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 9) {
      // Spanish mobile format: XXX XX XX XX
      return '${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)}';
    } else if (digits.length == 11 && digits.startsWith('34')) {
      // Spanish international format: +34 XXX XX XX XX
      return '+34 ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)} ${digits.substring(9, 11)}';
    } else {
      return phoneNumber; // Return original if format not recognized
    }
  }
  
  // Credit card formatting
  static String formatCreditCard(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    
    return buffer.toString();
  }
  
  // Mask credit card number
  static String maskCreditCard(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return cardNumber;
    
    final lastFour = digits.substring(digits.length - 4);
    final masked = '*' * (digits.length - 4);
    
    return formatCreditCard(masked + lastFour);
  }
  
  // Address formatting
  static String formatAddress(String street, String city, String postalCode) => '$street, $city $postalCode';
  
  // Capacity formatting
  static String formatCapacity(int capacity) => capacity == 1 ? '1 persona' : '$capacity personas';
  
  // Equipment list formatting
  static String formatEquipmentList(List<String> equipment) {
    if (equipment.isEmpty) return 'Sin equipamiento';
    if (equipment.length == 1) return equipment.first;
    if (equipment.length <= 3) {
      return equipment.join(', ');
    } else {
      return '${equipment.take(3).join(', ')} y ${equipment.length - 3} más';
    }
  }
  
  // Booking status formatting
  static String formatBookingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmada';
      case 'cancelled':
        return 'Cancelada';
      case 'completed':
        return 'Completada';
      case 'in_progress':
        return 'En progreso';
      default:
        return status;
    }
  }
  
  // Payment status formatting
  static String formatPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'paid':
        return 'Pagado';
      case 'failed':
        return 'Fallido';
      case 'refunded':
        return 'Reembolsado';
      case 'partial_refund':
        return 'Reembolso parcial';
      default:
        return status;
    }
  }
  
  // Listing status formatting
  static String formatListingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Activa';
      case 'inactive':
        return 'Inactiva';
      case 'pending':
        return 'Pendiente';
      case 'suspended':
        return 'Suspendida';
      case 'draft':
        return 'Borrador';
      default:
        return status;
    }
  }
  
  // User role formatting
  static String formatUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return 'Usuario';
      case 'host':
        return 'Anfitrión';
      case 'admin':
        return 'Administrador';
      case 'moderator':
        return 'Moderador';
      default:
        return role;
    }
  }
  
  // Notification type formatting
  static String formatNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return 'Reserva';
      case 'payment':
        return 'Pago';
      case 'message':
        return 'Mensaje';
      case 'review':
        return 'Reseña';
      case 'system':
        return 'Sistema';
      case 'promotion':
        return 'Promoción';
      default:
        return type;
    }
  }
  
  // Text truncation
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
  
  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Title case formatting
  static String toTitleCase(String text) => text.split(' ').map(capitalize).join(' ');
  
  // Parse methods
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _apiDateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  static DateTime? parseApiDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return _apiDateTimeFormat.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
  
  // Clean phone number for API
  static String cleanPhoneNumber(String phoneNumber) => phoneNumber.replaceAll(RegExp(r'\D'), '');
  
  // Format time range
  static String formatTimeRange(String startTime, String endTime) => '$startTime - $endTime';
  
  // Format date range
  static String formatDateRange(DateTime startDate, DateTime endDate) {
    if (startDate.year == endDate.year && 
        startDate.month == endDate.month && 
        startDate.day == endDate.day) {
      return formatDate(startDate);
    } else {
      return '${formatDate(startDate)} - ${formatDate(endDate)}';
    }
  }
}

// Extension methods for easier formatting
extension DateTimeFormatting on DateTime {
  String get formatted => Formatters.formatDate(this);
  String get timeFormatted => Formatters.formatTime(this);
  String get dateTimeFormatted => Formatters.formatDateTime(this);
  String get relativeFormatted => Formatters.formatRelativeDate(this);
  String get futureRelativeFormatted => Formatters.formatFutureRelativeDate(this);
  String get dayOfWeek => Formatters.formatDayOfWeek(this);
  String get month => Formatters.formatMonth(this);
}

extension DoubleFormatting on double {
  String get currency => Formatters.formatCurrency(this);
  String get price => Formatters.formatPrice(this);
  String get rating => Formatters.formatRating(this);
  String get percent => Formatters.formatPercent(this);
  String get decimal => Formatters.formatDecimal(this);
  String get distance => Formatters.formatDistance(this);
}

extension IntFormatting on int {
  String get formatted => Formatters.formatNumber(this);
  String get fileSize => Formatters.formatFileSize(this);
  String get capacity => Formatters.formatCapacity(this);
  String get bookingDuration => Formatters.formatBookingDuration(this);
}

extension StringFormatting on String {
  String get capitalized => Formatters.capitalize(this);
  String get titleCase => Formatters.toTitleCase(this);
  String get phoneFormatted => Formatters.formatPhoneNumber(this);
  String get creditCardFormatted => Formatters.formatCreditCard(this);
  String get creditCardMasked => Formatters.maskCreditCard(this);
  String get phoneClean => Formatters.cleanPhoneNumber(this);
  String truncate(int maxLength, {String suffix = '...'}) => 
    Formatters.truncateText(this, maxLength, suffix: suffix);
}