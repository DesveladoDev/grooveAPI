/// Constants used throughout the application
/// This file centralizes all hardcoded values to improve maintainability
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // UI Constants
  static const double defaultBorderRadius = 12;
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;
  static const double defaultIconSize = 20;
  static const double smallIconSize = 14;
  static const double largeIconSize = 32;
  static const double avatarRadius = 20;
  static const double notificationBadgeSize = 8;

  // Text Sizes
  static const double headlineTextSize = 24;
  static const double bodyTextSize = 16;
  static const double captionTextSize = 12;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxCommentLength = 500;
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int maxBookingDurationHours = 24;
  static const int defaultSearchLimit = 20;

  // Business Logic Constants
  static const double defaultTaxRate = 0.16; // 16% IVA in Mexico
  static const double defaultServiceFeeRate = 0.05; // 5% service fee
  static const double defaultRating = 4.8;
  static const int defaultCapacity = 4;

  // Error Messages
  static const String genericErrorMessage = 'Ha ocurrido un error inesperado';
  static const String networkErrorMessage = 'Error de conexión. Verifica tu internet';
  static const String authErrorMessage = 'Error de autenticación';
  static const String validationErrorMessage = 'Por favor verifica los datos ingresados';

  // Success Messages
  static const String bookingSuccessMessage = 'Reserva creada exitosamente';
  static const String profileUpdateSuccessMessage = 'Perfil actualizado correctamente';
  static const String reviewSubmittedMessage = 'Reseña enviada exitosamente';

  // Default Values
  static const String defaultCurrency = 'MXN';
  static const String defaultCountryCode = 'MX';
  static const String defaultLanguage = 'es';
  static const String defaultTimeZone = 'America/Mexico_City';

  // File Upload Constants
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Cache Duration
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // Mock Data (for development)
  static const List<String> mockAmenities = [
    'Micrófono profesional',
    'Piano acústico',
    'Batería completa',
    'Amplificador',
    'WiFi gratuito',
    'Estacionamiento',
    'Aire acondicionado',
    'Café gratis',
    'Monitores de estudio',
    'Cabina de grabación',
  ];

  static const List<String> mockCities = [
    'Ciudad de México',
    'Guadalajara',
    'Monterrey',
    'Puebla',
    'Tijuana',
  ];

  // Category Rating Labels
  static const Map<String, String> categoryRatingLabels = {
    'cleanliness': 'Limpieza',
    'equipment': 'Equipamiento',
    'location': 'Ubicación',
    'value': 'Relación calidad-precio',
    'communication': 'Comunicación',
    'acoustics': 'Acústica',
  };

  // Cancellation Policies
  static const Map<String, String> cancellationPolicies = {
    'flexible': 'Flexible',
    'moderate': 'Moderada',
    'strict': 'Estricta',
  };

  // User Roles
  static const String userRole = 'user';
  static const String hostRole = 'host';
  static const String adminRole = 'admin';

  // Booking Status
  static const String pendingStatus = 'pending';
  static const String confirmedStatus = 'confirmed';
  static const String cancelledStatus = 'cancelled';
  static const String completedStatus = 'completed';

  // Payment Status
  static const String paymentPendingStatus = 'pending';
  static const String paymentSuccessStatus = 'succeeded';
  static const String paymentFailedStatus = 'failed';
  static const String paymentRefundedStatus = 'refunded';
}