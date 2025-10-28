import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/models/booking.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/providers/auth_provider.dart';
import 'package:salas_beats/providers/booking_provider.dart';
import 'package:salas_beats/widgets/booking/guest_counter.dart';
import 'package:salas_beats/widgets/booking/price_breakdown.dart';
import 'package:salas_beats/widgets/booking/time_slot_picker.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';
import 'package:salas_beats/widgets/common/loading_overlay.dart';

class BookingScreen extends StatefulWidget {
  
  const BookingScreen({
    required this.listingId, super.key,
  });
  final String listingId;
  
  @override
  State<BookingScreen> createState() => _BookingScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('listingId', listingId));
  }
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _guestCount = 1;
  final TextEditingController _specialRequestsController = TextEditingController();
  
  bool _isAvailabilityChecked = false;
  bool _isAvailable = false;
  ListingModel? _listing;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _startTime = const TimeOfDay(hour: 10, minute: 0);
    _endTime = const TimeOfDay(hour: 12, minute: 0);
    _loadListing();
  }
  
  void _loadListing() {
    // Mock data - en producción se cargaría desde Firestore usando widget.listingId
    _listing = ListingModel(
      id: widget.listingId,
      hostId: 'host1',
      title: 'Estudio de Grabación Pro',
      description: 'Estudio profesional completamente equipado.',
      photos: ['https://example.com/studio1.jpg'],
      amenities: ['Micrófono profesional', 'Mesa de mezclas'],
      capacity: 8,
      hourlyPrice: 450,
      rules: ['No fumar dentro del estudio'],
      location: LocationData(
        lat: 19.4326,
        lng: -99.1332,
        address: 'Calle Álvaro Obregón 185, Roma Norte',
        city: 'Ciudad de México',
      ),
      cancellationPolicy: CancellationPolicy.flexible,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading || _listing == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reservar Sala'),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Sala'),
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) => LoadingOverlay(
            isLoading: bookingProvider.isCalculatingPrice,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del listing
                  _buildListingInfo(),
                  const SizedBox(height: 24),
                  
                  // Selección de fecha
                  _buildDateSelection(),
                  const SizedBox(height: 24),
                  
                  // Selección de horario
                  _buildTimeSelection(),
                  const SizedBox(height: 24),
                  
                  // Contador de huéspedes
                  _buildGuestCounter(),
                  const SizedBox(height: 24),
                  
                  // Verificación de disponibilidad
                  if (_isFormValid()) ...[
                    _buildAvailabilityCheck(bookingProvider),
                    const SizedBox(height: 24),
                  ],
                  
                  // Desglose de precios
                  if (_isAvailable && bookingProvider.currentPriceCalculation != null) ...[
                    PriceBreakdown(
                      priceCalculation: bookingProvider.currentPriceCalculation!,
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Solicitudes especiales
                  _buildSpecialRequests(),
                  const SizedBox(height: 24),
                  
                  // Políticas
                  _buildPolicies(),
                  const SizedBox(height: 32),
                  
                  // Botón de continuar
                  _buildContinueButton(bookingProvider),
                ],
              ),
            ),
          ),
      ),
    );
  }
  
  Widget _buildListingInfo() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _listing!.photos.isNotEmpty
                ? _listing!.photos.first // Using photos instead of images
                    : 'https://via.placeholder.com/80x80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _listing!.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_listing!.location.address}, ${_listing!.location.city}', // Using location instead of address
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_listing!.hourlyPrice.toStringAsFixed(0)}/hora',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildDateSelection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? DateFormat('EEEE, d MMMM yyyy', 'es').format(_selectedDate!)
                      : 'Seleccionar fecha',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  
  Widget _buildTimeSelection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horario',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTimeField(
                label: 'Hora de inicio',
                time: _startTime,
                onTap: () => _selectTime(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeField(
                label: 'Hora de fin',
                time: _endTime,
                onTap: () => _selectTime(false),
              ),
            ),
          ],
        ),
        if (_startTime != null && _endTime != null) ...[
          const SizedBox(height: 8),
          Text(
            'Duración: ${_calculateDuration()} horas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  
  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) => InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time?.format(context) ?? '--:--',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  
  Widget _buildGuestCounter() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Número de personas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GuestCounter(
          guestCount: _guestCount,
          maxGuests: _listing!.capacity,
          onChanged: (count) {
            setState(() {
              _guestCount = count;
              _isAvailabilityChecked = false;
            });
          },
        ),
      ],
    );
  
  Widget _buildAvailabilityCheck(BookingProvider bookingProvider) => Card(
      color: _isAvailable ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_isAvailabilityChecked) ...[
              CustomButton(
                text: 'Verificar Disponibilidad',
                onPressed: () => _checkAvailability(bookingProvider),
                isLoading: bookingProvider.isCalculatingPrice,
              ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    _isAvailable ? Icons.check_circle : Icons.info,
                    color: _isAvailable ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isAvailable 
                          ? '¡Disponible! La sala está libre en el horario seleccionado.'
                          : 'No disponible en este horario. Prueba con otra fecha u horario.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (!_isAvailable) ...[
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Verificar Nuevamente',
                  onPressed: () => _checkAvailability(bookingProvider),
                  isOutlined: true, // Using isOutlined instead of variant
                ),
              ],
            ],
          ],
        ),
      ),
    );
  
  Widget _buildSpecialRequests() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Solicitudes especiales (opcional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _specialRequestsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ej: Necesito acceso temprano, equipos adicionales, etc.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  
  Widget _buildPolicies() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Políticas importantes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPolicyItem(
              icon: Icons.schedule, // Using IconData directly
              title: 'Cancelación',
              description: _listing!.cancellationPolicy.toString().split('.').last, // Using cancellationPolicy directly
            ),
            const SizedBox(height: 8),
            _buildPolicyItem(
              icon: Icons.access_time, // Using IconData directly
              title: 'Check-in',
              description: 'Flexible - Horarios disponibles según disponibilidad', // Simplified description without policies
            ),
            const SizedBox(height: 8),
            _buildPolicyItem(
              icon: Icons.rule, // Using IconData directly
              title: 'Reglas de la casa',
              description: _listing!.rules.join(', '), // Using rules instead of policies.houseRules
            ),
          ],
        ),
      ),
    );
  
  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String description,
  }) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  
  Widget _buildContinueButton(BookingProvider bookingProvider) {
    final canContinue = _isFormValid() && _isAvailable && 
                       bookingProvider.currentPriceCalculation != null;
    
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Continuar con el Pago',
        onPressed: canContinue ? _proceedToPayment : null,
        isLoading: bookingProvider.isCreatingBooking,
      ),
    );
  }
  
  // Métodos de funcionalidad
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isAvailabilityChecked = false;
      });
    }
  }
  
  Future<void> _selectTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? (_startTime ?? const TimeOfDay(hour: 10, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 12, minute: 0)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Ajustar hora de fin si es necesario
          if (_endTime != null && _timeToMinutes(picked) >= _timeToMinutes(_endTime!)) {
            _endTime = TimeOfDay(
              hour: (picked.hour + 1) % 24,
              minute: picked.minute,
            );
          }
        } else {
          _endTime = picked;
          // Ajustar hora de inicio si es necesario
          if (_startTime != null && _timeToMinutes(_startTime!) >= _timeToMinutes(picked)) {
            _startTime = TimeOfDay(
              hour: picked.hour > 0 ? picked.hour - 1 : 23,
              minute: picked.minute,
            );
          }
        }
        _isAvailabilityChecked = false;
      });
    }
  }
  
  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;
  
  double _calculateDuration() {
    if (_startTime == null || _endTime == null) return 0;
    
    final startMinutes = _timeToMinutes(_startTime!);
    final endMinutes = _timeToMinutes(_endTime!);
    
    var duration = endMinutes - startMinutes;
    if (duration <= 0) duration += 24 * 60; // Manejar horarios que cruzan medianoche
    
    return duration / 60.0;
  }
  
  bool _isFormValid() => _selectedDate != null &&
           _startTime != null &&
           _endTime != null &&
           _guestCount > 0 &&
           _calculateDuration() > 0;
  
  Future<void> _checkAvailability(BookingProvider bookingProvider) async {
    if (!_isFormValid()) return;
    
    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    
    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    
    // Verificar disponibilidad
    final isAvailable = await bookingProvider.checkAvailability(
      listingId: _listing!.id,
      startTime: startDateTime,
      endTime: endDateTime,
    );
    
    setState(() {
      _isAvailable = isAvailable;
      _isAvailabilityChecked = true;
    });
    
    // Si está disponible, calcular precio
    if (isAvailable) {
      await bookingProvider.calculatePrice(
        listingId: _listing!.id,
        startTime: startDateTime,
        endTime: endDateTime,
        cityId: _listing!.location.city, // Using location instead of address
        guestCount: _guestCount,
      );
    }
  }
  
  void _proceedToPayment() {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    if (bookingProvider.currentPriceCalculation == null) return;
    
    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    
    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    
    context.go(
      AppRoutes.payment,
      extra: {
        'listing': _listing,
        'startTime': startDateTime,
        'endTime': endDateTime,
        'guestCount': _guestCount,
        'specialRequests': _specialRequestsController.text.trim().isNotEmpty 
            ? _specialRequestsController.text.trim() 
            : null,
        'priceCalculation': bookingProvider.currentPriceCalculation,
      },
    );
  }
}