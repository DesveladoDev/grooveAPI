import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/models/booking.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/providers/booking_provider.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';
import 'package:share_plus/share_plus.dart';

class BookingConfirmationScreen extends StatefulWidget {
  
  const BookingConfirmationScreen({
    required this.data, super.key,
  });
  final Map<String, dynamic> data;
  
  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, dynamic>>('data', data));
  }
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  BookingModel get booking => widget.data['booking'] as BookingModel;
  ListingModel get listing => widget.data['listing'] as ListingModel;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.6, curve: Curves.elasticOut),
    ),);
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1, curve: Curves.easeInOut),
    ),);
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Animación de éxito
                    _buildSuccessAnimation(),
                    const SizedBox(height: 32),
                    
                    // Mensaje de confirmación
                    _buildConfirmationMessage(),
                    const SizedBox(height: 32),
                    
                    // Detalles de la reserva
                    _buildBookingDetails(),
                    const SizedBox(height: 24),
                    
                    // Información del anfitrión
                    _buildHostInfo(),
                    const SizedBox(height: 24),
                    
                    // Próximos pasos
                    _buildNextSteps(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Botones de acción
            _buildActionButtons(),
          ],
        ),
      ),
    );
  
  Widget _buildSuccessAnimation() => AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 60,
            ),
          ),
        ),
    );
  
  Widget _buildConfirmationMessage() => FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            '¡Reserva confirmada!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tu reserva ha sido confirmada exitosamente. Hemos enviado los detalles a tu email.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Text(
              'ID de reserva: ${booking.id.substring(0, 8).toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  
  Widget _buildBookingDetails() => FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalles de tu reserva',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Información del listing
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      listing.photos.isNotEmpty 
                          ? listing.photos.first // Using photos instead of images
                          : 'https://via.placeholder.com/60x60',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${listing.location.address}, ${listing.location.city}', // Using location instead of address
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Detalles de fecha y hora
              _buildDetailRow(
                icon: Icons.calendar_today, // Using IconData directly
                label: 'Fecha',
                value: DateFormat('EEEE, d MMMM yyyy', 'es').format(booking.startTime),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                  icon: Icons.access_time, // Using IconData directly
                label: 'Horario',
                value: '${TimeOfDay.fromDateTime(booking.startTime).format(context)} - ${TimeOfDay.fromDateTime(booking.endTime).format(context)}',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                  icon: Icons.group, // Using IconData directly
                label: 'Personas',
                value: '${booking.metadata?['guestCount'] ?? 1} personas', // Using metadata for guestCount
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                  icon: Icons.payment, // Using IconData directly
                label: 'Total pagado',
                value: '\$${booking.totalGuestPay.toStringAsFixed(2)}', // Using totalGuestPay instead of totalAmount
                valueColor: Colors.green[700],
              ),
              
              if (booking.metadata?['specialRequests'] != null) ...[ // Using metadata instead of specialRequests
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.note, // Using IconData directly
                  label: 'Solicitudes especiales',
                  value: booking.metadata!['specialRequests'] as String, // Using metadata instead of specialRequests
                  isMultiline: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMultiline = false,
  }) => Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  
  Widget _buildHostInfo() => FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu anfitrión',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      listing.hostId.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anfitrión verificado',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Responde en promedio en 1 hora',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.chatRoom, // Using chatRoom instead of conversation
                        arguments: {
                          'hostId': listing.hostId,
                          'bookingId': booking.id,
                        },
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  
  Widget _buildNextSteps() => FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Text(
                    'Próximos pasos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStepItem(
                '1. Revisa tu email para los detalles completos',
                Colors.blue[700]!,
              ),
              _buildStepItem(
                '2. Contacta al anfitrión si tienes preguntas',
                Colors.blue[700]!,
              ),
              _buildStepItem(
                '3. Llega puntual el día de tu reserva',
                Colors.blue[700]!,
              ),
              _buildStepItem(
                '4. Disfruta tu sesión musical',
                Colors.blue[700]!,
              ),
            ],
          ),
        ),
      ),
    );
  
  Widget _buildStepItem(String text, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: color,
        ),
      ),
    );
  
  Widget _buildActionButtons() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón principal
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Ver mis reservas',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home, // Using home route as fallback
                  (route) => route.settings.name == AppRoutes.home,
                );
              },
              icon: const Icon(Icons.calendar_today), // Wrapping IconData in Icon widget
            ),
          ),
          const SizedBox(height: 12),
          
          // Botones secundarios
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Compartir',
                  onPressed: _shareBooking,
                  isOutlined: true, // Using isOutlined instead of variant
                  icon: const Icon(Icons.share), // Wrapping IconData in Icon widget
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Chat',
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chatRoom, // Using chatRoom instead of conversation
                      arguments: {
                        'hostId': listing.hostId,
                        'bookingId': booking.id,
                      },
                    );
                  },
                  isOutlined: true, // Using isOutlined instead of variant
                  icon: const Icon(Icons.chat_bubble_outline), // Wrapping IconData in Icon widget
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Botón de inicio
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            },
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  
  void _shareBooking() {
    final shareText = '''
¡Reservé una sala en Salas & Beats! 🎵

Sala: ${listing.title}
Fecha: ${DateFormat('d MMM yyyy', 'es').format(booking.startTime)}
Horario: ${TimeOfDay.fromDateTime(booking.startTime).format(context)} - ${TimeOfDay.fromDateTime(booking.endTime).format(context)}
Ubicación: ${listing.location.address}, ${listing.location.city} // Using location instead of address

¡Descarga la app y encuentra tu sala perfecta!
''';
    
    Share.share(shareText);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BookingModel>('booking', booking));
    properties.add(DiagnosticsProperty<ListingModel>('listing', listing));
  }
}