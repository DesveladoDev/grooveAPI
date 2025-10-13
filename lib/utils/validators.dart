import 'package:flutter/material.dart';
import 'package:salas_beats/config/constants.dart';

/// Clase utilitaria que contiene métodos de validación para formularios.
/// 
/// Esta clase proporciona validadores estáticos para diferentes tipos de datos
/// como emails, contraseñas, nombres, teléfonos, etc. Todos los métodos
/// retornan null si la validación es exitosa, o un String con el mensaje
/// de error si la validación falla.
/// 
/// Ejemplo de uso:
/// ```dart
/// TextFormField(
///   validator: Validators.validateEmail,
///   // ...
/// )
/// ```
class Validators {
  /// Valida que el email tenga un formato correcto.
  /// 
  /// Verifica que:
  /// - El valor no sea null o vacío
  /// - El formato coincida con el patrón de email definido en [AppConstants.emailPattern]
  /// 
  /// Retorna:
  /// - `null` si el email es válido
  /// - `String` con el mensaje de error si es inválido
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }
  
  /// Valida que la contraseña cumpla con los requisitos de seguridad.
  /// 
  /// Verifica que:
  /// - El valor no sea null o vacío
  /// - La longitud esté entre [AppConstants.minPasswordLength] y [AppConstants.maxPasswordLength]
  /// - Contenga al menos una mayúscula, una minúscula y un número
  /// 
  /// Retorna:
  /// - `null` si la contraseña es válida
  /// - `String` con el mensaje de error si es inválida
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }
    
    if (value.length > AppConstants.maxPasswordLength) {
      return 'La contraseña no puede tener más de ${AppConstants.maxPasswordLength} caracteres';
    }
    
    final passwordRegex = RegExp(AppConstants.passwordPattern);
    if (!passwordRegex.hasMatch(value)) {
      return 'La contraseña debe contener al menos una mayúscula, una minúscula y un número';
    }
    
    return null;
  }
  
  /// Valida que la confirmación de contraseña coincida con la contraseña original.
  /// 
  /// Parámetros:
  /// - [value]: La confirmación de contraseña a validar
  /// - [password]: La contraseña original para comparar
  /// 
  /// Retorna:
  /// - `null` si las contraseñas coinciden
  /// - `String` con el mensaje de error si no coinciden o está vacía
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }
  
  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario es requerido';
    }
    
    if (value.length < AppConstants.minUsernameLength) {
      return 'El nombre de usuario debe tener al menos ${AppConstants.minUsernameLength} caracteres';
    }
    
    if (value.length > AppConstants.maxUsernameLength) {
      return 'El nombre de usuario no puede tener más de ${AppConstants.maxUsernameLength} caracteres';
    }
    
    final usernameRegex = RegExp(AppConstants.usernamePattern);
    if (!usernameRegex.hasMatch(value)) {
      return 'El nombre de usuario solo puede contener letras, números y guiones bajos';
    }
    
    return null;
  }
  
  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    
    final phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un número de teléfono válido';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (value.length > 50) {
      return 'El nombre no puede tener más de 50 caracteres';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\u00f1\u00d1\s'-]+$");
    if (!nameRegex.hasMatch(value)) {
      return 'El nombre solo puede contener letras, espacios, guiones y apostrofes';
    }
    
    return null;
  }
  
  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es requerido';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Ingresa un precio válido';
    }
    
    if (price < AppConstants.minListingPrice) {
      return 'El precio mínimo es ${AppConstants.minListingPrice}${AppConstants.currencySymbol}';
    }
    
    if (price > AppConstants.maxListingPrice) {
      return 'El precio máximo es ${AppConstants.maxListingPrice}${AppConstants.currencySymbol}';
    }
    
    return null;
  }
  
  // Capacity validation
  static String? validateCapacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La capacidad es requerida';
    }
    
    final capacity = int.tryParse(value);
    if (capacity == null) {
      return 'Ingresa una capacidad válida';
    }
    
    if (capacity < 1) {
      return 'La capacidad mínima es 1 persona';
    }
    
    if (capacity > AppConstants.maxGuestsPerBooking) {
      return 'La capacidad máxima es ${AppConstants.maxGuestsPerBooking} personas';
    }
    
    return null;
  }
  
  // Description validation
  static String? validateDescription(String? value, {int? maxLength}) {
    if (value == null || value.isEmpty) {
      return 'La descripción es requerida';
    }
    
    if (value.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    
    final max = maxLength ?? AppConstants.maxListingDescriptionLength;
    if (value.length > max) {
      return 'La descripción no puede tener más de $max caracteres';
    }
    
    return null;
  }
  
  // Title validation
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'El título es requerido';
    }
    
    if (value.trim().length < 5) {
      return 'El título debe tener al menos 5 caracteres';
    }
    
    if (value.length > AppConstants.maxListingTitleLength) {
      return 'El título no puede tener más de ${AppConstants.maxListingTitleLength} caracteres';
    }
    
    return null;
  }
  
  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'La dirección es requerida';
    }
    
    if (value.trim().length < 10) {
      return 'Ingresa una dirección completa';
    }
    
    if (value.length > 200) {
      return 'La dirección no puede tener más de 200 caracteres';
    }
    
    return null;
  }
  
  // City validation
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La ciudad es requerida';
    }
    
    if (value.trim().length < 2) {
      return 'La ciudad debe tener al menos 2 caracteres';
    }
    
    if (value.length > 50) {
      return 'La ciudad no puede tener más de 50 caracteres';
    }
    
    return null;
  }
  
  // Postal code validation
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'El código postal es requerido';
    }
    
    // Spanish postal code format (5 digits)
    final postalCodeRegex = RegExp(r'^[0-9]{5}$');
    if (!postalCodeRegex.hasMatch(value)) {
      return 'Ingresa un código postal válido (5 dígitos)';
    }
    
    return null;
  }
  
  // Rating validation
  static String? validateRating(double? value) {
    if (value == null) {
      return 'La calificación es requerida';
    }
    
    if (value < AppConstants.minRating || value > AppConstants.maxRating) {
      return 'La calificación debe estar entre ${AppConstants.minRating} y ${AppConstants.maxRating}';
    }
    
    return null;
  }
  
  // Review validation
  static String? validateReview(String? value) {
    if (value == null || value.isEmpty) {
      return 'La reseña es requerida';
    }
    
    if (value.trim().length < 10) {
      return 'La reseña debe tener al menos 10 caracteres';
    }
    
    if (value.length > AppConstants.maxReviewLength) {
      return 'La reseña no puede tener más de ${AppConstants.maxReviewLength} caracteres';
    }
    
    return null;
  }
  
  // Message validation
  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El mensaje no puede estar vacío';
    }
    
    if (value.length > AppConstants.maxMessageLength) {
      return 'El mensaje no puede tener más de ${AppConstants.maxMessageLength} caracteres';
    }
    
    return null;
  }
  
  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'La fecha es requerida';
    }
    
    final now = DateTime.now();
    if (value.isBefore(now)) {
      return 'La fecha no puede ser anterior a hoy';
    }
    
    final maxDate = now.add(const Duration(days: AppConstants.advanceBookingDays));
    if (value.isAfter(maxDate)) {
      return 'No se pueden hacer reservas con más de ${AppConstants.advanceBookingDays} días de anticipación';
    }
    
    return null;
  }
  
  // Time validation
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'La hora es requerida';
    }
    
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Ingresa una hora válida (HH:MM)';
    }
    
    return null;
  }
  
  // Duration validation
  static String? validateDuration(int? hours) {
    if (hours == null || hours <= 0) {
      return 'La duración es requerida';
    }
    
    if (hours < AppConstants.minimumBookingDuration) {
      return 'La duración mínima es ${AppConstants.minimumBookingDuration} hora(s)';
    }
    
    if (hours > AppConstants.maximumBookingDuration) {
      return 'La duración máxima es ${AppConstants.maximumBookingDuration} horas';
    }
    
    return null;
  }
  
  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'La edad es requerida';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Ingresa una edad válida';
    }
    
    if (age < AppConstants.minHostAge) {
      return 'Debes ser mayor de ${AppConstants.minHostAge} años';
    }
    
    if (age > 120) {
      return 'Ingresa una edad válida';
    }
    
    return null;
  }
  
  // URL validation
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'La URL es requerida' : null;
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Ingresa una URL válida';
    }
    
    return null;
  }
  
  // Credit card validation (basic)
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de tarjeta es requerido';
    }
    
    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it's all digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'El número de tarjeta solo puede contener dígitos';
    }
    
    // Check length (most cards are 13-19 digits)
    if (cleanValue.length < 13 || cleanValue.length > 19) {
      return 'Ingresa un número de tarjeta válido';
    }
    
    // Luhn algorithm validation
    if (!_isValidLuhn(cleanValue)) {
      return 'Número de tarjeta inválido';
    }
    
    return null;
  }
  
  // CVV validation
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'El CVV es requerido';
    }
    
    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
      return 'El CVV debe tener 3 o 4 dígitos';
    }
    
    return null;
  }
  
  // Expiry date validation (MM/YY format)
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha de vencimiento es requerida';
    }
    
    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!expiryRegex.hasMatch(value)) {
      return 'Formato inválido (MM/AA)';
    }
    
    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    
    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0); // Last day of the month
    
    if (expiryDate.isBefore(now)) {
      return 'La tarjeta ha expirado';
    }
    
    return null;
  }
  
  // Helper method for Luhn algorithm
  static bool _isValidLuhn(String cardNumber) {
    var sum = 0;
    var alternate = false;
    
    for (var i = cardNumber.length - 1; i >= 0; i--) {
      var digit = int.parse(cardNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
  
  // Combine multiple validators
  static String? combineValidators(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

// Extension for easy form validation
extension FormValidation on GlobalKey<FormState> {
  bool validateAndSave() {
    final form = currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}