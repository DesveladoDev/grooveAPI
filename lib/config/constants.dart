/// Clase que contiene todas las constantes de la aplicación.
/// 
/// Esta clase centraliza todos los valores constantes utilizados en la aplicación,
/// incluyendo configuración de API, Firebase, Stripe, límites de archivos,
/// configuraciones de paginación, y otros valores que no deben cambiar
/// durante la ejecución de la aplicación.
/// 
/// Todas las constantes están organizadas por categorías para facilitar
/// su localización y mantenimiento.
class AppConstants {
  // ========================================
  // INFORMACIÓN DE LA APLICACIÓN
  // ========================================
  static const String appName = 'Salas & Beats';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Plataforma de alquiler de salas de ensayo y estudios musicales';
  
  // ========================================
  // CONFIGURACIÓN DE API
  // ========================================
  static const String baseUrl = 'https://api.salasandbeats.com';
  static const String apiVersion = 'v1';
  static const String apiUrl = '$baseUrl/$apiVersion';
  
  // ========================================
  // CONFIGURACIÓN DE FIREBASE
  // ========================================
  static const String firebaseProjectId = 'salas-beats-app';
  static const String firebaseStorageBucket = 'salas-beats-app.appspot.com';
  
  // ========================================
  // CONFIGURACIÓN DE STRIPE
  // ========================================
  static const String stripePublishableKey = 'pk_test_...';
  static const String stripeMerchantId = 'merchant.com.salasandbeats';
  
  // ========================================
  // COMISIONES Y PRECIOS
  // ========================================
  static const double platformCommissionRate = 0.15; // 15%
  static const double minimumBookingAmount = 10;
  static const double maximumBookingAmount = 10000;
  static const int minimumBookingDuration = 1; // hours
  static const int maximumBookingDuration = 24; // hours
  static const int advanceBookingDays = 90; // days
  
  // ========================================
  // PAGINACIÓN
  // ========================================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // ========================================
  // CARGA DE ARCHIVOS
  // ========================================
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];
  static const List<String> allowedDocumentFormats = ['pdf', 'doc', 'docx'];
  
  // ========================================
  // DIMENSIONES DE IMÁGENES
  // ========================================
  static const int listingImageWidth = 800;
  static const int listingImageHeight = 600;
  static const int thumbnailWidth = 300;
  static const int thumbnailHeight = 200;
  static const int profileImageSize = 400;
  
  // ========================================
  // DURACIÓN DE CACHÉ
  // ========================================
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);
  static const Duration locationTimeout = Duration(seconds: 10);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 500;
  static const int maxListingTitleLength = 100;
  static const int maxListingDescriptionLength = 2000;
  static const int maxReviewLength = 1000;
  static const int maxMessageLength = 1000;
  
  // Rating
  static const double minRating = 1;
  static const double maxRating = 5;
  static const int minReviewsForAverage = 3;
  
  // Search
  static const int maxSearchRadius = 50; // km
  static const int defaultSearchRadius = 10; // km
  static const int maxSearchResults = 100;
  static const int searchHistoryLimit = 10;
  
  // Notifications
  static const int maxNotificationHistory = 100;
  static const Duration notificationRetention = Duration(days: 30);
  
  // Booking
  static const int maxGuestsPerBooking = 50;
  static const int defaultBookingDuration = 2; // hours
  static const Duration cancellationWindow = Duration(hours: 24);
  static const Duration refundProcessingTime = Duration(days: 7);
  
  // Host Requirements
  static const int minHostAge = 18;
  static const int minListingImages = 3;
  static const int maxListingImages = 20;
  static const double minListingPrice = 5;
  static const double maxListingPrice = 1000;
  
  // Chat
  static const int maxChatHistory = 1000;
  static const Duration messageDeliveryTimeout = Duration(seconds: 30);
  static const int maxChatParticipants = 2; // Host and Guest only
  
  // Location
  static const double defaultLatitude = 40.7128; // New York
  static const double defaultLongitude = -74.0060;
  static const double locationAccuracyThreshold = 100; // meters
  
  // Error Messages
  static const String genericErrorMessage = 'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';
  static const String networkErrorMessage = 'Error de conexión. Verifica tu conexión a internet.';
  static const String authErrorMessage = 'Error de autenticación. Por favor, inicia sesión nuevamente.';
  static const String permissionErrorMessage = 'No tienes permisos para realizar esta acción.';
  static const String notFoundErrorMessage = 'El recurso solicitado no fue encontrado.';
  
  // Success Messages
  static const String bookingCreatedMessage = '¡Reserva creada exitosamente!';
  static const String bookingCancelledMessage = 'Reserva cancelada correctamente.';
  static const String profileUpdatedMessage = 'Perfil actualizado exitosamente.';
  static const String listingCreatedMessage = '¡Sala publicada exitosamente!';
  static const String listingUpdatedMessage = 'Sala actualizada correctamente.';
  static const String paymentSuccessMessage = '¡Pago procesado exitosamente!';
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$';
  static const String phonePattern = r'^[+]?[0-9]{10,15}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,30}$';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';
  
  // Currency
  static const String defaultCurrency = 'EUR';
  static const String currencySymbol = '€';
  static const List<String> supportedCurrencies = ['EUR', 'USD', 'GBP'];
  
  // Languages
  static const String defaultLanguage = 'es';
  static const List<String> supportedLanguages = ['es', 'en', 'fr', 'de'];
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/salasandbeats';
  static const String twitterUrl = 'https://twitter.com/salasandbeats';
  static const String instagramUrl = 'https://instagram.com/salasandbeats';
  static const String youtubeUrl = 'https://youtube.com/salasandbeats';
  
  // Legal
  static const String termsOfServiceUrl = 'https://salasandbeats.com/terms';
  static const String privacyPolicyUrl = 'https://salasandbeats.com/privacy';
  static const String cookiePolicyUrl = 'https://salasandbeats.com/cookies';
  
  // Support
  static const String supportEmail = 'support@salasandbeats.com';
  static const String supportPhone = '+34 900 123 456';
  static const String helpCenterUrl = 'https://help.salasandbeats.com';
  
  // App Store
  static const String appStoreUrl = 'https://apps.apple.com/app/salas-beats';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.salasandbeats.app';
  
  // Deep Links
  static const String deepLinkScheme = 'salasbeats';
  static const String universalLinkDomain = 'salasandbeats.com';
  
  // Analytics
  static const String googleAnalyticsId = 'GA_MEASUREMENT_ID';
  static const String firebaseAnalyticsEnabled = 'true';
  
  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableLocationServices = true;
  static const bool enableChatFeature = true;
  static const bool enableVideoCall = false;
  static const bool enableSocialLogin = true;
  static const bool enableBiometricAuth = true;
  static const bool enableDarkMode = true;
  static const bool enableOfflineMode = false;
  
  // Environment
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  static const bool isProduction = environment == 'production';
  static const bool isDevelopment = environment == 'development';
  static const bool isStaging = environment == 'staging';
  
  // Debug
  static const bool enableDebugMode = !isProduction;
  static const bool enableLogging = true;
  static const bool enableCrashReporting = isProduction;
  
  // ========================================
  // UI SPACING AND DIMENSIONS
  // ========================================
  static const double smallSpacing = 8;
  static const double defaultSpacing = 16;
  static const double largeSpacing = 24;
  static const double extraLargeSpacing = 32;
  
  // Border Radius
  static const double smallBorderRadius = 4;
  static const double defaultBorderRadius = 8;
  static const double largeBorderRadius = 12;
  
  // Icon Sizes
  static const double smallIconSize = 16;
  static const double defaultIconSize = 24;
  static const double largeIconSize = 32;
  
  // Button Heights
  static const double buttonHeight = 48;
  static const double smallButtonHeight = 36;
  static const double largeButtonHeight = 56;
}

// Equipment types for music studios
class EquipmentTypes {
  static const List<String> audioEquipment = [
    'Micrófono de condensador',
    'Micrófono dinámico',
    'Interfaz de audio',
    'Monitores de estudio',
    'Auriculares profesionales',
    'Mesa de mezclas',
    'Preamplificadores',
    'Compresores',
    'Ecualizadores',
    'Reverb/Delay',
  ];
  
  static const List<String> instruments = [
    'Piano acústico',
    'Piano eléctrico',
    'Teclado/Sintetizador',
    'Guitarra eléctrica',
    'Guitarra acústica',
    'Bajo eléctrico',
    'Batería acústica',
    'Batería electrónica',
    'Percusión',
    'Amplificadores',
  ];
  
  static const List<String> recordingEquipment = [
    'DAW (Software)',
    'Plugins profesionales',
    'Controladores MIDI',
    'Monitores de referencia',
    'Tratamiento acústico',
    'Cabina de grabación',
    'Patchbay',
    'Cables profesionales',
    'Soportes y atriles',
    'Iluminación profesional',
  ];
}

// Room types for music venues
class RoomTypes {
  static const List<String> studioTypes = [
    'Sala de ensayo',
    'Estudio de grabación',
    'Sala de mezcla',
    'Sala de masterización',
    'Estudio de podcast',
    'Sala de producción',
    'Sala de composición',
    'Estudio de doblaje',
    'Sala de conferencias musicales',
    'Espacio multifuncional',
  ];
  
  static const List<String> venueTypes = [
    'Sala de conciertos',
    'Club nocturno',
    'Bar con música en vivo',
    'Teatro musical',
    'Auditorio',
    'Sala de eventos',
    'Estudio de baile',
    'Sala de karaoke',
    'Espacio al aire libre',
    'Venue privado',
  ];
}

// Music genres
class MusicGenres {
  static const List<String> genres = [
    'Rock',
    'Pop',
    'Jazz',
    'Blues',
    'Classical',
    'Electronic',
    'Hip Hop',
    'R&B',
    'Country',
    'Folk',
    'Reggae',
    'Punk',
    'Metal',
    'Indie',
    'Alternative',
    'Funk',
    'Soul',
    'Gospel',
    'Latin',
    'World Music',
  ];
  
  // ========================================
  // MENSAJES DE ERROR
  // ========================================
  static const String defaultErrorMessage = 'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';
}