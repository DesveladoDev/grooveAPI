class AppConstants {
  // App Information
  static const String appName = 'Salas & Beats';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Salas & Beats';
  static const String appDescription = 'Tu espacio musical - Encuentra y reserva salas de ensayo, estudios de grabación y espacios para eventos musicales';
  
  // API Configuration
  static const String baseUrl = 'https://api.salasandbeats.com';
  static const String apiVersion = 'v1';
  static const String apiUrl = '$baseUrl/api/$apiVersion';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'salas-beats';
  static const String firebaseStorageBucket = 'salas-beats.appspot.com';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const int maxAudioSizeMB = 50;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];
  static const List<String> allowedAudioFormats = ['mp3', 'wav', 'aac', 'm4a'];
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 500;
  static const int maxListingTitleLength = 100;
  static const int maxListingDescriptionLength = 2000;
  
  // Booking
  static const int minBookingHours = 1;
  static const int maxBookingHours = 24;
  static const int maxAdvanceBookingDays = 90;
  static const int minCancellationHours = 24;
  
  // Payment
  static const double platformFeePercentage = 0.05; // 5%
  static const double minBookingAmount = 10;
  static const double maxBookingAmount = 10000;
  
  // Chat
  static const int maxMessageLength = 1000;
  static const int maxChatImageSizeMB = 5;
  static const int chatHistoryDays = 30;
  
  // Notifications
  static const int maxNotificationHistory = 100;
  static const int notificationRetentionDays = 30;
  
  // Cache
  static const int imageCacheDays = 7;
  static const int dataCacheHours = 1;
  
  // Map
  static const double defaultLatitude = 40.4168; // Madrid
  static const double defaultLongitude = -3.7038;
  static const double defaultZoom = 12;
  static const double maxSearchRadius = 50; // km
  
  // Rating
  static const double minRating = 1;
  static const double maxRating = 5;
  
  // Social
  static const List<String> supportedSocialPlatforms = [
    'instagram',
    'facebook',
    'twitter',
    'youtube',
    'spotify',
    'soundcloud',
  ];
  
  // Categories
  static const List<String> listingCategories = [
    'studio',
    'rehearsal',
    'event',
    'recording',
    'live',
    'podcast',
  ];
  
  static const Map<String, String> categoryNames = {
    'studio': 'Estudio de Grabación',
    'rehearsal': 'Sala de Ensayo',
    'event': 'Espacio para Eventos',
    'recording': 'Estudio de Grabación',
    'live': 'Espacio para Conciertos',
    'podcast': 'Estudio de Podcast',
  };
  
  // Equipment Types
  static const List<String> equipmentTypes = [
    'microphones',
    'instruments',
    'amplifiers',
    'mixing_console',
    'monitors',
    'recording_equipment',
    'lighting',
    'sound_system',
  ];
  
  static const Map<String, String> equipmentNames = {
    'microphones': 'Micrófonos',
    'instruments': 'Instrumentos',
    'amplifiers': 'Amplificadores',
    'mixing_console': 'Mesa de Mezclas',
    'monitors': 'Monitores',
    'recording_equipment': 'Equipo de Grabación',
    'lighting': 'Iluminación',
    'sound_system': 'Sistema de Sonido',
  };
  
  // User Roles
  static const List<String> userRoles = [
    'musician',
    'host',
    'admin',
  ];
  
  static const Map<String, String> roleNames = {
    'musician': 'Músico',
    'host': 'Anfitrión',
    'admin': 'Administrador',
  };
  
  // Booking Status
  static const List<String> bookingStatuses = [
    'pending',
    'confirmed',
    'cancelled',
    'completed',
    'no_show',
  ];
  
  static const Map<String, String> bookingStatusNames = {
    'pending': 'Pendiente',
    'confirmed': 'Confirmada',
    'cancelled': 'Cancelada',
    'completed': 'Completada',
    'no_show': 'No se presentó',
  };
  
  // Listing Status
  static const List<String> listingStatuses = [
    'draft',
    'pending',
    'active',
    'suspended',
    'rejected',
  ];
  
  static const Map<String, String> listingStatusNames = {
    'draft': 'Borrador',
    'pending': 'Pendiente',
    'active': 'Activo',
    'suspended': 'Suspendido',
    'rejected': 'Rechazado',
  };
  
  // Time Slots
  static const List<String> timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
  ];
  
  // Contact Information
  static const String supportEmail = 'soporte@salasandbeats.com';
  static const String businessEmail = 'contacto@salasandbeats.com';
  static const String supportPhone = '+34 900 123 456';
  
  // Legal
  static const String privacyPolicyUrl = 'https://salasandbeats.com/privacy';
  static const String termsOfServiceUrl = 'https://salasandbeats.com/terms';
  static const String cookiePolicyUrl = 'https://salasandbeats.com/cookies';
  
  // Social Media
  static const String instagramUrl = 'https://instagram.com/salasandbeats';
  static const String facebookUrl = 'https://facebook.com/salasandbeats';
  static const String twitterUrl = 'https://twitter.com/salasandbeats';
  static const String youtubeUrl = 'https://youtube.com/salasandbeats';
  
  // App Store
  static const String appStoreUrl = 'https://apps.apple.com/app/salas-beats';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.salasandbeats.app';
  
  // Deep Links
  static const String deepLinkScheme = 'salasbeats';
  static const String webUrl = 'https://salasandbeats.com';
  
  // Error Messages
  static const String genericErrorMessage = 'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';
  static const String networkErrorMessage = 'Error de conexión. Verifica tu conexión a internet.';
  static const String authErrorMessage = 'Error de autenticación. Por favor, inicia sesión de nuevo.';
  static const String permissionErrorMessage = 'No tienes permisos para realizar esta acción.';
  
  // Success Messages
  static const String bookingCreatedMessage = 'Reserva creada exitosamente';
  static const String bookingCancelledMessage = 'Reserva cancelada exitosamente';
  static const String profileUpdatedMessage = 'Perfil actualizado exitosamente';
  static const String listingCreatedMessage = 'Listado creado exitosamente';
  
  // Feature Flags
  static const bool enableChatFeature = true;
  static const bool enableVideoCallFeature = false;
  static const bool enablePaymentFeature = true;
  static const bool enableReviewsFeature = true;
  static const bool enableNotificationsFeature = true;
  static const bool enableAnalyticsFeature = true;
  
  // Development
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableCrashReporting = true;
  
  // Utility Methods
  static String getApiEndpoint(String endpoint) => '$apiUrl/$endpoint';
  
  static String getCategoryName(String category) => categoryNames[category] ?? category;
  
  static String getEquipmentName(String equipment) => equipmentNames[equipment] ?? equipment;
  
  static String getRoleName(String role) => roleNames[role] ?? role;
  
  static String getBookingStatusName(String status) => bookingStatusNames[status] ?? status;
  
  static String getListingStatusName(String status) => listingStatusNames[status] ?? status;
  
  static bool isValidImageFormat(String extension) => allowedImageFormats.contains(extension.toLowerCase());
  
  static bool isValidVideoFormat(String extension) => allowedVideoFormats.contains(extension.toLowerCase());
  
  static bool isValidAudioFormat(String extension) => allowedAudioFormats.contains(extension.toLowerCase());
  
  static bool isValidRole(String role) => userRoles.contains(role);
  
  static bool isValidCategory(String category) => listingCategories.contains(category);
  
  static bool isValidBookingStatus(String status) => bookingStatuses.contains(status);
  
  static bool isValidListingStatus(String status) => listingStatuses.contains(status);
}