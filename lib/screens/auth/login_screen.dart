import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/services/auth_service.dart';
import 'package:salas_beats/services/localization_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  // Estados de validación en tiempo real
  bool _emailValid = false;
  bool _passwordValid = false;
  
  // Controladores de focus
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
  
  void _validateEmail(String value) {
    setState(() {
      _emailValid = value.trim().isNotEmpty && 
                   RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim());
    });
  }
  
  void _validatePassword(String value) {
    setState(() {
      _passwordValid = value.isNotEmpty;
    });
  }
  
  bool get _isFormValid => _emailValid && _passwordValid;

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (success && mounted) {
        // Navega inmediatamente tras autenticación exitosa
        final isOnboardingComplete = authProvider.user?.isOnboardingComplete ?? false;
        context.go(isOnboardingComplete ? AppRoutes.home : AppRoutes.onboarding);
      } else if (mounted) {
        _showErrorSnackBar(authProvider.error ?? context.l10n.signInError);
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

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signInWithGoogle();
      
      if (success && mounted) {
        // Navega inmediatamente tras autenticación exitosa
        final isOnboardingComplete = authProvider.user?.isOnboardingComplete ?? false;
        context.go(isOnboardingComplete ? AppRoutes.home : AppRoutes.onboarding);
      } else if (mounted) {
        _showErrorSnackBar(authProvider.error ?? context.l10n.googleSignInError);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.googleSignInError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signInWithApple();
      
      if (success && mounted) {
        // Navega inmediatamente tras autenticación exitosa
        final isOnboardingComplete = authProvider.user?.isOnboardingComplete ?? false;
        context.go(isOnboardingComplete ? AppRoutes.home : AppRoutes.onboarding);
      } else if (mounted) {
        _showErrorSnackBar(authProvider.error ?? context.l10n.appleSignInError);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.appleSignInError);
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

  void _navigateToRegister() {
    context.push(AppRoutes.register);
  }

  void _navigateToForgotPassword() {
    context.push(AppRoutes.forgotPassword);
  }

  // Método temporal para crear documento faltante
  Future<void> _createMissingUserDocument() async {
    setState(() => _isLoading = true);
    
    try {
      final authService = AuthService();
      await authService.createMissingUserDocument();
      
      if (mounted) {
        _showSuccessSnackBar(context.l10n.userDocumentCreated);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.createDocumentError(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: size.height * 0.08),
              
              // Logo y título
              _buildHeader(theme),
              
              SizedBox(height: size.height * 0.06),
              
              // Formulario de login
              _buildLoginForm(theme),
              
              const SizedBox(height: 24),
              
              // Botón de login
              _buildLoginButton(theme),
              
              const SizedBox(height: 16),
              
              // Enlace de contraseña olvidada
              _buildForgotPasswordLink(theme),
              
              const SizedBox(height: 32),
              
              // Divisor "O"
              _buildDivider(theme),
              
              const SizedBox(height: 24),
              
              // Botón de Google
              _buildGoogleButton(theme),
              
              const SizedBox(height: 16),
              
              // Botón de Apple
              _buildAppleButton(theme),
              
              const SizedBox(height: 16),
              
              // Botón temporal para crear documento faltante
              _buildCreateUserButton(theme),
              
              const SizedBox(height: 32),
              
              // Enlace de registro
              _buildRegisterLink(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) => Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Título
        Text(
          context.l10n.welcomeBack,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Subtítulo
        Text(
          context.l10n.signInToContinue,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

  Widget _buildLoginForm(ThemeData theme) => Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de email
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            onChanged: _validateEmail,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            decoration: InputDecoration(
              labelText: context.l10n.email,
              hintText: context.l10n.emailHint,
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: _emailController.text.isNotEmpty
                  ? Icon(
                      _emailValid ? Icons.check_circle : Icons.error,
                      color: _emailValid ? Colors.green : Colors.red,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                borderSide: BorderSide(
                  color: _emailController.text.isNotEmpty
                      ? (_emailValid ? Colors.green : Colors.red)
                      : Colors.grey.shade300,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.enterEmail;
              }
              if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
                return context.l10n.enterValidEmail;
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
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            onChanged: _validatePassword,
            onFieldSubmitted: (_) => _isFormValid ? _handleEmailLogin() : null,
            decoration: InputDecoration(
              labelText: context.l10n.password,
              hintText: context.l10n.passwordHint,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_passwordController.text.isNotEmpty)
                    Icon(
                      _passwordValid ? Icons.check_circle : Icons.error,
                      color: _passwordValid ? Colors.green : Colors.red,
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
                      : Colors.grey.shade300,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.enterPassword;
              }
              if (value.length < AppConstants.minPasswordLength) {
                return context.l10n.passwordMinLength(AppConstants.minPasswordLength);
              }
              return null;
            },
          ),
        ],
      ),
    );

  Widget _buildLoginButton(ThemeData theme) {
    final canLogin = _isFormValid && !_isLoading;
    
    return Column(
      children: [
        // Indicador de estado del formulario
        if (!_isFormValid && (_emailController.text.isNotEmpty || _passwordController.text.isNotEmpty))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.completeAllFields,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Botón de login
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: canLogin ? _handleEmailLogin : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canLogin 
                  ? theme.colorScheme.primary 
                  : Colors.grey.shade300,
              foregroundColor: canLogin 
                  ? Colors.white 
                  : Colors.grey.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                      if (canLogin) 
                        const Icon(Icons.login, size: 18),
                      if (canLogin) 
                        const SizedBox(width: 8),
                      Text(
                        canLogin ? context.l10n.signIn : context.l10n.completeForm,
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

  Widget _buildForgotPasswordLink(ThemeData theme) => Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _navigateToForgotPassword,
        child: Text(
          context.l10n.forgotPassword,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

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
            context.l10n.or,
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
        onPressed: _isLoading ? null : _handleGoogleLogin,
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
          style: TextStyle(
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

  Widget _buildAppleButton(ThemeData theme) => SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleAppleLogin,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.apple,
                size: 20,
                color: Colors.black,
              ),
        label: Text(
          context.l10n.continueWithApple,
          style: TextStyle(
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

  Widget _buildCreateUserButton(ThemeData theme) => SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _createMissingUserDocument,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.person_add, size: 18),
        label: Text(
          context.l10n.createUserDocument,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(
            color: Colors.orange,
          ),
        ),
      ),
    );

  Widget _buildRegisterLink(ThemeData theme) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.noAccount,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _navigateToRegister,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            context.l10n.register,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
}