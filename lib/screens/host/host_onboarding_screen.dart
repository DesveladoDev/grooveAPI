import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/providers/stripe_provider.dart';
import 'package:salas_beats/services/stripe_service.dart';
import 'package:salas_beats/utils/app_routes.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';
import 'package:salas_beats/widgets/common/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class HostOnboardingScreen extends StatefulWidget {
  const HostOnboardingScreen({super.key});
  
  @override
  State<HostOnboardingScreen> createState() => _HostOnboardingScreenState();
}

class _HostOnboardingScreenState extends State<HostOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingAccount();
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Column(
            children: [
              // Header con progreso
              _buildHeader(),
              
              // Contenido de las páginas
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildBenefitsPage(),
                    _buildRequirementsPage(),
                    _buildSetupPage(),
                  ],
                ),
              ),
              
              // Botones de navegación
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  
  Widget _buildHeader() => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Botón de cerrar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
              Text(
                'Conviértete en anfitrión',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48), // Espaciador
            ],
          ),
          const SizedBox(height: 16),
          
          // Indicador de progreso
          LinearProgressIndicator(
            value: (_currentPage + 1) / 4,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Paso ${_currentPage + 1} de 4',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  
  Widget _buildWelcomePage() => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustración
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.home_work,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          
          // Título
          Text(
            '¡Bienvenido a Salas & Beats!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Descripción
          Text(
            'Comparte tu estudio de música y genera ingresos extra. Miles de músicos están buscando el espacio perfecto para crear.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Estadísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('500+', 'Anfitriones'),
              _buildStatItem(r'$2,500', 'Promedio mensual'),
              _buildStatItem('4.8★', 'Calificación'),
            ],
          ),
        ],
      ),
    );
  
  Widget _buildBenefitsPage() {
    final benefits = [
      {
        'icon': Icons.attach_money,
        'title': 'Genera ingresos',
        'description': 'Gana dinero con tu estudio cuando no lo uses',
      },
      {
        'icon': Icons.schedule,
        'title': 'Horarios flexibles',
        'description': 'Tú decides cuándo y cómo rentar tu espacio',
      },
      {
        'icon': Icons.security,
        'title': 'Pagos seguros',
        'description': 'Recibe pagos directamente en tu cuenta bancaria',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Soporte 24/7',
        'description': 'Te ayudamos en cada paso del proceso',
      },
      {
        'icon': Icons.verified_user,
        'title': 'Usuarios verificados',
        'description': 'Todos los huéspedes pasan por verificación',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Crece tu red',
        'description': 'Conecta con músicos y productores locales',
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Beneficios de ser anfitrión',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre todas las ventajas de compartir tu estudio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: benefits.length,
              itemBuilder: (context, index) {
                final benefit = benefits[index];
                return _buildBenefitItem(
                  icon: benefit['icon']! as IconData,
                  title: benefit['title']! as String,
                  description: benefit['description']! as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRequirementsPage() {
    final requirements = [
      {
        'icon': Icons.home,
        'title': 'Espacio adecuado',
        'description': 'Estudio de grabación, ensayo o producción musical',
        'completed': true,
      },
      {
        'icon': Icons.account_balance,
        'title': 'Cuenta bancaria',
        'description': 'Para recibir pagos de forma segura',
        'completed': false,
      },
      {
        'icon': Icons.description,
        'title': 'Documentación',
        'description': 'Identificación oficial y comprobante de domicilio',
        'completed': false,
      },
      {
        'icon': Icons.camera_alt,
        'title': 'Fotos del estudio',
        'description': 'Al menos 5 fotos de buena calidad',
        'completed': false,
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos para empezar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Asegúrate de tener todo listo antes de continuar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: requirements.length,
              itemBuilder: (context, index) {
                final requirement = requirements[index];
                return _buildRequirementItem(
                  icon: requirement['icon']! as IconData,
                  title: requirement['title']! as String,
                  description: requirement['description']! as String,
                  completed: requirement['completed']! as bool,
                );
              },
            ),
          ),
          
          // Nota importante
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'El proceso de verificación puede tomar de 1 a 3 días hábiles.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSetupPage() => Consumer<StripeProvider>(
      builder: (context, stripeProvider, child) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuración de pagos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configura tu cuenta para recibir pagos de forma segura',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // Estado de la cuenta
              if (stripeProvider.connectAccountStatus != null)
                _buildAccountStatusCard(stripeProvider.connectAccountStatus!),
              
              const SizedBox(height: 24),
              
              // Información de Stripe
              _buildStripeInfoCard(),
              
              const Spacer(),
              
              // Términos y condiciones
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Al continuar, aceptas:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTermItem('Términos de servicio de Salas & Beats'),
                    _buildTermItem('Términos de servicio de Stripe'),
                    _buildTermItem('Política de privacidad'),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  
  Widget _buildNavigationButtons() => Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Botón anterior
          if (_currentPage > 0)
            Expanded(
              child: CustomButton(
                text: 'Anterior',
                onPressed: _previousPage,
                isOutlined: true,
              ),
            ),
          
          if (_currentPage > 0) const SizedBox(width: 16),
          
          // Botón siguiente/finalizar
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: CustomButton(
              text: _currentPage == 3 ? 'Comenzar configuración' : 'Siguiente',
              onPressed: _currentPage == 3 ? _startStripeOnboarding : _nextPage,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  
  // Widgets auxiliares
  Widget _buildStatItem(String value, String label) => Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  
  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  
  Widget _buildRequirementItem({
    required IconData icon,
    required String title,
    required String description,
    required bool completed,
  }) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: completed 
                  ? Colors.green[100] 
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              completed ? Icons.check_circle : icon,
              color: completed ? Colors.green[600] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: completed ? Colors.green[700] : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  
  Widget _buildAccountStatusCard(ConnectAccountStatus status) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.isActive ? Icons.check_circle : Icons.pending,
                  color: status.isActive ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  status.isActive ? 'Cuenta activa' : 'Configuración pendiente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (status.requirements.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Requisitos pendientes:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...status.requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6),
                    const SizedBox(width: 8),
                    Text(
                      req,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),),
            ],
          ],
        ),
      ),
    );
  
  Widget _buildStripeInfoCard() => Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/stripe_logo.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.payment,
                      color: Colors.blue[700],
                    ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Powered by Stripe',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Stripe es la plataforma de pagos más segura del mundo. Tu información financiera está protegida con encriptación de nivel bancario.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildTermItem(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  
  // Métodos de navegación
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  // Métodos de funcionalidad
  Future<void> _checkExistingAccount() async {
    final stripeProvider = Provider.of<StripeProvider>(context, listen: false);
    await stripeProvider.loadConnectAccountStatus();
    
    if (stripeProvider.hasActiveConnectAccount) {
      // Si ya tiene cuenta activa, redirigir al dashboard
      Navigator.of(context).pushReplacementNamed(AppRoutes.hostDashboard);
    }
  }
  
  Future<void> _startStripeOnboarding() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final stripeProvider = Provider.of<StripeProvider>(context, listen: false);
      
      final user = authProvider.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Crear cuenta de Stripe Connect
      final result = await stripeProvider.createConnectAccount(
        email: user.email,
        businessType: 'individual',
        additionalInfo: {
          'firstName': user.name, // Using name instead of firstName
          'lastName': '', // UserModel doesn't have lastName property
          'phone': user.phone,
        },
      );
      
      if (result.success && result.onboardingUrl != null) {
        // Abrir URL de onboarding
        final uri = Uri.parse(result.onboardingUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          
          // Navegar al dashboard
          Navigator.of(context).pushReplacementNamed(AppRoutes.hostDashboard);
        } else {
          throw Exception('No se pudo abrir el enlace de configuración');
        }
      } else {
        throw Exception(result.toString()); // Using toString() instead of message
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}