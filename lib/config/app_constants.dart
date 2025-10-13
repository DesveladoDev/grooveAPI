class AppConstants {
  // Información de la aplicación
  static const String appName = 'Salas & Beats';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Plataforma de alquiler de espacios musicales';

  // URLs y endpoints
  static const String baseUrl = 'https://api.salasybeats.com';
  static const String websiteUrl = 'https://salasybeats.com';
  static const String supportEmail = 'soporte@salasybeats.com';
  static const String privacyPolicyUrl = 'https://salasybeats.com/privacy';
  static const String termsOfServiceUrl = 'https://salasybeats.com/terms';

  // Configuración de paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Configuración de archivos
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImagesPerListing = 10;
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;

  // Configuración de reservas
  static const int minBookingHours = 1;
  static const int maxBookingHours = 24;
  static const int maxAdvanceBookingDays = 90;
  static const int minAdvanceBookingHours = 2;

  // Configuración de precios
  static const double minPricePerHour = 10;
  static const double maxPricePerHour = 1000;
  static const double platformFeePercentage = 0.15; // 15%
  static const double stripeFeePercentage = 0.029; // 2.9%
  static const double stripeFeeFixed = 0.30; // $0.30

  // Configuración de calificaciones
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int minReviewLength = 10;
  static const int maxReviewLength = 500;

  // Categorías de espacios
  static const List<Map<String, String>> spaceCategories = [
    {'id': 'studio', 'name': 'Estudio de grabación'},
    {'id': 'rehearsal', 'name': 'Sala de ensayo'},
    {'id': 'live_room', 'name': 'Sala de conciertos'},
    {'id': 'podcast', 'name': 'Estudio de podcast'},
    {'id': 'mixing', 'name': 'Sala de mezcla'},
    {'id': 'mastering', 'name': 'Sala de masterización'},
    {'id': 'vocal_booth', 'name': 'Cabina vocal'},
    {'id': 'production', 'name': 'Sala de producción'},
    {'id': 'event_space', 'name': 'Espacio para eventos'},
    {'id': 'other', 'name': 'Otro'},
  ];

  // Comodidades disponibles
  static const List<Map<String, String>> amenities = [
    {'id': 'wifi', 'name': 'WiFi'},
    {'id': 'parking', 'name': 'Estacionamiento'},
    {'id': 'air_conditioning', 'name': 'Aire acondicionado'},
    {'id': 'heating', 'name': 'Calefacción'},
    {'id': 'kitchen', 'name': 'Cocina'},
    {'id': 'bathroom', 'name': 'Baño'},
    {'id': 'lounge_area', 'name': 'Área de descanso'},
    {'id': 'security', 'name': 'Seguridad 24/7'},
    {'id': 'elevator', 'name': 'Ascensor'},
    {'id': 'wheelchair_accessible', 'name': 'Acceso para sillas de ruedas'},
    {'id': 'smoking_allowed', 'name': 'Se permite fumar'},
    {'id': 'pets_allowed', 'name': 'Se permiten mascotas'},
    {'id': 'catering', 'name': 'Servicio de catering'},
    {'id': 'cleaning_service', 'name': 'Servicio de limpieza'},
  ];

  // Equipamiento disponible
  static const List<Map<String, String>> equipment = [
    // Audio
    {'id': 'microphones', 'name': 'Micrófonos'},
    {'id': 'audio_interface', 'name': 'Interfaz de audio'},
    {'id': 'mixing_console', 'name': 'Consola de mezcla'},
    {'id': 'monitors', 'name': 'Monitores de estudio'},
    {'id': 'headphones', 'name': 'Audífonos'},
    {'id': 'preamps', 'name': 'Preamplificadores'},
    {'id': 'compressors', 'name': 'Compresores'},
    {'id': 'equalizers', 'name': 'Ecualizadores'},
    {'id': 'reverb_units', 'name': 'Unidades de reverb'},
    {'id': 'di_boxes', 'name': 'Cajas directas'},
    
    // Instrumentos
    {'id': 'piano', 'name': 'Piano'},
    {'id': 'keyboard', 'name': 'Teclado'},
    {'id': 'drum_kit', 'name': 'Batería'},
    {'id': 'guitar_amps', 'name': 'Amplificadores de guitarra'},
    {'id': 'bass_amps', 'name': 'Amplificadores de bajo'},
    {'id': 'guitars', 'name': 'Guitarras'},
    {'id': 'bass_guitars', 'name': 'Bajos'},
    {'id': 'synthesizers', 'name': 'Sintetizadores'},
    
    // Tecnología
    {'id': 'daw_software', 'name': 'Software DAW'},
    {'id': 'plugins', 'name': 'Plugins'},
    {'id': 'computers', 'name': 'Computadoras'},
    {'id': 'midi_controllers', 'name': 'Controladores MIDI'},
    {'id': 'audio_cables', 'name': 'Cables de audio'},
    {'id': 'power_conditioners', 'name': 'Acondicionadores de energía'},
    
    // Acústica
    {'id': 'acoustic_treatment', 'name': 'Tratamiento acústico'},
    {'id': 'isolation_booths', 'name': 'Cabinas de aislamiento'},
    {'id': 'bass_traps', 'name': 'Trampas de graves'},
    {'id': 'diffusers', 'name': 'Difusores'},
    
    // Iluminación y video
    {'id': 'stage_lighting', 'name': 'Iluminación de escenario'},
    {'id': 'video_cameras', 'name': 'Cámaras de video'},
    {'id': 'projectors', 'name': 'Proyectores'},
    {'id': 'screens', 'name': 'Pantallas'},
  ];

  // Tipos de notificación
  static const List<Map<String, String>> notificationTypes = [
    {'id': 'booking_confirmed', 'name': 'Reserva confirmada'},
    {'id': 'booking_cancelled', 'name': 'Reserva cancelada'},
    {'id': 'booking_reminder', 'name': 'Recordatorio de reserva'},
    {'id': 'payment_received', 'name': 'Pago recibido'},
    {'id': 'payment_failed', 'name': 'Pago fallido'},
    {'id': 'new_review', 'name': 'Nueva reseña'},
    {'id': 'new_message', 'name': 'Nuevo mensaje'},
    {'id': 'listing_approved', 'name': 'Listado aprobado'},
    {'id': 'listing_rejected', 'name': 'Listado rechazado'},
    {'id': 'promotional', 'name': 'Promocional'},
    {'id': 'system_update', 'name': 'Actualización del sistema'},
  ];

  // Estados de reserva
  static const List<String> bookingStatuses = [
    'pending',
    'confirmed',
    'in_progress',
    'completed',
    'cancelled',
    'refunded',
  ];

  // Estados de pago
  static const List<String> paymentStatuses = [
    'pending',
    'processing',
    'succeeded',
    'failed',
    'cancelled',
    'refunded',
    'partially_refunded',
  ];

  // Roles de usuario
  static const List<String> userRoles = [
    'guest',
    'host',
    'admin',
    'super_admin',
  ];

  // Configuración de mapa
  static const double defaultLatitude = 19.4326; // Ciudad de México
  static const double defaultLongitude = -99.1332;
  static const double defaultZoom = 12;
  static const double searchRadius = 50; // km

  // Configuración de chat
  static const int maxMessageLength = 1000;
  static const int maxAttachmentsPerMessage = 5;
  static const List<String> allowedAttachmentTypes = ['image', 'document', 'audio'];

  // Configuración de cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration imageCacheExpiration = Duration(days: 7);

  // Configuración de animaciones
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Configuración de tema
  static const double defaultBorderRadius = 8;
  static const double largeBorderRadius = 16;
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;

  // Configuración de validación
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;

  // Patrones de validación
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^[\+]?[1-9]?[0-9]{7,15}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phoneRegex = r'^[\+]?[1-9]?[0-9]{7,15}$';
  static const String passwordRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  static const String urlRegex = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  // Mensajes de error comunes
  static const String networkErrorMessage = 'Error de conexión. Verifica tu internet.';
  static const String serverErrorMessage = 'Error del servidor. Inténtalo más tarde.';
  static const String unknownErrorMessage = 'Ocurrió un error inesperado.';
  static const String validationErrorMessage = 'Por favor, verifica los datos ingresados.';
  static const String authErrorMessage = 'Error de autenticación. Inicia sesión nuevamente.';

  // Configuración de desarrollo
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
}