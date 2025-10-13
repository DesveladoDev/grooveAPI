import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/models/booking.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';

class AvailabilityWidget extends StatefulWidget {
  
  const AvailabilityWidget({
    required this.listingId, required this.selectedDate, required this.onTimeSlotSelected, super.key,
    this.selectedTimeSlot,
    this.isLoading = false,
  });
  final String listingId;
  final DateTime selectedDate;
  final ValueChanged<TimeSlot?> onTimeSlotSelected;
  final TimeSlot? selectedTimeSlot;
  final bool isLoading;
  
  @override
  State<AvailabilityWidget> createState() => _AvailabilityWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('listingId', listingId));
    properties.add(DiagnosticsProperty<DateTime>('selectedDate', selectedDate));
    properties.add(ObjectFlagProperty<ValueChanged<TimeSlot?>>.has('onTimeSlotSelected', onTimeSlotSelected));
    properties.add(DiagnosticsProperty<TimeSlot?>('selectedTimeSlot', selectedTimeSlot));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
  }
}

class _AvailabilityWidgetState extends State<AvailabilityWidget> {
  List<TimeSlot> _availableSlots = [];
  bool _isLoadingSlots = false;
  
  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }
  
  @override
  void didUpdateWidget(AvailabilityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.listingId != widget.listingId) {
      _loadAvailableSlots();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading || _isLoadingSlots) {
      return _buildLoadingState();
    }
    
    if (_availableSlots.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(),
        const SizedBox(height: AppConstants.defaultSpacing),
        
        // Horarios disponibles
        _buildTimeSlots(),
        
        // Información adicional
        const SizedBox(height: AppConstants.defaultSpacing),
        _buildAdditionalInfo(),
      ],
    );
  }
  
  Widget _buildHeader() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horarios disponibles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatSelectedDate(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: _loadAvailableSlots,
          icon: const Icon(Icons.refresh),
          tooltip: 'Actualizar disponibilidad',
        ),
      ],
    );
  
  Widget _buildTimeSlots() {
    // Agrupar slots por período del día
    final groupedSlots = _groupSlotsByPeriod();
    
    return Column(
      children: groupedSlots.entries.map((entry) => _buildPeriodSection(entry.key, entry.value)).toList(),
    );
  }
  
  Widget _buildPeriodSection(String period, List<TimeSlot> slots) => Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del período
            Row(
              children: [
                Icon(
                  _getPeriodIcon(period),
                  size: AppConstants.defaultIconSize,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: AppConstants.smallSpacing),
                Text(
                  period,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${slots.length} disponibles',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            
            // Grid de horarios
            Wrap(
              spacing: AppConstants.smallSpacing,
              runSpacing: AppConstants.smallSpacing,
              children: slots.map(_buildTimeSlotChip).toList(),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildTimeSlotChip(TimeSlot slot) {
    final isSelected = widget.selectedTimeSlot?.id == slot.id;
    final isAvailable = slot.isAvailable;
    
    return InkWell(
      onTap: isAvailable ? () => widget.onTimeSlotSelected(slot) : null,
      borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _getSlotColor(slot, isSelected),
          border: Border.all(
            color: _getSlotBorderColor(slot, isSelected),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getSlotTextColor(slot, isSelected),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (slot.price != null) ...[
              const SizedBox(width: AppConstants.smallSpacing),
              Text(
                '\$${slot.price!.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getSlotTextColor(slot, isSelected),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (!isAvailable) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.lock,
                size: AppConstants.smallIconSize,
                color: Colors.grey[600],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdditionalInfo() => Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: AppConstants.smallSpacing),
                Text(
                  'Información importante',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            
            _buildInfoItem(
              icon: Icons.access_time,
              text: 'Los horarios se muestran en tu zona horaria local',
            ),
            _buildInfoItem(
              icon: Icons.event_busy,
              text: 'Las reservas deben hacerse con al menos 2 horas de anticipación',
            ),
            _buildInfoItem(
              icon: Icons.cancel,
              text: 'Cancelación gratuita hasta 24 horas antes',
            ),
          ],
        ),
      ),
    );
  
  Widget _buildInfoItem({required IconData icon, required String text}) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: AppConstants.smallSpacing),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  
  Widget _buildLoadingState() => Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              'Cargando disponibilidad...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  
  Widget _buildEmptyState() => Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              'No hay horarios disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              'Intenta seleccionar otra fecha o contacta al anfitrión para más opciones.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            CustomButton(
              text: 'Contactar anfitrión',
              onPressed: _contactHost,
              isOutlined: true,
              icon: const Icon(Icons.message),
            ),
          ],
        ),
      ),
    );
  
  // Métodos de funcionalidad
  Future<void> _loadAvailableSlots() async {
    setState(() {
      _isLoadingSlots = true;
    });
    
    try {
      // TODO: Implementar carga real desde el servicio
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Datos mock
      _availableSlots = _generateMockSlots();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar disponibilidad: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingSlots = false;
      });
    }
  }
  
  List<TimeSlot> _generateMockSlots() {
    final slots = <TimeSlot>[];
    final random = DateTime.now().millisecond;
    
    // Horarios de mañana
    for (var hour = 9; hour <= 12; hour++) {
      slots.add(TimeSlot(
        id: 'slot_${hour}_00',
        startTime: TimeOfDay(hour: hour, minute: 0),
        endTime: TimeOfDay(hour: hour + 1, minute: 0),
        isAvailable: (hour + random) % 3 != 0,
        price: 50.0 + (hour - 9) * 10,
      ),);
    }
    
    // Horarios de tarde
    for (var hour = 14; hour <= 18; hour++) {
      slots.add(TimeSlot(
        id: 'slot_${hour}_00',
        startTime: TimeOfDay(hour: hour, minute: 0),
        endTime: TimeOfDay(hour: hour + 1, minute: 0),
        isAvailable: (hour + random) % 4 != 0,
        price: 60.0 + (hour - 14) * 5,
      ),);
    }
    
    // Horarios de noche
    for (var hour = 19; hour <= 22; hour++) {
      slots.add(TimeSlot(
        id: 'slot_${hour}_00',
        startTime: TimeOfDay(hour: hour, minute: 0),
        endTime: TimeOfDay(hour: hour + 1, minute: 0),
        isAvailable: (hour + random) % 2 != 0,
        price: 70.0 + (hour - 19) * 8,
      ),);
    }
    
    return slots;
  }
  
  Map<String, List<TimeSlot>> _groupSlotsByPeriod() {
    final grouped = <String, List<TimeSlot>>{};
    
    for (final slot in _availableSlots) {
      final period = _getPeriodForTime(slot.startTime);
      grouped.putIfAbsent(period, () => []).add(slot);
    }
    
    return grouped;
  }
  
  String _getPeriodForTime(TimeOfDay time) {
    if (time.hour >= 6 && time.hour < 12) {
      return 'Mañana';
    } else if (time.hour >= 12 && time.hour < 18) {
      return 'Tarde';
    } else {
      return 'Noche';
    }
  }
  
  IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'Mañana':
        return Icons.wb_sunny;
      case 'Tarde':
        return Icons.wb_cloudy;
      case 'Noche':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
  
  Color _getSlotColor(TimeSlot slot, bool isSelected) {
    if (!slot.isAvailable) {
      return Colors.grey[100]!;
    }
    if (isSelected) {
      return Theme.of(context).primaryColor;
    }
    return Colors.white;
  }
  
  /// Determines the border color for a time slot based on its state
  /// 
  /// Returns appropriate color for:
  /// - Unavailable slots: light grey
  /// - Selected slots: primary theme color
  /// - Available slots: default grey
  Color _getSlotBorderColor(TimeSlot slot, bool isSelected) {
    if (!slot.isAvailable) {
      return Colors.grey[300]!;
    }
    if (isSelected) {
      return Theme.of(context).primaryColor;
    }
    return Colors.grey[300]!;
  }
  
  /// Determines the text color for a time slot based on its state
  /// 
  /// Returns appropriate color for:
  /// - Unavailable slots: muted grey
  /// - Selected slots: white (for contrast)
  /// - Available slots: black
  Color _getSlotTextColor(TimeSlot slot, bool isSelected) {
    if (!slot.isAvailable) {
      return Colors.grey[500]!;
    }
    if (isSelected) {
      return Colors.white;
    }
    return Colors.black;
  }
  
  /// Formats the selected date in Spanish locale
  /// 
  /// Returns a formatted string like "Lunes, 15 de Enero"
  String _formatSelectedDate() {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    
    const weekdays = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
    ];
    
    final weekday = weekdays[widget.selectedDate.weekday - 1];
    final day = widget.selectedDate.day;
    final month = months[widget.selectedDate.month - 1];
    
    return '$weekday, $day de $month';
  }
  
  void _contactHost() {
    // TODO: Implementar navegación al chat con el anfitrión
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de contacto en desarrollo'),
      ),
    );
  }
}

// Modelo para slots de tiempo
class TimeSlot {
  
  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.price,
    this.note,
  });
  final String id;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAvailable;
  final double? price;
  final String? note;
  
  Duration get duration {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return Duration(minutes: endMinutes - startMinutes);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

// Widget compacto para mostrar disponibilidad rápida
class QuickAvailabilityIndicator extends StatelessWidget {
  
  const QuickAvailabilityIndicator({
    required this.listingId, required this.date, super.key,
    this.onTap,
  });
  final String listingId;
  final DateTime date;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border.all(color: Colors.green[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: Colors.green[600],
            ),
            const SizedBox(width: 4),
            Text(
              'Disponible',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('listingId', listingId));
    properties.add(DiagnosticsProperty<DateTime>('date', date));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}