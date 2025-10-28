import 'package:cloud_firestore/cloud_firestore.dart';

/// Resultado de una validación
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  String get firstError => errors.isNotEmpty ? errors.first : '';
  String get allErrors => errors.join(', ');
}

/// Servicio centralizado de validaciones
class ValidationService {
  static const ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  const ValidationService._internal();

  // ========== VALIDACIONES DE EMAIL ==========
  
  ValidationResult validateEmail(String? email) {
    final errors = <String>[];
    
    if (email == null || email.trim().isEmpty) {
      errors.add('El email es requerido');
      return ValidationResult(isValid: false, errors: errors);
    }
    
    final emailTrimmed = email.trim().toLowerCase();
    
    // Regex para validar email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(emailTrimmed)) {
      errors.add('El formato del email no es válido');
    }
    
    if (emailTrimmed.length > 254) {
      errors.add('El email es demasiado largo (máximo 254 caracteres)');
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  // ========== VALIDACIONES DE CONTRASEÑA ==========
  
  ValidationResult validatePassword(String? password) {
    final errors = <String>[];
    final warnings = <String>[];
    
    if (password == null || password.isEmpty) {
      errors.add('La contraseña es requerida');
      return ValidationResult(isValid: false, errors: errors);
    }
    
    if (password.length < 8) {
      errors.add('La contraseña debe tener al menos 8 caracteres');
    }
    
    if (password.length > 128) {
      errors.add('La contraseña es demasiado larga (máximo 128 caracteres)');
    }
    
    // Verificar que tenga al menos una letra minúscula
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('La contraseña debe contener al menos una letra minúscula');
    }
    
    // Verificar que tenga al menos una letra mayúscula
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('La contraseña debe contener al menos una letra mayúscula');
    }
    
    // Verificar que tenga al menos un número
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('La contraseña debe contener al menos un número');
    }
    
    // Verificar que tenga al menos un carácter especial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      warnings.add('Se recomienda incluir al menos un carácter especial');
    }
    
    // Verificar patrones comunes débiles
    final commonPasswords = [
      'password', '12345678', 'qwerty123', 'abc123456', 
      'password123', '123456789', 'admin123'
    ];
    
    if (commonPasswords.contains(password.toLowerCase())) {
      errors.add('Esta contraseña es demasiado común');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty, 
      errors: errors, 
      warnings: warnings
    );
  }

  // ========== VALIDACIONES DE NOMBRE ==========
  
  ValidationResult validateName(String? name, {bool isRequired = true}) {
    final errors = <String>[];
    
    if (name == null || name.trim().isEmpty) {
      if (isRequired) {
        errors.add('El nombre es requerido');
      }
      return ValidationResult(isValid: !isRequired, errors: errors);
    }
    
    final nameTrimmed = name.trim();
    
    if (nameTrimmed.length < 2) {
      errors.add('El nombre debe tener al menos 2 caracteres');
    }
    
    if (nameTrimmed.length > 50) {
      errors.add('El nombre es demasiado largo (máximo 50 caracteres)');
    }
    
    // Verificar que solo contenga letras, espacios y algunos caracteres especiales
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s\-'\.]+$").hasMatch(nameTrimmed)) {
      errors.add('El nombre solo puede contener letras, espacios, guiones y apostrofes');
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  // ========== VALIDACIONES DE TELÉFONO ==========
  
  ValidationResult validatePhone(String? phone, {bool isRequired = false}) {
    final errors = <String>[];
    
    if (phone == null || phone.trim().isEmpty) {
      if (isRequired) {
        errors.add('El teléfono es requerido');
      }
      return ValidationResult(isValid: !isRequired, errors: errors);
    }
    
    final phoneTrimmed = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Validar formato mexicano (+52) o internacional
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phoneTrimmed)) {
      errors.add('El formato del teléfono no es válido');
    }
    
    // Validar longitud para números mexicanos
    if (phoneTrimmed.startsWith('+52') || phoneTrimmed.startsWith('52')) {
      final numberPart = phoneTrimmed.replaceFirst(RegExp(r'^\+?52'), '');
      if (numberPart.length != 10) {
        errors.add('El número mexicano debe tener 10 dígitos después del código de país');
      }
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  // ========== VALIDACIONES DE FECHAS ==========
  
  ValidationResult validateDateRange(DateTime? startDate, DateTime? endDate, {
    bool allowPastDates = false,
    Duration? minimumDuration,
    Duration? maximumDuration,
  }) {
    final errors = <String>[];
    
    if (startDate == null) {
      errors.add('La fecha de inicio es requerida');
    }
    
    if (endDate == null) {
      errors.add('La fecha de fin es requerida');
    }
    
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        errors.add('La fecha de inicio debe ser anterior a la fecha de fin');
      }
      
      if (!allowPastDates && startDate.isBefore(DateTime.now())) {
        errors.add('La fecha de inicio no puede ser en el pasado');
      }
      
      final duration = endDate.difference(startDate);
      
      if (minimumDuration != null && duration < minimumDuration) {
        final hours = minimumDuration.inHours;
        errors.add('La duración mínima es de $hours hora${hours != 1 ? 's' : ''}');
      }
      
      if (maximumDuration != null && duration > maximumDuration) {
        final hours = maximumDuration.inHours;
        errors.add('La duración máxima es de $hours hora${hours != 1 ? 's' : ''}');
      }
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  // ========== VALIDACIONES DE PRECIOS ==========
  
  ValidationResult validatePrice(double? price, {
    double? minPrice,
    double? maxPrice,
    bool isRequired = true,
  }) {
    final errors = <String>[];
    
    if (price == null) {
      if (isRequired) {
        errors.add('El precio es requerido');
      }
      return ValidationResult(isValid: !isRequired, errors: errors);
    }
    
    if (price < 0) {
      errors.add('El precio no puede ser negativo');
    }
    
    if (price == 0 && isRequired) {
      errors.add('El precio debe ser mayor a 0');
    }
    
    if (minPrice != null && price < minPrice) {
      errors.add('El precio mínimo es \$${minPrice.toStringAsFixed(2)}');
    }
    
    if (maxPrice != null && price > maxPrice) {
      errors.add('El precio máximo es \$${maxPrice.toStringAsFixed(2)}');
    }
    
    // Verificar que no tenga más de 2 decimales
    final priceString = price.toStringAsFixed(2);
    if (price.toString() != priceString && price.toString().length > priceString.length) {
      errors.add('El precio no puede tener más de 2 decimales');
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  // ========== VALIDACIONES DE IDs ==========
  
  ValidationResult validateId(String? id, {String fieldName = 'ID'}) {
    final errors = <String>[];
    
    if (id == null || id.trim().isEmpty) {
      errors.add('$fieldName es requerido');
      return ValidationResult(isValid: false, errors: errors);
    }
    
    final idTrimmed = id.trim();
    
    // Validar que sea un ID válido de Firestore (alfanumérico, guiones bajos)
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(idTrimmed)) {
      errors.add('$fieldName contiene caracteres no válidos');
    }
    
    if (idTrimmed.length < 3) {
      errors.add('$fieldName debe tener al menos 3 caracteres');
    }
    
    if (idTrimmed.length > 100) {
      errors.add('$fieldName es demasiado largo (máximo 100 caracteres)');
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  // ========== VALIDACIONES DE TEXTO LIBRE ==========
  
  ValidationResult validateText(String? text, {
    String fieldName = 'Texto',
    int? minLength,
    int? maxLength,
    bool isRequired = false,
    bool allowHtml = false,
  }) {
    final errors = <String>[];
    
    if (text == null || text.trim().isEmpty) {
      if (isRequired) {
        errors.add('$fieldName es requerido');
      }
      return ValidationResult(isValid: !isRequired, errors: errors);
    }
    
    final textTrimmed = text.trim();
    
    if (minLength != null && textTrimmed.length < minLength) {
      errors.add('$fieldName debe tener al menos $minLength caracteres');
    }
    
    if (maxLength != null && textTrimmed.length > maxLength) {
      errors.add('$fieldName no puede tener más de $maxLength caracteres');
    }
    
    // Verificar contenido malicioso si no se permite HTML
    if (!allowHtml) {
      if (RegExp(r'<[^>]*>').hasMatch(textTrimmed)) {
        errors.add('$fieldName no puede contener etiquetas HTML');
      }
      
      if (RegExp(r'javascript:', caseSensitive: false).hasMatch(textTrimmed)) {
        errors.add('$fieldName contiene contenido no permitido');
      }
    }
    
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  // ========== VALIDACIONES COMPUESTAS ==========
  
  /// Valida todos los campos de un usuario
  ValidationResult validateUserData({
    required String? name,
    required String? email,
    String? phone,
    String? bio,
  }) {
    final allErrors = <String>[];
    final allWarnings = <String>[];
    
    final nameResult = validateName(name);
    allErrors.addAll(nameResult.errors);
    allWarnings.addAll(nameResult.warnings);
    
    final emailResult = validateEmail(email);
    allErrors.addAll(emailResult.errors);
    allWarnings.addAll(emailResult.warnings);
    
    final phoneResult = validatePhone(phone);
    allErrors.addAll(phoneResult.errors);
    allWarnings.addAll(phoneResult.warnings);
    
    if (bio != null) {
      final bioResult = validateText(bio, 
        fieldName: 'Biografía', 
        maxLength: 500
      );
      allErrors.addAll(bioResult.errors);
      allWarnings.addAll(bioResult.warnings);
    }
    
    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
    );
  }

  /// Valida todos los campos de una reserva
  ValidationResult validateBookingData({
    required String? listingId,
    required String? hostId,
    required String? guestId,
    required DateTime? startTime,
    required DateTime? endTime,
    required double? pricePerHour,
  }) {
    final allErrors = <String>[];
    final allWarnings = <String>[];
    
    final listingResult = validateId(listingId, fieldName: 'ID del listing');
    allErrors.addAll(listingResult.errors);
    
    final hostResult = validateId(hostId, fieldName: 'ID del anfitrión');
    allErrors.addAll(hostResult.errors);
    
    final guestResult = validateId(guestId, fieldName: 'ID del huésped');
    allErrors.addAll(guestResult.errors);
    
    final dateResult = validateDateRange(
      startTime, 
      endTime,
      minimumDuration: const Duration(hours: 1),
      maximumDuration: const Duration(hours: 24),
    );
    allErrors.addAll(dateResult.errors);
    allWarnings.addAll(dateResult.warnings);
    
    final priceResult = validatePrice(
      pricePerHour,
      minPrice: 50.0, // Precio mínimo por hora
      maxPrice: 10000.0, // Precio máximo por hora
    );
    allErrors.addAll(priceResult.errors);
    allWarnings.addAll(priceResult.warnings);
    
    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
    );
  }
}