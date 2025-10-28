import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('pt')
  ];

  /// Título de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Salas & Beats'**
  String get appTitle;

  /// Descripción de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Marketplace para rentar salas de ensayo y estudios de grabación'**
  String get appDescription;

  /// Mensaje de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get welcome;

  /// Mensaje de bienvenida principal
  ///
  /// In es, this message translates to:
  /// **'Encuentra el espacio perfecto para tu música'**
  String get welcomeMessage;

  /// Botón para comenzar
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get getStarted;

  /// Botón de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// Text for register button
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get register;

  /// Email field label
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// Password field label
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// Label for confirm password field
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// Forgot password link text
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// Botón para restablecer contraseña
  ///
  /// In es, this message translates to:
  /// **'Restablecer Contraseña'**
  String get resetPassword;

  /// Botón para iniciar sesión con Google
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión con Google'**
  String get signInWithGoogle;

  /// Botón para iniciar sesión con Apple
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión con Apple'**
  String get signInWithApple;

  /// Tab de inicio en navegación inferior
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// Pestaña de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// Tab de reservas en navegación inferior
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get bookings;

  /// Tab de perfil en navegación inferior
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// Placeholder para búsqueda de estudios
  ///
  /// In es, this message translates to:
  /// **'Buscar estudios...'**
  String get searchStudios;

  /// Sección de estudios cercanos
  ///
  /// In es, this message translates to:
  /// **'Estudios Cercanos'**
  String get nearbyStudios;

  /// Sección de estudios populares
  ///
  /// In es, this message translates to:
  /// **'Estudios Populares'**
  String get popularStudios;

  /// Sección de estudios vistos recientemente
  ///
  /// In es, this message translates to:
  /// **'Vistos Recientemente'**
  String get recentlyViewed;

  /// Título del modal de filtros
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filters;

  /// Opción de ordenamiento
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get sortBy;

  /// Filtro de precio
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get price;

  /// Filtro de calificación
  ///
  /// In es, this message translates to:
  /// **'Calificación'**
  String get rating;

  /// Filtro de distancia
  ///
  /// In es, this message translates to:
  /// **'Distancia'**
  String get distance;

  /// Filtro de disponibilidad
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad'**
  String get availability;

  /// Filtro de tipo de estudio
  ///
  /// In es, this message translates to:
  /// **'Tipo de Estudio'**
  String get studioType;

  /// Tipo de estudio: sala de ensayo
  ///
  /// In es, this message translates to:
  /// **'Sala de Ensayo'**
  String get rehearsalRoom;

  /// Tipo de estudio: estudio de grabación
  ///
  /// In es, this message translates to:
  /// **'Estudio de Grabación'**
  String get recordingStudio;

  /// Tipo de estudio: sala en vivo
  ///
  /// In es, this message translates to:
  /// **'Sala en Vivo'**
  String get liveRoom;

  /// Formato de precio por hora
  ///
  /// In es, this message translates to:
  /// **'\${price}/hora'**
  String pricePerHour(int price);

  /// Rango de precios
  ///
  /// In es, this message translates to:
  /// **'{min} - {max}'**
  String priceRange(String min, String max);

  /// Botón para ver detalles
  ///
  /// In es, this message translates to:
  /// **'Ver Detalles'**
  String get viewDetails;

  /// Botón para reservar
  ///
  /// In es, this message translates to:
  /// **'Reservar Ahora'**
  String get bookNow;

  /// Botón para seleccionar fecha
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Fecha'**
  String get selectDate;

  /// Botón para seleccionar hora
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Hora'**
  String get selectTime;

  /// Campo de duración
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get duration;

  /// Unidad de tiempo: horas
  ///
  /// In es, this message translates to:
  /// **'horas'**
  String get hours;

  /// Unidad de tiempo: minutos
  ///
  /// In es, this message translates to:
  /// **'minutos'**
  String get minutes;

  /// Precio total de la reserva
  ///
  /// In es, this message translates to:
  /// **'Precio Total'**
  String get totalPrice;

  /// Botón para confirmar reserva
  ///
  /// In es, this message translates to:
  /// **'Confirmar Reserva'**
  String get confirmBooking;

  /// Sección de método de pago
  ///
  /// In es, this message translates to:
  /// **'Método de Pago'**
  String get paymentMethod;

  /// Método de pago: tarjeta de crédito
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de Crédito'**
  String get creditCard;

  /// Método de pago: PayPal
  ///
  /// In es, this message translates to:
  /// **'PayPal'**
  String get paypal;

  /// Método de pago: Apple Pay
  ///
  /// In es, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// Método de pago: Google Pay
  ///
  /// In es, this message translates to:
  /// **'Google Pay'**
  String get googlePay;

  /// Botón para pagar
  ///
  /// In es, this message translates to:
  /// **'Pagar Ahora'**
  String get payNow;

  /// Mensaje de confirmación de reserva
  ///
  /// In es, this message translates to:
  /// **'Reserva Confirmada'**
  String get bookingConfirmed;

  /// Título de detalles de reserva
  ///
  /// In es, this message translates to:
  /// **'Detalles de la Reserva'**
  String get bookingDetails;

  /// ID de la reserva
  ///
  /// In es, this message translates to:
  /// **'ID de Reserva'**
  String get bookingId;

  /// Nombre del estudio
  ///
  /// In es, this message translates to:
  /// **'Nombre del Estudio'**
  String get studioName;

  /// Campo de fecha
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// Campo de hora
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get time;

  /// Campo de ubicación
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get location;

  /// Información de contacto
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get contact;

  /// Botón para obtener direcciones
  ///
  /// In es, this message translates to:
  /// **'Direcciones'**
  String get directions;

  /// Botón para llamar al estudio
  ///
  /// In es, this message translates to:
  /// **'Llamar al Estudio'**
  String get callStudio;

  /// Botón para enviar mensaje al estudio
  ///
  /// In es, this message translates to:
  /// **'Enviar Mensaje'**
  String get messageStudio;

  /// Botón para cancelar reserva
  ///
  /// In es, this message translates to:
  /// **'Cancelar Reserva'**
  String get cancelBooking;

  /// Botón para modificar reserva
  ///
  /// In es, this message translates to:
  /// **'Modificar Reserva'**
  String get modifyBooking;

  /// Sección de próximas reservas
  ///
  /// In es, this message translates to:
  /// **'Próximas Reservas'**
  String get upcomingBookings;

  /// Sección de reservas anteriores
  ///
  /// In es, this message translates to:
  /// **'Reservas Anteriores'**
  String get pastBookings;

  /// Mensaje cuando no hay reservas
  ///
  /// In es, this message translates to:
  /// **'No tienes reservas'**
  String get noBookings;

  /// Botón para explorar estudios
  ///
  /// In es, this message translates to:
  /// **'Explorar Estudios'**
  String get exploreStudios;

  /// Botón para calificar experiencia
  ///
  /// In es, this message translates to:
  /// **'Calificar Experiencia'**
  String get rateExperience;

  /// Botón para escribir reseña
  ///
  /// In es, this message translates to:
  /// **'Escribir Reseña'**
  String get writeReview;

  /// Botón para enviar reseña
  ///
  /// In es, this message translates to:
  /// **'Enviar Reseña'**
  String get submitReview;

  /// Sección de reseñas
  ///
  /// In es, this message translates to:
  /// **'Reseñas'**
  String get reviews;

  /// Sección de fotos
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get photos;

  /// Label para filtro de amenidades
  ///
  /// In es, this message translates to:
  /// **'Amenidades'**
  String get amenities;

  /// Sección de equipamiento
  ///
  /// In es, this message translates to:
  /// **'Equipamiento'**
  String get equipment;

  /// Sección de reglas del estudio
  ///
  /// In es, this message translates to:
  /// **'Reglas'**
  String get rules;

  /// Política de cancelación
  ///
  /// In es, this message translates to:
  /// **'Política de Cancelación'**
  String get cancellationPolicy;

  /// Configuración de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// Configuración de notificaciones
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// Configuración de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Title for language selection dialog
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get selectLanguage;

  /// Message shown when language is successfully changed
  ///
  /// In es, this message translates to:
  /// **'Idioma actualizado'**
  String get languageUpdated;

  /// Welcome back title on login screen
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de vuelta'**
  String get welcomeBack;

  /// Subtitle on login screen
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para continuar'**
  String get signInToContinue;

  /// Email field hint text
  ///
  /// In es, this message translates to:
  /// **'tu@email.com'**
  String get emailHint;

  /// Password field hint text
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña'**
  String get passwordHint;

  /// Email validation error message
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electrónico'**
  String get enterEmail;

  /// Invalid email format error message
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get enterValidEmail;

  /// Password validation error message
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get enterPassword;

  /// Password minimum length error message
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {minLength} caracteres'**
  String passwordMinLength(int minLength);

  /// Form validation message
  ///
  /// In es, this message translates to:
  /// **'Completa todos los campos correctamente'**
  String get completeAllFields;

  /// Sign in link text
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get signIn;

  /// Text for disabled create account button
  ///
  /// In es, this message translates to:
  /// **'Completa el formulario'**
  String get completeForm;

  /// Divider text between login methods
  ///
  /// In es, this message translates to:
  /// **'O'**
  String get or;

  /// Text for Google registration button
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// Apple sign in button text
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get continueWithApple;

  /// Text for create user document button
  ///
  /// In es, this message translates to:
  /// **'Crear Documento Usuario (Temporal)'**
  String get createUserDocument;

  /// Text asking if user doesn't have an account
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get noAccount;

  /// Error message for sign in failure
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get signInError;

  /// Error message for unexpected errors
  ///
  /// In es, this message translates to:
  /// **'Error inesperado. Inténtalo de nuevo.'**
  String get unexpectedError;

  /// Error message for Google sign in failure
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión con Google'**
  String get googleSignInError;

  /// Error message for Apple sign in failure
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión con Apple'**
  String get appleSignInError;

  /// Success message for user document creation
  ///
  /// In es, this message translates to:
  /// **'Documento de usuario creado exitosamente'**
  String get userDocumentCreated;

  /// Error message for document creation failure
  ///
  /// In es, this message translates to:
  /// **'Error al crear documento: {error}'**
  String createDocumentError(String error);

  /// Title for create account screen
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// Subtitle for create account screen
  ///
  /// In es, this message translates to:
  /// **'Únete a la comunidad musical'**
  String get joinMusicalCommunity;

  /// Label for account type selector
  ///
  /// In es, this message translates to:
  /// **'Tipo de cuenta'**
  String get accountType;

  /// Musician account type
  ///
  /// In es, this message translates to:
  /// **'Músico'**
  String get musician;

  /// Description for musician account type
  ///
  /// In es, this message translates to:
  /// **'Busca y reserva salas'**
  String get searchAndBookRooms;

  /// Host account type
  ///
  /// In es, this message translates to:
  /// **'Anfitrión'**
  String get host;

  /// Description for host account type
  ///
  /// In es, this message translates to:
  /// **'Renta tu espacio'**
  String get rentYourSpace;

  /// Label for full name field
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// Hint for name field
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get yourName;

  /// Validation message for empty name
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get enterName;

  /// Validation message for name minimum length
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 2 caracteres'**
  String get nameMinLength;

  /// Label for email field
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailAddress;

  /// Label for optional phone field
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get phoneOptional;

  /// Hint for phone field
  ///
  /// In es, this message translates to:
  /// **'+52 55 1234 5678'**
  String get phoneHint;

  /// Validation message for invalid phone
  ///
  /// In es, this message translates to:
  /// **'Ingresa un teléfono válido'**
  String get enterValidPhone;

  /// Hint for password minimum length
  ///
  /// In es, this message translates to:
  /// **'Mínimo {length} caracteres'**
  String passwordMinLengthHint(int length);

  /// Helper text for password requirements
  ///
  /// In es, this message translates to:
  /// **'Debe tener al menos {length} caracteres'**
  String passwordHelperText(int length);

  /// Mensaje de error para contraseña muy corta
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {length} caracteres'**
  String passwordMinLengthError(int length);

  /// Hint for confirm password field
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get repeatPassword;

  /// Validation message when passwords don't match
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// Validation message for empty confirm password
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get confirmYourPassword;

  /// Text before terms and conditions link
  ///
  /// In es, this message translates to:
  /// **'Acepto los '**
  String get acceptTerms;

  /// Terms and conditions link text
  ///
  /// In es, this message translates to:
  /// **'términos y condiciones'**
  String get termsAndConditions;

  /// Text after terms and conditions link
  ///
  /// In es, this message translates to:
  /// **' y política de privacidad'**
  String get andPrivacyPolicy;

  /// Text for validation checklist header
  ///
  /// In es, this message translates to:
  /// **'Completa los siguientes campos:'**
  String get completeFollowingFields;

  /// Validation checklist item for name
  ///
  /// In es, this message translates to:
  /// **'Nombre válido'**
  String get validName;

  /// Validation checklist item for email
  ///
  /// In es, this message translates to:
  /// **'Email válido'**
  String get validEmail;

  /// Validation checklist item for password
  ///
  /// In es, this message translates to:
  /// **'Contraseña segura'**
  String get securePassword;

  /// Validation checklist item for password confirmation
  ///
  /// In es, this message translates to:
  /// **'Contraseñas coinciden'**
  String get passwordsMatch;

  /// Validation checklist item for terms acceptance
  ///
  /// In es, this message translates to:
  /// **'Términos aceptados'**
  String get termsAccepted;

  /// Text for create account button
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get createAccountButton;

  /// Text before sign in link
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get alreadyHaveAccount;

  /// Error message when terms are not accepted
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos y condiciones'**
  String get mustAcceptTerms;

  /// Success message for account creation
  ///
  /// In es, this message translates to:
  /// **'Cuenta creada exitosamente. Verifica tu email.'**
  String get accountCreatedSuccessfully;

  /// Generic registration error message
  ///
  /// In es, this message translates to:
  /// **'Error desconocido durante el registro'**
  String get unknownRegistrationError;

  /// Error message for Google registration failure
  ///
  /// In es, this message translates to:
  /// **'Error al registrarse con Google'**
  String get googleRegistrationError;

  /// Title for terms and conditions dialog
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsAndConditionsTitle;

  /// Content for terms and conditions dialog
  ///
  /// In es, this message translates to:
  /// **'Al usar Salas & Beats, aceptas nuestros términos de servicio y política de privacidad.\n\nComo músico, puedes buscar y reservar salas de ensayo.\n\nComo anfitrión, puedes listar tu espacio y recibir pagos por las reservas.\n\nNos reservamos el derecho de suspender cuentas que violen nuestras políticas.'**
  String get termsContent;

  /// Close button text
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// Configuración de tema
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// Tema claro
  ///
  /// In es, this message translates to:
  /// **'Tema Claro'**
  String get lightTheme;

  /// Tema oscuro
  ///
  /// In es, this message translates to:
  /// **'Tema Oscuro'**
  String get darkTheme;

  /// Tema del sistema
  ///
  /// In es, this message translates to:
  /// **'Tema del Sistema'**
  String get systemTheme;

  /// Configuración de privacidad
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get privacy;

  /// Términos de servicio
  ///
  /// In es, this message translates to:
  /// **'Términos de Servicio'**
  String get termsOfService;

  /// Política de privacidad
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyPolicy;

  /// Sección de ayuda
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get help;

  /// Soporte técnico
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get support;

  /// Preguntas frecuentes
  ///
  /// In es, this message translates to:
  /// **'Preguntas Frecuentes'**
  String get faq;

  /// Contactar soporte
  ///
  /// In es, this message translates to:
  /// **'Contáctanos'**
  String get contactUs;

  /// Botón para cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// Botón para eliminar cuenta
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get deleteAccount;

  /// Botón para editar perfil
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get editProfile;

  /// Campo de nombre
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get firstName;

  /// Campo de apellido
  ///
  /// In es, this message translates to:
  /// **'Apellido'**
  String get lastName;

  /// Campo de número de teléfono
  ///
  /// In es, this message translates to:
  /// **'Número de Teléfono'**
  String get phoneNumber;

  /// Campo de fecha de nacimiento
  ///
  /// In es, this message translates to:
  /// **'Fecha de Nacimiento'**
  String get dateOfBirth;

  /// Botón para guardar cambios
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get saveChanges;

  /// Botón para descartar cambios
  ///
  /// In es, this message translates to:
  /// **'Descartar Cambios'**
  String get discardChanges;

  /// Mensaje de carga
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// Mensaje de error genérico
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// Botón para reintentar
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Botón para cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Botón para confirmar
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// Botón para guardar
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Botón para eliminar
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Botón para editar
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Botón para compartir
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// Botón para marcar como favorito
  ///
  /// In es, this message translates to:
  /// **'Favorito'**
  String get favorite;

  /// Botón para quitar de favoritos
  ///
  /// In es, this message translates to:
  /// **'Quitar de Favoritos'**
  String get unfavorite;

  /// Sección de favoritos
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favorites;

  /// Mensaje cuando no hay favoritos
  ///
  /// In es, this message translates to:
  /// **'No tienes favoritos'**
  String get noFavorites;

  /// Botón para agregar a favoritos
  ///
  /// In es, this message translates to:
  /// **'Agregar a Favoritos'**
  String get addToFavorites;

  /// Botón para quitar de favoritos
  ///
  /// In es, this message translates to:
  /// **'Quitar de Favoritos'**
  String get removeFromFavorites;

  /// Título de resultados de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Resultados de Búsqueda'**
  String get searchResults;

  /// Mensaje cuando no hay resultados
  ///
  /// In es, this message translates to:
  /// **'No se encontraron resultados'**
  String get noResults;

  /// Sugerencia cuando no hay resultados
  ///
  /// In es, this message translates to:
  /// **'Intenta con una búsqueda diferente'**
  String get tryDifferentSearch;

  /// Botón para limpiar filtros
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get clearFilters;

  /// Botón para aplicar filtros
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get applyFilters;

  /// Vista de mapa
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get map;

  /// Vista de lista
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get list;

  /// Horarios de apertura del estudio
  ///
  /// In es, this message translates to:
  /// **'Horarios de Apertura'**
  String get openingHours;

  /// Estado cerrado
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get closed;

  /// Estado abierto
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get open;

  /// Hora de apertura
  ///
  /// In es, this message translates to:
  /// **'Abre a las {time}'**
  String opensAt(String time);

  /// Hora de cierre
  ///
  /// In es, this message translates to:
  /// **'Cierra a las {time}'**
  String closesAt(String time);

  /// Estado disponible
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get available;

  /// Estado no disponible
  ///
  /// In es, this message translates to:
  /// **'No Disponible'**
  String get unavailable;

  /// Estado reservado
  ///
  /// In es, this message translates to:
  /// **'Reservado'**
  String get booked;

  /// Estado pendiente
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pending;

  /// Estado confirmado
  ///
  /// In es, this message translates to:
  /// **'Confirmado'**
  String get confirmed;

  /// Estado cancelado
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get cancelled;

  /// Estado completado
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get completed;

  /// Estado reembolsado
  ///
  /// In es, this message translates to:
  /// **'Reembolsado'**
  String get refunded;

  /// Saludo personalizado en home screen
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String hello(String name);

  /// Subtítulo del home screen
  ///
  /// In es, this message translates to:
  /// **'Encuentra tu espacio musical perfecto'**
  String get findPerfectSpace;

  /// Placeholder de la barra de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Buscar salas, ubicación...'**
  String get searchPlaceholder;

  /// Capacidad máxima del espacio
  ///
  /// In es, this message translates to:
  /// **'Hasta {capacity} personas'**
  String upToCapacity(int capacity);

  /// Mensaje cuando no hay resultados de búsqueda
  ///
  /// In es, this message translates to:
  /// **'No se encontraron salas'**
  String get noRoomsFound;

  /// Mensaje de sugerencia cuando no hay resultados
  ///
  /// In es, this message translates to:
  /// **'Intenta ajustar tus filtros o buscar en otra ubicación'**
  String get adjustFiltersMessage;

  /// Botón para limpiar en filtros
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get clear;

  /// Label para filtro de ciudad
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get city;

  /// Opción para mostrar todas las opciones
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get all;

  /// Label para filtro de precio máximo
  ///
  /// In es, this message translates to:
  /// **'Precio máximo por hora: \${price}'**
  String maxPricePerHour(int price);

  /// Tab de explorar en navegación inferior
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get explore;

  /// Tab de mensajes en navegación inferior
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get messages;

  /// Error general para creación de perfil
  ///
  /// In es, this message translates to:
  /// **'Error al crear perfil'**
  String get profileCreationError;

  /// Error de red durante creación de perfil
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el perfil. Verifica tu conexión a internet e intenta nuevamente.'**
  String get profileCreationNetworkError;

  /// Error de validación durante creación de perfil
  ///
  /// In es, this message translates to:
  /// **'Los datos del perfil no son válidos. Revisa la información ingresada.'**
  String get profileCreationValidationError;

  /// Error de permisos durante creación de perfil
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos para crear este perfil. Contacta al administrador.'**
  String get profileCreationPermissionError;

  /// Error del servidor durante creación de perfil
  ///
  /// In es, this message translates to:
  /// **'Error interno del servidor. Intenta nuevamente en unos minutos.'**
  String get profileCreationServerError;

  /// Error de timeout durante creación de perfil
  ///
  /// In es, this message translates to:
  /// **'La creación del perfil tardó demasiado tiempo. Verifica tu conexión e intenta nuevamente.'**
  String get profileCreationTimeoutError;

  /// Error general para actualización de perfil
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar perfil'**
  String get profileUpdateError;

  /// Error de red durante actualización de perfil
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el perfil. Verifica tu conexión a internet.'**
  String get profileUpdateNetworkError;

  /// Error de validación durante actualización de perfil
  ///
  /// In es, this message translates to:
  /// **'Los datos ingresados no son válidos. Revisa la información.'**
  String get profileUpdateValidationError;

  /// Error de permisos durante actualización de perfil
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos para actualizar este perfil.'**
  String get profileUpdatePermissionError;

  /// Error cuando el perfil está incompleto
  ///
  /// In es, this message translates to:
  /// **'Tu perfil está incompleto. Completa todos los campos requeridos.'**
  String get profileIncompleteError;

  /// Error cuando falta el nombre en el perfil
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio para crear tu perfil.'**
  String get profileNameRequiredError;

  /// Error cuando falta el email en el perfil
  ///
  /// In es, this message translates to:
  /// **'El email es obligatorio para crear tu perfil.'**
  String get profileEmailRequiredError;

  /// Error cuando falta el rol en el perfil
  ///
  /// In es, this message translates to:
  /// **'Debes seleccionar un tipo de cuenta (Músico o Anfitrión).'**
  String get profileRoleRequiredError;

  /// Error cuando el nombre es muy corto
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 2 caracteres.'**
  String get profileNameTooShortError;

  /// Error cuando el nombre es muy largo
  ///
  /// In es, this message translates to:
  /// **'El nombre no puede tener más de 50 caracteres.'**
  String get profileNameTooLongError;

  /// Error cuando el email tiene formato inválido
  ///
  /// In es, this message translates to:
  /// **'El formato del email no es válido.'**
  String get profileEmailInvalidError;

  /// Error cuando el teléfono tiene formato inválido
  ///
  /// In es, this message translates to:
  /// **'El formato del teléfono no es válido.'**
  String get profilePhoneInvalidError;

  /// Error cuando la biografía es muy larga
  ///
  /// In es, this message translates to:
  /// **'La biografía no puede tener más de 500 caracteres.'**
  String get profileBioTooLongError;

  /// Mensaje de éxito al crear perfil
  ///
  /// In es, this message translates to:
  /// **'¡Perfil creado exitosamente! Bienvenido a Salas & Beats.'**
  String get profileCreationSuccessMessage;

  /// Mensaje de éxito al actualizar perfil
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado exitosamente.'**
  String get profileUpdateSuccessMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
