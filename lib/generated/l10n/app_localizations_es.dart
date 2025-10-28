// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Salas & Beats';

  @override
  String get appDescription =>
      'Marketplace para rentar salas de ensayo y estudios de grabación';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get welcomeMessage => 'Encuentra el espacio perfecto para tu música';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Regístrate';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signInWithApple => 'Iniciar sesión con Apple';

  @override
  String get home => 'Inicio';

  @override
  String get search => 'Buscar';

  @override
  String get bookings => 'Reservas';

  @override
  String get profile => 'Perfil';

  @override
  String get searchStudios => 'Buscar estudios...';

  @override
  String get nearbyStudios => 'Estudios Cercanos';

  @override
  String get popularStudios => 'Estudios Populares';

  @override
  String get recentlyViewed => 'Vistos Recientemente';

  @override
  String get filters => 'Filtros';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get price => 'Precio';

  @override
  String get rating => 'Calificación';

  @override
  String get distance => 'Distancia';

  @override
  String get availability => 'Disponibilidad';

  @override
  String get studioType => 'Tipo de Estudio';

  @override
  String get rehearsalRoom => 'Sala de Ensayo';

  @override
  String get recordingStudio => 'Estudio de Grabación';

  @override
  String get liveRoom => 'Sala en Vivo';

  @override
  String pricePerHour(int price) {
    return '\$$price/hora';
  }

  @override
  String priceRange(String min, String max) {
    return '$min - $max';
  }

  @override
  String get viewDetails => 'Ver Detalles';

  @override
  String get bookNow => 'Reservar Ahora';

  @override
  String get selectDate => 'Seleccionar Fecha';

  @override
  String get selectTime => 'Seleccionar Hora';

  @override
  String get duration => 'Duración';

  @override
  String get hours => 'horas';

  @override
  String get minutes => 'minutos';

  @override
  String get totalPrice => 'Precio Total';

  @override
  String get confirmBooking => 'Confirmar Reserva';

  @override
  String get paymentMethod => 'Método de Pago';

  @override
  String get creditCard => 'Tarjeta de Crédito';

  @override
  String get paypal => 'PayPal';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get payNow => 'Pagar Ahora';

  @override
  String get bookingConfirmed => 'Reserva Confirmada';

  @override
  String get bookingDetails => 'Detalles de la Reserva';

  @override
  String get bookingId => 'ID de Reserva';

  @override
  String get studioName => 'Nombre del Estudio';

  @override
  String get date => 'Fecha';

  @override
  String get time => 'Hora';

  @override
  String get location => 'Ubicación';

  @override
  String get contact => 'Contacto';

  @override
  String get directions => 'Direcciones';

  @override
  String get callStudio => 'Llamar al Estudio';

  @override
  String get messageStudio => 'Enviar Mensaje';

  @override
  String get cancelBooking => 'Cancelar Reserva';

  @override
  String get modifyBooking => 'Modificar Reserva';

  @override
  String get upcomingBookings => 'Próximas Reservas';

  @override
  String get pastBookings => 'Reservas Anteriores';

  @override
  String get noBookings => 'No tienes reservas';

  @override
  String get exploreStudios => 'Explorar Estudios';

  @override
  String get rateExperience => 'Calificar Experiencia';

  @override
  String get writeReview => 'Escribir Reseña';

  @override
  String get submitReview => 'Enviar Reseña';

  @override
  String get reviews => 'Reseñas';

  @override
  String get photos => 'Fotos';

  @override
  String get amenities => 'Amenidades';

  @override
  String get equipment => 'Equipamiento';

  @override
  String get rules => 'Reglas';

  @override
  String get cancellationPolicy => 'Política de Cancelación';

  @override
  String get settings => 'Configuración';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get languageUpdated => 'Idioma actualizado';

  @override
  String get welcomeBack => 'Bienvenido de vuelta';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get emailHint => 'tu@email.com';

  @override
  String get passwordHint => 'Tu contraseña';

  @override
  String get enterEmail => 'Ingresa tu correo electrónico';

  @override
  String get enterValidEmail => 'Ingresa un correo válido';

  @override
  String get enterPassword => 'Ingresa tu contraseña';

  @override
  String passwordMinLength(int minLength) {
    return 'La contraseña debe tener al menos $minLength caracteres';
  }

  @override
  String get completeAllFields => 'Completa todos los campos correctamente';

  @override
  String get signIn => 'Inicia sesión';

  @override
  String get completeForm => 'Completa el formulario';

  @override
  String get or => 'O';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get createUserDocument => 'Crear Documento Usuario (Temporal)';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get signInError => 'Error al iniciar sesión';

  @override
  String get unexpectedError => 'Error inesperado. Inténtalo de nuevo.';

  @override
  String get googleSignInError => 'Error al iniciar sesión con Google';

  @override
  String get appleSignInError => 'Error al iniciar sesión con Apple';

  @override
  String get userDocumentCreated => 'Documento de usuario creado exitosamente';

  @override
  String createDocumentError(String error) {
    return 'Error al crear documento: $error';
  }

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get joinMusicalCommunity => 'Únete a la comunidad musical';

  @override
  String get accountType => 'Tipo de cuenta';

  @override
  String get musician => 'Músico';

  @override
  String get searchAndBookRooms => 'Busca y reserva salas';

  @override
  String get host => 'Anfitrión';

  @override
  String get rentYourSpace => 'Renta tu espacio';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get enterName => 'Ingresa tu nombre';

  @override
  String get nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get phoneOptional => 'Teléfono (opcional)';

  @override
  String get phoneHint => '+52 55 1234 5678';

  @override
  String get enterValidPhone => 'Ingresa un teléfono válido';

  @override
  String passwordMinLengthHint(int length) {
    return 'Mínimo $length caracteres';
  }

  @override
  String passwordHelperText(int length) {
    return 'Debe tener al menos $length caracteres';
  }

  @override
  String passwordMinLengthError(int length) {
    return 'La contraseña debe tener al menos $length caracteres';
  }

  @override
  String get repeatPassword => 'Repite tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get confirmYourPassword => 'Confirma tu contraseña';

  @override
  String get acceptTerms => 'Acepto los ';

  @override
  String get termsAndConditions => 'términos y condiciones';

  @override
  String get andPrivacyPolicy => ' y política de privacidad';

  @override
  String get completeFollowingFields => 'Completa los siguientes campos:';

  @override
  String get validName => 'Nombre válido';

  @override
  String get validEmail => 'Email válido';

  @override
  String get securePassword => 'Contraseña segura';

  @override
  String get passwordsMatch => 'Contraseñas coinciden';

  @override
  String get termsAccepted => 'Términos aceptados';

  @override
  String get createAccountButton => 'Crear Cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get mustAcceptTerms => 'Debes aceptar los términos y condiciones';

  @override
  String get accountCreatedSuccessfully =>
      'Cuenta creada exitosamente. Verifica tu email.';

  @override
  String get unknownRegistrationError =>
      'Error desconocido durante el registro';

  @override
  String get googleRegistrationError => 'Error al registrarse con Google';

  @override
  String get termsAndConditionsTitle => 'Términos y Condiciones';

  @override
  String get termsContent =>
      'Al usar Salas & Beats, aceptas nuestros términos de servicio y política de privacidad.\n\nComo músico, puedes buscar y reservar salas de ensayo.\n\nComo anfitrión, puedes listar tu espacio y recibir pagos por las reservas.\n\nNos reservamos el derecho de suspender cuentas que violen nuestras políticas.';

  @override
  String get close => 'Cerrar';

  @override
  String get theme => 'Tema';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Oscuro';

  @override
  String get systemTheme => 'Tema del Sistema';

  @override
  String get privacy => 'Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get help => 'Ayuda';

  @override
  String get support => 'Soporte';

  @override
  String get faq => 'Preguntas Frecuentes';

  @override
  String get contactUs => 'Contáctanos';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get phoneNumber => 'Número de Teléfono';

  @override
  String get dateOfBirth => 'Fecha de Nacimiento';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get discardChanges => 'Descartar Cambios';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get share => 'Compartir';

  @override
  String get favorite => 'Favorito';

  @override
  String get unfavorite => 'Quitar de Favoritos';

  @override
  String get favorites => 'Favoritos';

  @override
  String get noFavorites => 'No tienes favoritos';

  @override
  String get addToFavorites => 'Agregar a Favoritos';

  @override
  String get removeFromFavorites => 'Quitar de Favoritos';

  @override
  String get searchResults => 'Resultados de Búsqueda';

  @override
  String get noResults => 'No se encontraron resultados';

  @override
  String get tryDifferentSearch => 'Intenta con una búsqueda diferente';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get map => 'Mapa';

  @override
  String get list => 'Lista';

  @override
  String get openingHours => 'Horarios de Apertura';

  @override
  String get closed => 'Cerrado';

  @override
  String get open => 'Abierto';

  @override
  String opensAt(String time) {
    return 'Abre a las $time';
  }

  @override
  String closesAt(String time) {
    return 'Cierra a las $time';
  }

  @override
  String get available => 'Disponible';

  @override
  String get unavailable => 'No Disponible';

  @override
  String get booked => 'Reservado';

  @override
  String get pending => 'Pendiente';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get completed => 'Completado';

  @override
  String get refunded => 'Reembolsado';

  @override
  String hello(String name) {
    return 'Hola, $name';
  }

  @override
  String get findPerfectSpace => 'Encuentra tu espacio musical perfecto';

  @override
  String get searchPlaceholder => 'Buscar salas, ubicación...';

  @override
  String upToCapacity(int capacity) {
    return 'Hasta $capacity personas';
  }

  @override
  String get noRoomsFound => 'No se encontraron salas';

  @override
  String get adjustFiltersMessage =>
      'Intenta ajustar tus filtros o buscar en otra ubicación';

  @override
  String get clear => 'Limpiar';

  @override
  String get city => 'Ciudad';

  @override
  String get all => 'Todas';

  @override
  String maxPricePerHour(int price) {
    return 'Precio máximo por hora: \$$price';
  }

  @override
  String get explore => 'Explorar';

  @override
  String get messages => 'Mensajes';

  @override
  String get profileCreationError => 'Error al crear perfil';

  @override
  String get profileCreationNetworkError =>
      'No se pudo crear el perfil. Verifica tu conexión a internet e intenta nuevamente.';

  @override
  String get profileCreationValidationError =>
      'Los datos del perfil no son válidos. Revisa la información ingresada.';

  @override
  String get profileCreationPermissionError =>
      'No tienes permisos para crear este perfil. Contacta al administrador.';

  @override
  String get profileCreationServerError =>
      'Error interno del servidor. Intenta nuevamente en unos minutos.';

  @override
  String get profileCreationTimeoutError =>
      'La creación del perfil tardó demasiado tiempo. Verifica tu conexión e intenta nuevamente.';

  @override
  String get profileUpdateError => 'Error al actualizar perfil';

  @override
  String get profileUpdateNetworkError =>
      'No se pudo actualizar el perfil. Verifica tu conexión a internet.';

  @override
  String get profileUpdateValidationError =>
      'Los datos ingresados no son válidos. Revisa la información.';

  @override
  String get profileUpdatePermissionError =>
      'No tienes permisos para actualizar este perfil.';

  @override
  String get profileIncompleteError =>
      'Tu perfil está incompleto. Completa todos los campos requeridos.';

  @override
  String get profileNameRequiredError =>
      'El nombre es obligatorio para crear tu perfil.';

  @override
  String get profileEmailRequiredError =>
      'El email es obligatorio para crear tu perfil.';

  @override
  String get profileRoleRequiredError =>
      'Debes seleccionar un tipo de cuenta (Músico o Anfitrión).';

  @override
  String get profileNameTooShortError =>
      'El nombre debe tener al menos 2 caracteres.';

  @override
  String get profileNameTooLongError =>
      'El nombre no puede tener más de 50 caracteres.';

  @override
  String get profileEmailInvalidError => 'El formato del email no es válido.';

  @override
  String get profilePhoneInvalidError =>
      'El formato del teléfono no es válido.';

  @override
  String get profileBioTooLongError =>
      'La biografía no puede tener más de 500 caracteres.';

  @override
  String get profileCreationSuccessMessage =>
      '¡Perfil creado exitosamente! Bienvenido a Salas & Beats.';

  @override
  String get profileUpdateSuccessMessage => 'Perfil actualizado exitosamente.';
}
