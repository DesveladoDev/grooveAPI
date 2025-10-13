import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  final bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );

  PreferredSizeWidget _buildAppBar() => AppBar(
      title: const Text('Términos y Condiciones'),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareTerms,
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'download_pdf',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Descargar PDF'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  Icon(Icons.print),
                  SizedBox(width: 8),
                  Text('Imprimir'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'contact_support',
              child: Row(
                children: [
                  Icon(Icons.support_agent),
                  SizedBox(width: 8),
                  Text('Contactar Soporte'),
                ],
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildSearchBar() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar en términos y condiciones...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );

  Widget _buildTabBar() => TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Términos de Uso'),
        Tab(text: 'Política de Privacidad'),
        Tab(text: 'Política de Cookies'),
      ],
    );

  Widget _buildContent() => TabBarView(
      controller: _tabController,
      children: [
        _buildTermsOfUse(),
        _buildPrivacyPolicy(),
        _buildCookiePolicy(),
      ],
    );

  Widget _buildTermsOfUse() => SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Términos de Uso de Salas and Beats'),
          _buildLastUpdated('Última actualización: 15 de enero de 2024'),
          const SizedBox(height: 24),
          
          _buildSection(
            title: '1. Aceptación de los Términos',
            content: 'Al acceder y utilizar la aplicación Salas and Beats, usted acepta estar sujeto a estos Términos de Uso y todas las leyes y regulaciones aplicables. Si no está de acuerdo con alguno de estos términos, se le prohíbe usar o acceder a este sitio.',
          ),
          
          _buildSection(
            title: '2. Descripción del Servicio',
            content: 'Salas and Beats es una plataforma digital que permite a los usuarios reservar espacios para eventos, ensayos musicales, grabaciones y otras actividades relacionadas. Nuestro servicio incluye:\n\n• Búsqueda y reserva de espacios\n• Sistema de pagos integrado\n• Comunicación entre usuarios\n• Gestión de reservas\n• Valoraciones y reseñas',
          ),
          
          _buildSection(
            title: '3. Registro de Usuario',
            content: 'Para utilizar ciertos aspectos del servicio, debe registrarse y crear una cuenta. Usted es responsable de:\n\n• Proporcionar información precisa y actualizada\n• Mantener la confidencialidad de su contraseña\n• Todas las actividades que ocurran bajo su cuenta\n• Notificar inmediatamente cualquier uso no autorizado',
          ),
          
          _buildSection(
            title: '4. Uso Aceptable',
            content: 'Al usar nuestro servicio, usted acepta no:\n\n• Violar cualquier ley local, estatal, nacional o internacional\n• Transmitir material que sea difamatorio, obsceno o ilegal\n• Interferir con la seguridad del servicio\n• Intentar obtener acceso no autorizado a otros sistemas\n• Usar el servicio para actividades comerciales no autorizadas',
          ),
          
          _buildSection(
            title: '5. Reservas y Pagos',
            content: 'Las reservas están sujetas a disponibilidad y confirmación. Los términos específicos incluyen:\n\n• Los pagos deben realizarse según los términos acordados\n• Las cancelaciones están sujetas a la política de cancelación\n• Los reembolsos se procesan según nuestras políticas\n• Los precios pueden cambiar sin previo aviso',
          ),
          
          _buildSection(
            title: '6. Responsabilidades del Usuario',
            content: 'Como usuario de la plataforma, usted es responsable de:\n\n• Cumplir con las reglas del espacio reservado\n• Cualquier daño causado durante el uso del espacio\n• Proporcionar información precisa en las reservas\n• Respetar a otros usuarios y propietarios de espacios',
          ),
          
          _buildSection(
            title: '7. Limitación de Responsabilidad',
            content: 'Salas and Beats no será responsable por:\n\n• Daños indirectos, incidentales o consecuentes\n• Pérdida de beneficios o datos\n• Interrupciones del servicio\n• Acciones de terceros\n• Problemas con los espacios reservados',
          ),
          
          _buildSection(
            title: '8. Modificaciones',
            content: 'Nos reservamos el derecho de modificar estos términos en cualquier momento. Las modificaciones entrarán en vigor inmediatamente después de su publicación. Su uso continuado del servicio constituye la aceptación de los términos modificados.',
          ),
          
          _buildSection(
            title: '9. Terminación',
            content: 'Podemos terminar o suspender su cuenta inmediatamente, sin previo aviso, por cualquier motivo, incluyendo la violación de estos Términos de Uso.',
          ),
          
          _buildSection(
            title: '10. Contacto',
            content: 'Si tiene preguntas sobre estos Términos de Uso, puede contactarnos en:\n\nEmail: legal@salasandbeats.com\nTeléfono: +34 900 123 456\nDirección: Calle Principal 123, Madrid, España',
          ),
        ],
      ),
    );

  Widget _buildPrivacyPolicy() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Política de Privacidad'),
          _buildLastUpdated('Última actualización: 15 de enero de 2024'),
          const SizedBox(height: 24),
          
          _buildSection(
            title: '1. Información que Recopilamos',
            content: 'Recopilamos información que usted nos proporciona directamente:\n\n• Información de registro (nombre, email, teléfono)\n• Información de perfil\n• Historial de reservas\n• Comunicaciones con otros usuarios\n• Información de pago (procesada de forma segura)',
          ),
          
          _buildSection(
            title: '2. Cómo Utilizamos su Información',
            content: 'Utilizamos su información para:\n\n• Proporcionar y mejorar nuestros servicios\n• Procesar reservas y pagos\n• Comunicarnos con usted\n• Personalizar su experiencia\n• Cumplir con obligaciones legales',
          ),
          
          _buildSection(
            title: '3. Compartir Información',
            content: 'No vendemos su información personal. Podemos compartir información:\n\n• Con propietarios de espacios para reservas\n• Con proveedores de servicios de confianza\n• Cuando sea requerido por ley\n• Para proteger nuestros derechos y seguridad',
          ),
          
          _buildSection(
            title: '4. Seguridad de Datos',
            content: 'Implementamos medidas de seguridad técnicas y organizativas para proteger su información personal contra acceso no autorizado, alteración, divulgación o destrucción.',
          ),
          
          _buildSection(
            title: '5. Sus Derechos',
            content: 'Usted tiene derecho a:\n\n• Acceder a su información personal\n• Corregir información inexacta\n• Solicitar la eliminación de sus datos\n• Oponerse al procesamiento\n• Portabilidad de datos',
          ),
          
          _buildSection(
            title: '6. Cookies y Tecnologías Similares',
            content: 'Utilizamos cookies y tecnologías similares para mejorar su experiencia, analizar el uso del sitio y personalizar contenido. Puede gestionar sus preferencias de cookies en la configuración de su navegador.',
          ),
        ],
      ),
    );

  Widget _buildCookiePolicy() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Política de Cookies'),
          _buildLastUpdated('Última actualización: 15 de enero de 2024'),
          const SizedBox(height: 24),
          
          _buildSection(
            title: '¿Qué son las Cookies?',
            content: 'Las cookies son pequeños archivos de texto que se almacenan en su dispositivo cuando visita un sitio web. Nos ayudan a recordar sus preferencias y mejorar su experiencia.',
          ),
          
          _buildSection(
            title: 'Tipos de Cookies que Utilizamos',
            content: '• **Cookies Esenciales**: Necesarias para el funcionamiento básico del sitio\n• **Cookies de Rendimiento**: Nos ayudan a entender cómo usa el sitio\n• **Cookies de Funcionalidad**: Recuerdan sus preferencias\n• **Cookies de Marketing**: Utilizadas para mostrar anuncios relevantes',
          ),
          
          _buildSection(
            title: 'Gestión de Cookies',
            content: 'Puede controlar y/o eliminar las cookies como desee. Puede eliminar todas las cookies que ya están en su computadora y puede configurar la mayoría de los navegadores para evitar que se coloquen.',
          ),
          
          _buildSection(
            title: 'Cookies de Terceros',
            content: 'Algunos de nuestros socios pueden usar cookies en nuestro sitio. Estos incluyen:\n\n• Google Analytics (análisis)\n• Stripe (pagos)\n• Redes sociales (compartir contenido)',
          ),
        ],
      ),
    );

  Widget _buildSectionHeader(String title) => Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );

  Widget _buildLastUpdated(String date) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        date,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
        ),
      ),
    );

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    // Highlight search query if present
    if (_searchQuery.isNotEmpty && 
        (title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
         content.toLowerCase().contains(_searchQuery.toLowerCase()))) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          border: Border.all(color: Colors.yellow[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildSectionContent(title, content),
      );
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: _buildSectionContent(title, content),
    );
  }

  Widget _buildSectionContent(String title, String content) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );

  void _shareTerms() {
    const shareText = 'Términos y Condiciones de Salas and Beats\n\n'
        'Consulta nuestros términos completos en la aplicación.';
    
    Clipboard.setData(const ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Términos copiados al portapapeles'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'download_pdf':
        _downloadPDF();
        break;
      case 'print':
        _printTerms();
        break;
      case 'contact_support':
        _contactSupport();
        break;
    }
  }

  void _downloadPDF() {
    // TODO: Implementar descarga de PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Descarga de PDF próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _printTerms() {
    // TODO: Implementar impresión
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de impresión próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _contactSupport() {
    Navigator.pushNamed(context, '/support');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}