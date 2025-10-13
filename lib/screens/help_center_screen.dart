import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  final List<HelpCategory> _categories = [
    HelpCategory(
      title: 'Reservas',
      icon: Icons.book_online,
      color: Colors.blue,
      faqs: [
        FAQ(
          question: '¿Cómo hago una reserva?',
          answer: 'Para hacer una reserva, busca el espacio que te interese, selecciona la fecha y hora, y sigue el proceso de pago.',
        ),
        FAQ(
          question: '¿Puedo cancelar mi reserva?',
          answer: 'Sí, puedes cancelar tu reserva desde la sección "Mis Reservas" hasta 24 horas antes del evento.',
        ),
        FAQ(
          question: '¿Qué pasa si llego tarde?',
          answer: 'Si llegas tarde, tu tiempo de reserva se reducirá. Te recomendamos llegar puntualmente.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Pagos',
      icon: Icons.payment,
      color: Colors.green,
      faqs: [
        FAQ(
          question: '¿Qué métodos de pago aceptan?',
          answer: 'Aceptamos tarjetas de crédito, débito, PayPal y transferencias bancarias.',
        ),
        FAQ(
          question: '¿Cuándo se cobra el pago?',
          answer: 'El pago se procesa inmediatamente después de confirmar la reserva.',
        ),
        FAQ(
          question: '¿Puedo obtener un reembolso?',
          answer: 'Los reembolsos están sujetos a la política de cancelación de cada espacio.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Cuenta',
      icon: Icons.account_circle,
      color: Colors.orange,
      faqs: [
        FAQ(
          question: '¿Cómo cambio mi contraseña?',
          answer: 'Ve a Configuración > Seguridad > Cambiar contraseña para actualizar tu contraseña.',
        ),
        FAQ(
          question: '¿Cómo actualizo mi perfil?',
          answer: 'Puedes actualizar tu perfil desde la sección "Mi Perfil" en el menú principal.',
        ),
        FAQ(
          question: '¿Cómo elimino mi cuenta?',
          answer: 'Para eliminar tu cuenta, contacta con nuestro soporte técnico.',
        ),
      ],
    ),
    HelpCategory(
      title: 'Hosts',
      icon: Icons.home_work,
      color: Colors.purple,
      faqs: [
        FAQ(
          question: '¿Cómo publico mi espacio?',
          answer: 'Ve a "Crear Anuncio" y completa toda la información requerida sobre tu espacio.',
        ),
        FAQ(
          question: '¿Cuánto cobran de comisión?',
          answer: 'Cobramos una comisión del 10% por cada reserva completada exitosamente.',
        ),
        FAQ(
          question: '¿Cuándo recibo el pago?',
          answer: 'Los pagos se procesan 24 horas después de que termine la reserva.',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Ayuda'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar en preguntas frecuentes...',
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
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty ? _buildCategoriesView() : _buildSearchResults(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _contactSupport,
        icon: const Icon(Icons.support_agent),
        label: const Text('Contactar Soporte'),
      ),
    );

  Widget _buildCategoriesView() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActions(),
          const SizedBox(height: 24),
          Text(
            'Categorías de Ayuda',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ],
      ),
    );

  Widget _buildQuickActions() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.chat,
                    label: 'Chat en Vivo',
                    onTap: _startLiveChat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.email,
                    label: 'Enviar Email',
                    onTap: _sendEmail,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

  Widget _buildCategoryCard(HelpCategory category) => Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToCategory(category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 32,
                  color: category.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.faqs.length} preguntas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildSearchResults() {
    final results = <FAQ>[];
    
    for (final category in _categories) {
      for (final faq in category.faqs) {
        if (faq.question.toLowerCase().contains(_searchQuery) ||
            faq.answer.toLowerCase().contains(_searchQuery)) {
          results.add(faq);
        }
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros términos de búsqueda',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final faq = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              faq.question,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  faq.answer,
                  style: const TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToCategory(HelpCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpCategoryScreen(category: category),
      ),
    );
  }

  void _contactSupport() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contactar Soporte',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat en Vivo'),
              subtitle: const Text('Respuesta inmediata'),
              onTap: _startLiveChat,
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('soporte@salasandbeats.com'),
              onTap: _sendEmail,
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Teléfono'),
              subtitle: const Text('+1 (555) 123-4567'),
              onTap: _callSupport,
            ),
          ],
        ),
      ),
    );
  }

  void _startLiveChat() {
    // Implementar chat en vivo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat en vivo próximamente disponible'),
      ),
    );
  }

  Future<void> _sendEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'soporte@salasandbeats.com',
      query: 'subject=Consulta desde la app',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el cliente de email'),
          ),
        );
      }
    }
  }

  Future<void> _callSupport() async {
    final phoneUri = Uri(
      scheme: 'tel',
      path: '+15551234567',
    );
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo realizar la llamada'),
          ),
        );
      }
    }
  }
}

class HelpCategoryScreen extends StatelessWidget {

  const HelpCategoryScreen({required this.category, super.key});
  final HelpCategory category;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(category.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.faqs.length,
        itemBuilder: (context, index) {
          final faq = category.faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(
                faq.question,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faq.answer,
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<HelpCategory>('category', category));
  }
}

class HelpCategory {

  HelpCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.faqs,
  });
  final String title;
  final IconData icon;
  final Color color;
  final List<FAQ> faqs;
}

class FAQ {

  FAQ({
    required this.question,
    required this.answer,
  });
  final String question;
  final String answer;
}