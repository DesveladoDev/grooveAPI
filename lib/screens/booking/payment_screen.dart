import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/models/booking_model.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/providers/booking_provider.dart';
import 'package:salas_beats/services/booking_service.dart';
import 'package:salas_beats/widgets/booking/payment_method_selector.dart';
import 'package:salas_beats/widgets/booking/price_breakdown.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';
import 'package:salas_beats/widgets/common/loading_overlay.dart';

class PaymentScreen extends StatefulWidget {
  
  const PaymentScreen({
    required this.bookingData, super.key,
  });
  final Map<String, dynamic> bookingData;
  
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, dynamic>>('bookingData', bookingData));
  }
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethodId;
  bool _acceptedTerms = false;
  bool _acceptedCancellationPolicy = false;
  
  ListingModel get listing => widget.bookingData['listing'] as ListingModel;
  DateTime get startTime => widget.bookingData['startTime'] as DateTime;
  DateTime get endTime => widget.bookingData['endTime'] as DateTime;
  int get guestCount => widget.bookingData['guestCount'] as int;
  String? get specialRequests => widget.bookingData['specialRequests'] as String?;
  PriceCalculation get priceCalculation => widget.bookingData['priceCalculation'] as PriceCalculation;
  
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar y Pagar'),
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) => LoadingOverlay(
            isLoading: bookingProvider.isCreatingBooking,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resumen de la reserva
                        _buildBookingSummary(),
                        const SizedBox(height: 24),
                        
                        // Desglose de precios
                        PriceBreakdown(
                          priceCalculation: priceCalculation,
                          showTitle: true,
                        ),
                        const SizedBox(height: 24),
                        
                        // Método de pago
                        _buildPaymentMethodSection(),
                        const SizedBox(height: 24),
                        
                        // Políticas y términos
                        _buildPoliciesSection(),
                        const SizedBox(height: 24),
                        
                        // Información importante
                        _buildImportantInfo(),
                      ],
                    ),
                  ),
                ),
                
                // Botón de pago fijo en la parte inferior
                _buildPaymentButton(bookingProvider),
              ],
            ),
          ),
      ),
    );
  
  Widget _buildBookingSummary() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de tu reserva',
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
            
            // Detalles de la reserva
            _buildSummaryRow(
              icon: Icons.calendar_today, // Using IconData directly
              label: 'Fecha',
              value: DateFormat('EEEE, d MMMM yyyy', 'es').format(startTime),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.access_time, // Using IconData directly
              label: 'Horario',
              value: '${TimeOfDay.fromDateTime(startTime).format(context)} - ${TimeOfDay.fromDateTime(endTime).format(context)}',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.group, // Using IconData directly
              label: 'Personas',
              value: '$guestCount ${guestCount == 1 ? 'persona' : 'personas'}',
            ),
            
            if (specialRequests != null) ...[
              const SizedBox(height: 12),
              _buildSummaryRow(
                icon: Icons.note, // Using IconData directly
                label: 'Solicitudes especiales',
                value: specialRequests!,
                isMultiline: true,
              ),
            ],
          ],
        ),
      ),
    );
  
  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  
  Widget _buildPaymentMethodSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de pago',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        PaymentMethodSelector(
          selectedPaymentMethodId: _selectedPaymentMethodId,
          onPaymentMethodSelected: (paymentMethodId) {
            setState(() {
              _selectedPaymentMethodId = paymentMethodId;
            });
          },
        ),
      ],
    );
  
  Widget _buildPoliciesSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Políticas y términos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Política de cancelación
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.policy, color: Colors.orange),
                    const SizedBox(width: 12),
                    Text(
                      'Política de cancelación',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  listing.cancellationPolicy.toString().split('.').last, // Converting enum to string
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedCancellationPolicy,
                      onChanged: (value) {
                        setState(() {
                          _acceptedCancellationPolicy = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Entiendo y acepto la política de cancelación',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Términos y condiciones
        Row(
          children: [
            Checkbox(
              value: _acceptedTerms,
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                });
              },
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: 'Acepto los '),
                    TextSpan(
                      text: 'términos y condiciones',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' y la '),
                    TextSpan(
                      text: 'política de privacidad',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' de Salas & Beats.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  
  Widget _buildImportantInfo() => Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Información importante',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              '• Tu reserva será confirmada inmediatamente después del pago.',
            ),
            _buildInfoItem(
              '• Recibirás un email de confirmación con todos los detalles.',
            ),
            _buildInfoItem(
              '• El anfitrión será notificado de tu reserva.',
            ),
            _buildInfoItem(
              '• Puedes contactar al anfitrión a través del chat de la app.',
            ),
            _buildInfoItem(
              '• Las cancelaciones están sujetas a la política del anfitrión.',
            ),
          ],
        ),
      ),
    );
  
  Widget _buildInfoItem(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.blue[700],
        ),
      ),
    );
  
  Widget _buildPaymentButton(BookingProvider bookingProvider) {
    final canPay = _selectedPaymentMethodId != null &&
                   _acceptedTerms &&
                   _acceptedCancellationPolicy;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
          // Total a pagar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total a pagar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${priceCalculation.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Botón de pago
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Confirmar y Pagar \$${priceCalculation.totalPrice.toStringAsFixed(2)}',
              onPressed: canPay ? () => _processPayment(bookingProvider) : null,
              isLoading: bookingProvider.isCreatingBooking,
              icon: const Icon(Icons.payment), // Wrapping IconData in Icon widget
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _processPayment(BookingProvider bookingProvider) async {
    if (_selectedPaymentMethodId == null) return;
    
    try {
      // Mostrar diálogo de confirmación
      final confirmed = await _showConfirmationDialog();
      if (!confirmed) return;
      
      // Crear la reserva
      final result = await bookingProvider.createBooking(
        listingId: listing.id,
        startTime: startTime,
        endTime: endTime,
        guestCount: guestCount,
        paymentMethodId: _selectedPaymentMethodId!,
        specialRequests: specialRequests,
        metadata: {
          'priceCalculation': priceCalculation.toJson(),
          'bookingSource': 'mobile_app',
        },
      );
      
      if (result.success && result.booking != null) {
        // Navegar a la pantalla de confirmación
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.bookingConfirmation,
          (route) => route.settings.name == AppRoutes.home,
          arguments: {
            'booking': result.booking,
            'listing': listing,
          },
        );
      } else {
        // Mostrar error
        _showErrorDialog(result.error ?? 'Error desconocido al procesar el pago');
      }
      
    } catch (e) {
      _showErrorDialog('Error al procesar el pago: $e');
    }
  }
  
  Future<bool> _showConfirmationDialog() async => await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que quieres confirmar esta reserva?'),
            const SizedBox(height: 16),
            Text(
              'Total: \$${priceCalculation.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${DateFormat('d MMM yyyy', 'es').format(startTime)}',
            ),
            Text(
              'Horario: ${TimeOfDay.fromDateTime(startTime).format(context)} - ${TimeOfDay.fromDateTime(endTime).format(context)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  
  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ListingModel>('listing', listing));
    properties.add(DiagnosticsProperty<DateTime>('startTime', startTime));
    properties.add(DiagnosticsProperty<DateTime>('endTime', endTime));
    properties.add(IntProperty('guestCount', guestCount));
    properties.add(StringProperty('specialRequests', specialRequests));
    properties.add(DiagnosticsProperty<PriceCalculation>('priceCalculation', priceCalculation));
  }
}