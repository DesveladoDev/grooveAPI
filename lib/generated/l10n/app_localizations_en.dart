// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Salas & Beats';

  @override
  String get appDescription =>
      'Marketplace for renting rehearsal rooms and recording studios';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeMessage => 'Find the perfect space for your music';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Sign In';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get bookings => 'Bookings';

  @override
  String get profile => 'Profile';

  @override
  String get searchStudios => 'Search studios...';

  @override
  String get nearbyStudios => 'Nearby Studios';

  @override
  String get popularStudios => 'Popular Studios';

  @override
  String get recentlyViewed => 'Recently Viewed';

  @override
  String get filters => 'Filters';

  @override
  String get sortBy => 'Sort by';

  @override
  String get price => 'Price';

  @override
  String get rating => 'Rating';

  @override
  String get distance => 'Distance';

  @override
  String get availability => 'Availability';

  @override
  String get studioType => 'Studio Type';

  @override
  String get rehearsalRoom => 'Rehearsal Room';

  @override
  String get recordingStudio => 'Recording Studio';

  @override
  String get liveRoom => 'Live Room';

  @override
  String pricePerHour(int price) {
    return '\$$price/hour';
  }

  @override
  String priceRange(String min, String max) {
    return '$min - $max';
  }

  @override
  String get viewDetails => 'View Details';

  @override
  String get bookNow => 'Book Now';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get duration => 'Duration';

  @override
  String get hours => 'hours';

  @override
  String get minutes => 'minutes';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get paypal => 'PayPal';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get payNow => 'Pay Now';

  @override
  String get bookingConfirmed => 'Booking Confirmed';

  @override
  String get bookingDetails => 'Booking Details';

  @override
  String get bookingId => 'Booking ID';

  @override
  String get studioName => 'Studio Name';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get location => 'Location';

  @override
  String get contact => 'Contact';

  @override
  String get directions => 'Directions';

  @override
  String get callStudio => 'Call Studio';

  @override
  String get messageStudio => 'Message Studio';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get modifyBooking => 'Modify Booking';

  @override
  String get upcomingBookings => 'Upcoming Bookings';

  @override
  String get pastBookings => 'Past Bookings';

  @override
  String get noBookings => 'You have no bookings';

  @override
  String get exploreStudios => 'Explore Studios';

  @override
  String get rateExperience => 'Rate Experience';

  @override
  String get writeReview => 'Write Review';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get reviews => 'Reviews';

  @override
  String get photos => 'Photos';

  @override
  String get amenities => 'Amenities';

  @override
  String get equipment => 'Equipment';

  @override
  String get rules => 'Rules';

  @override
  String get cancellationPolicy => 'Cancellation Policy';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get passwordHint => 'Your password';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String passwordMinLength(int minLength) {
    return 'Password must be at least $minLength characters';
  }

  @override
  String get completeAllFields => 'Complete all fields correctly';

  @override
  String get signIn => 'Sign in';

  @override
  String get completeForm => 'Complete the form';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get createUserDocument => 'Create User Document (Temporary)';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signInError => 'Sign in error';

  @override
  String get unexpectedError => 'Unexpected error. Please try again.';

  @override
  String get googleSignInError => 'Google sign in error';

  @override
  String get appleSignInError => 'Apple sign in error';

  @override
  String get userDocumentCreated => 'User document created successfully';

  @override
  String createDocumentError(String error) {
    return 'Error creating document: $error';
  }

  @override
  String get createAccount => 'Create account';

  @override
  String get joinMusicalCommunity => 'Join the musical community';

  @override
  String get accountType => 'Account type';

  @override
  String get musician => 'Musician';

  @override
  String get searchAndBookRooms => 'Search and book rooms';

  @override
  String get host => 'Host';

  @override
  String get rentYourSpace => 'Rent your space';

  @override
  String get fullName => 'Full name';

  @override
  String get yourName => 'Your name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get emailAddress => 'Email address';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get phoneHint => '+1 555 123 4567';

  @override
  String get enterValidPhone => 'Enter a valid phone number';

  @override
  String passwordMinLengthHint(int length) {
    return 'Minimum $length characters';
  }

  @override
  String passwordHelperText(int length) {
    return 'Must be at least $length characters';
  }

  @override
  String passwordMinLengthError(int length) {
    return 'Password must be at least $length characters';
  }

  @override
  String get repeatPassword => 'Repeat your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get acceptTerms => 'I accept the ';

  @override
  String get termsAndConditions => 'terms and conditions';

  @override
  String get andPrivacyPolicy => ' and privacy policy';

  @override
  String get completeFollowingFields => 'Complete the following fields:';

  @override
  String get validName => 'Valid name';

  @override
  String get validEmail => 'Valid email';

  @override
  String get securePassword => 'Secure password';

  @override
  String get passwordsMatch => 'Passwords match';

  @override
  String get termsAccepted => 'Terms accepted';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get mustAcceptTerms => 'You must accept the terms and conditions';

  @override
  String get accountCreatedSuccessfully =>
      'Account created successfully. Verify your email.';

  @override
  String get unknownRegistrationError => 'Unknown error during registration';

  @override
  String get googleRegistrationError => 'Error registering with Google';

  @override
  String get termsAndConditionsTitle => 'Terms and Conditions';

  @override
  String get termsContent =>
      'By using Salas & Beats, you accept our terms of service and privacy policy.\n\nAs a musician, you can search and book rehearsal rooms.\n\nAs a host, you can list your space and receive payments for bookings.\n\nWe reserve the right to suspend accounts that violate our policies.';

  @override
  String get close => 'Close';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get privacy => 'Privacy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get help => 'Help';

  @override
  String get support => 'Support';

  @override
  String get faq => 'FAQ';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get logout => 'Sign Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get discardChanges => 'Discard Changes';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get favorite => 'Favorite';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavorites => 'You have no favorites';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noResults => 'No results found';

  @override
  String get tryDifferentSearch => 'Try a different search';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get map => 'Map';

  @override
  String get list => 'List';

  @override
  String get openingHours => 'Opening Hours';

  @override
  String get closed => 'Closed';

  @override
  String get open => 'Open';

  @override
  String opensAt(String time) {
    return 'Opens at $time';
  }

  @override
  String closesAt(String time) {
    return 'Closes at $time';
  }

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get booked => 'Booked';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get completed => 'Completed';

  @override
  String get refunded => 'Refunded';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get findPerfectSpace => 'Find your perfect musical space';

  @override
  String get searchPlaceholder => 'Search rooms, location...';

  @override
  String upToCapacity(int capacity) {
    return 'Up to $capacity people';
  }

  @override
  String get noRoomsFound => 'No rooms found';

  @override
  String get adjustFiltersMessage =>
      'Try adjusting your filters or searching in another location';

  @override
  String get clear => 'Clear';

  @override
  String get city => 'City';

  @override
  String get all => 'All';

  @override
  String maxPricePerHour(int price) {
    return 'Max price per hour: \$$price';
  }

  @override
  String get explore => 'Explore';

  @override
  String get messages => 'Messages';

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
