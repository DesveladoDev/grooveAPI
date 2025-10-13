import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/app_constants.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.6, curve: Curves.easeIn),
    ),);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ),);

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 SplashScreen: Iniciando inicialización de la app');
      
      // Simular tiempo de carga mínimo para mostrar splash
      await Future.delayed(const Duration(milliseconds: 1500));

      // Verificar estado de autenticación
      print('🔐 SplashScreen: Verificando estado de autenticación');
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAuthStatus();

      print('🔐 SplashScreen: Estado de autenticación verificado');
      print('🔐 SplashScreen: isAuthenticated = ${authProvider.isAuthenticated}');
      print('🔐 SplashScreen: user = ${authProvider.user?.email ?? 'null'}');
      print('🔐 SplashScreen: status = ${authProvider.status}');

      // Esperar a que termine la animación
      await _animationController.forward();
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        print('🧭 SplashScreen: Navegando a la siguiente pantalla');
        _navigateToNextScreen();
      }
    } catch (e) {
      print('❌ SplashScreen: Error durante la inicialización: $e');
      // En caso de error, navegar a la pantalla de inicio
      if (mounted) {
        print('🧭 SplashScreen: Navegando a onboarding por error');
        context.go(AppRoutes.onboarding);
      }
    }
  }

  void _navigateToNextScreen() {
    print('🧭 SplashScreen: _navigateToNextScreen llamado');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    final user = authProvider.user;
    
    print('🧭 SplashScreen: isAuthenticated = $isAuthenticated');
    
    if (isAuthenticated && user != null) {
      print('🧭 SplashScreen: Usuario autenticado, navegando a home');
      print('🧭 SplashScreen: Intentando navegar a: ${AppRoutes.home}');
      try {
        context.go(AppRoutes.home);
        print('🧭 SplashScreen: Navegación a home exitosa');
      } catch (e) {
        print('🧭 SplashScreen: Error navegando a home: $e');
        // Fallback: navegar directamente con la ruta
        context.go('/home');
      }
    } else {
      print('🧭 SplashScreen: Usuario no autenticado, navegando a onboarding');
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildLogo(),
                    ),
                  ),
              ),
              
              const SizedBox(height: 32),
              
              // Nombre de la app
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
              ),
              
              const SizedBox(height: 8),
              
              // Descripción
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      AppConstants.appDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ),
              
              const SizedBox(height: 64),
              
              // Indicador de carga
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildLogo() => Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              'S&B',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}