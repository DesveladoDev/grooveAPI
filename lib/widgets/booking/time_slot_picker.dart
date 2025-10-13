import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/booking.dart';
import 'package:salas_beats/utils/formatters.dart';

class TimeSlotPicker extends StatefulWidget {

  const TimeSlotPicker({
    required this.availableSlots, required this.onSlotSelected, required this.selectedDate, super.key,
    this.selectedSlot,
    this.isLoading = false,
  });
  final List<TimeSlot> availableSlots;
  final TimeSlot? selectedSlot;
  final Function(TimeSlot?) onSlotSelected;
  final bool isLoading;
  final DateTime selectedDate;

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<TimeSlot>('availableSlots', availableSlots));
    properties.add(DiagnosticsProperty<TimeSlot?>('selectedSlot', selectedSlot));
    properties.add(ObjectFlagProperty<Function(TimeSlot? p1)>.has('onSlotSelected', onSlotSelected));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(DiagnosticsProperty<DateTime>('selectedDate', selectedDate));
  }
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horarios disponibles para ${Formatters.formatDate(widget.selectedDate)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (widget.availableSlots.isEmpty)
          _buildEmptyState()
        else
          _buildTimeSlotGrid(),
      ],
    );

  Widget _buildEmptyState() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay horarios disponibles',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona otra fecha para ver horarios disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  Widget _buildTimeSlotGrid() => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.availableSlots.length,
      itemBuilder: (context, index) {
        final slot = widget.availableSlots[index];
        return _buildTimeSlotCard(slot);
      },
    );

  Widget _buildTimeSlotCard(TimeSlot slot) {
    final isSelected = widget.selectedSlot?.id == slot.id;
    final isAvailable = slot.isAvailable;
    
    return GestureDetector(
      onTap: isAvailable ? () => widget.onSlotSelected(slot) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _getSlotColor(slot, isSelected),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getSlotBorderColor(slot, isSelected),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Formatters.formatTime(slot.startTime),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getSlotTextColor(slot, isSelected),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatTime(slot.endTime),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getSlotTextColor(slot, isSelected).withOpacity(0.7),
              ),
            ),
            if (slot.price != null) ...[
              const SizedBox(height: 4),
              Text(
                Formatters.formatCurrency(slot.price!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getSlotTextColor(slot, isSelected),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSlotColor(TimeSlot slot, bool isSelected) {
    if (!slot.isAvailable) {
      return Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3);
    }
    
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }
    
    return Theme.of(context).colorScheme.surface;
  }

  Color _getSlotBorderColor(TimeSlot slot, bool isSelected) {
    if (!slot.isAvailable) {
      return Theme.of(context).colorScheme.outline.withOpacity(0.3);
    }
    
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }
    
    return Theme.of(context).colorScheme.outline.withOpacity(0.5);
  }

  Color _getSlotTextColor(TimeSlot slot, bool isSelected) {
    if (!slot.isAvailable) {
      return Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5);
    }
    
    if (isSelected) {
      return Theme.of(context).colorScheme.onPrimary;
    }
    
    return Theme.of(context).colorScheme.onSurface;
  }
}

class TimeSlot {

  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.price,
    this.description,
    this.metadata,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
      price: (json['price'] as num?)?.toDouble(),
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final double? price;
  final String? description;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      'price': price,
      'description': description,
      'metadata': metadata,
    };

  Duration get duration => endTime.difference(startTime);

  bool get isPast => DateTime.now().isAfter(endTime);
  
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
           startTime.month == now.month &&
           startTime.day == now.day;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TimeSlot(id: $id, startTime: $startTime, endTime: $endTime, isAvailable: $isAvailable)';
}