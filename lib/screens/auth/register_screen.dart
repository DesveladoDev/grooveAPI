import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/services/localization_service.dart';
import 'package:salas_beats/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  String _selectedRole = 'musician'; // 'musician' o 'host'
  
  // Estados de validación en tiempo real
  bool _nameValid = false;
  bool _emailValid = false;
  bool _passwordValid = false;
  bool _confirmPasswordValid = false;
  bool _phoneValid = true; // Opcional, por defecto válido
  
  // Controladores de focus
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }
  
  void _validateName(String value) {
    setState(() {
      _nameValid = value.trim().isNotEmpty && value.trim().length >= 2;
    });
  }
  
  void _validateEmail(String value) {
    setState(() {
      _emailValid = Validators.validateEmail(value) == null;
    });
  }
  
  void _validatePassword(String value) {
    setState(() {
      _passwordValid = value.length >= AppConstants.minPasswordLength;
      // Re-validar confirmación de contraseña si ya tiene contenido
      if (_confirmPasswordController.text.isNotEmpty) {
        _confirmPasswordValid = _confirmPasswordController.text == value;
      }
    });
  }
  
  void _validateConfirmPassword(String value) {
    setState(() {
      _confirmPasswordValid = value == _passwordController.text && value.isNotEmpty;
    });
  }
  
  void _validatePhone(String value) {
    setState(() {
      _phoneValid = value.isEmpty || value.length >= 10;
    });
  }
  
  bool get _isFormValid => _nameValid && 
           _emailValid && 
           _passwordValid && 
           _confirmPasswordValid && 
           _phoneValid && 
           _acceptTerms;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      _showErrorSnackBar(context.l10n.mustAcceptTerms);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        role: _selectedRole,
      );
      
      if (result && mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.accountCreatedSuccessfully),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        // La navegación se maneja automáticamente en AuthProvider
      } else if (mounted) {
        final errorMessage = authProvider.error ?? context.l10n.unknownRegistrationError;
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.unexpectedError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.signInWithGoogle();
      
      if (result) {
        // La navegación se maneja automáticamente
      } else if (mounted) {
        final errorMessage = authProvider.error ?? 'Error al registrarse con Google';
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.googleRegistrationError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _navigateToLogin() {
    context.pop();
  }

  void _showTermsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.termsAndConditionsTitle),
        content: SingleChildScrollView(
          child: Text(context.l10n.termsContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(theme),
              
              const SizedBox(height: 32),
              
              // Selector de rol
              _buildRoleSelector(theme),
              
              const SizedBox(height: 24),
              
              // Formulario de registro
              _buildRegisterForm(theme),
              
              const SizedBox(height: 16),
              
              // Checkbox de términos
              _buildTermsCheckbox(theme),
              
              const SizedBox(height: 24),
              
              // Botón de registro
              _buildRegisterButton(theme),
              
              const SizedBox(height: 24),
              
              // Divisor "O"
              _buildDivider(theme),
              
              const SizedBox(height: 24),
              
              // Botón de Google
              _buildGoogleButton(theme),
              
              const SizedBox(height: 24),
              
              // Enlace de login
              _buildLoginLink(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) => Column(
      children: [
        Text(
          context.l10n.createAccount,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          context.l10n.joinMusicalCommunity,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

  Widget _buildRoleSelector(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.accountType,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildRoleOption(
                'musician',
                context.l10n.musician,
                context.l10n.searchAndBookRooms,
                Icons.music_note,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleOption(
                'host',
                context.l10n.host,
                context.l10n.rentYourSpace,
                Icons.home_work,
                theme,
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildRoleOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
    ThemeData theme,
  ) {
    final isSelected = _selectedRole == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(ThemeData theme) => Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de nombre
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            onChanged: _validateName,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            decoration: InputDecoration(
              labelText: context.l10n.fullName,
              hintText: context.l10n.yourName,
              prefixIcon: const Icon(Icons.person_outlined),
              suffixIcon: _nameController.text.isNotEmpty
                  ? Icon(
                      _nameValid ? Icons.check_circle : Icons.error,
                      color: _nameValid ? Colors.green : Colors.red,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                borderSide: BorderSide(
                  color: _nameController.text.isNotEmpty
                      ? (_nameValid ? Colors.green : Colors.red)
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.enterName;
              }
              if (value.trim().length < 2) {
                return context.l10n.nameMinLength;
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Campo de email
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            onChanged: _validateEmail,
            onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
            decoration: InputDecoration(
              labelText: context.l10n.emailAddress,
              hintText: context.l10n.emailHint,
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: _emailController.text.isNotEmpty
                  ? Icon(
                      _emailValid ? Icons.check_circle : Icons.error,
                      color: _emailValid ? Colors.green : Colors.red,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _emailController.text.isNotEmpty
                      ? (_emailValid ? Colors.green : Colors.red)
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            validator: Validators.validateEmail,
          ),
          
          const SizedBox(height: 16),
          
          // Campo de teléfono (opcional)
          TextFormField(
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            onChanged: _validatePhone,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            decoration: InputDecoration(
                labelText: context.l10n.phoneOptional,
                hintText: context.l10n.phoneHint,
              prefixIcon: const Icon(Icons.phone_outlined),
              suffixIcon: _phoneController.text.isNotEmpty
                  ? Icon(
                      _phoneValid ? Icons.check_circle : Icons.error,
                      color: _phoneValid ? Colors.green : Colors.red,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _phoneController.text.isNotEmpty
                      ? (_phoneValid ? Colors.green : Colors.red)
                      : theme.colorScheme.outline,
                ),
              ),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.length < 10) {
                  return context.l10n.enterValidPhone;
                }
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Campo de contraseña
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            onChanged: _validatePassword,
            onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
            decoration: InputDecoration(
              labelText: context.l10n.password,
              hintText: context.l10n.passwordMinLengthHint(AppConstants.minPasswordLength),
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_passwordController.text.isNotEmpty)
                    Icon(
                      _passwordValid ? Icons.check_circle : Icons.error,
                      color: _passwordValid ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _passwordController.text.isNotEmpty
                      ? (_passwordValid ? Colors.green : Colors.red)
                      : theme.colorScheme.outline,
                ),
              ),
              helperText: _passwordController.text.isNotEmpty && !_passwordValid
                  ? context.l10n.passwordHelperText(AppConstants.minPasswordLength)
                  : null,
              helperStyle: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.enterPassword;
              }
              if (value.length < AppConstants.minPasswordLength) {
                return context.l10n.passwordMinLengthError(AppConstants.minPasswordLength);
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Campo de confirmar contraseña
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            onChanged: _validateConfirmPassword,
            onFieldSubmitted: (_) => _isFormValid ? _handleRegister() : null,
            decoration: InputDecoration(
              labelText: context.l10n.confirmPassword,
              hintText: context.l10n.repeatPassword,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_confirmPasswordController.text.isNotEmpty)
                    Icon(
                      _confirmPasswordValid ? Icons.check_circle : Icons.error,
                      color: _confirmPasswordValid ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _confirmPasswordController.text.isNotEmpty
                      ? (_confirmPasswordValid ? Colors.green : Colors.red)
                      : theme.colorScheme.outline,
                ),
              ),
              helperText: _confirmPasswordController.text.isNotEmpty && !_confirmPasswordValid
                  ? context.l10n.passwordsDoNotMatch
                  : null,
              helperStyle: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.confirmYourPassword;
              }
              if (value != _passwordController.text) {
                return context.l10n.passwordsDoNotMatch;
              }
              return null;
            },
          ),
        ],
      ),
    );

  Widget _buildTermsCheckbox(ThemeData theme) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading ? null : () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  children: [
                    TextSpan(text: context.l10n.acceptTerms),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: _showTermsDialog,
                        child: Text(
                          context.l10n.termsAndConditions,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(text: context.l10n.andPrivacyPolicy),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

  Widget _buildRegisterButton(ThemeData theme) {
    final canRegister = _isFormValid && !_isLoading;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Indicador de progreso del formulario
        if (!_isFormValid && (_nameController.text.isNotEmpty || _emailController.text.isNotEmpty))
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.checklist,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                  context.l10n.completeFollowingFields,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._buildValidationChecklist(theme),
              ],
            ),
          ),
        
        // Botón de registro
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: canRegister ? _handleRegister : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canRegister 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline.withOpacity(0.3),
              foregroundColor: canRegister 
                  ? Colors.white 
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: canRegister ? 2 : 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (canRegister)
                        const Icon(
                          Icons.check_circle,
                          size: 20,
                        ),
                      if (canRegister) const SizedBox(width: 8),
                      Text(
                        canRegister ? context.l10n.createAccount : context.l10n.completeForm,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildValidationChecklist(ThemeData theme) {
    final checks = [
      {'label': context.l10n.validName, 'valid': _nameValid},
      {'label': context.l10n.validEmail, 'valid': _emailValid},
      {'label': context.l10n.securePassword, 'valid': _passwordValid},
      {'label': context.l10n.passwordsMatch, 'valid': _confirmPasswordValid},
      {'label': context.l10n.termsAccepted, 'valid': _acceptTerms},
    ];
    
    return checks.map((check) {
      final isValid = check['valid']! as bool;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isValid ? Colors.green : theme.colorScheme.outline,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              check['label']! as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isValid 
                    ? Colors.green 
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDivider(ThemeData theme) => Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
      ],
    );

  Widget _buildGoogleButton(ThemeData theme) => SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleRegister,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.asset(
                'assets/images/google_logo.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, size: 20),
              ),
        label: Text(
          context.l10n.continueWithGoogle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );

  Widget _buildLoginLink(ThemeData theme) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.alreadyHaveAccount,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _navigateToLogin,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            context.l10n.signIn,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
}