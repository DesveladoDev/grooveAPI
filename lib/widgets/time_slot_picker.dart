import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class TimeSlot {

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.price,
  });
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final double? price;
}

class TimeSlotPicker extends StatefulWidget {

  const TimeSlotPicker({
    required this.availableSlots, required this.onSlotSelected, super.key,
    this.selectedSlot,
    this.title,
  });
  final List<TimeSlot> availableSlots;
  final TimeSlot? selectedSlot;
  final Function(TimeSlot?) onSlotSelected;
  final String? title;

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<TimeSlot>('availableSlots', availableSlots));
    properties.add(DiagnosticsProperty<TimeSlot?>('selectedSlot', selectedSlot));
    properties.add(ObjectFlagProperty<Function(TimeSlot? p1)>.has('onSlotSelected', onSlotSelected));
    properties.add(StringProperty('title', title));
  }
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  TimeSlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.selectedSlot;
  }

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        if (widget.availableSlots.isEmpty)
          const Center(
            child: Text(
              'No hay horarios disponibles',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: widget.availableSlots.length,
            itemBuilder: (context, index) {
              final slot = widget.availableSlots[index];
              final isSelected = _selectedSlot == slot;
              
              return GestureDetector(
                onTap: slot.isAvailable
                    ? () {
                        setState(() {
                          _selectedSlot = isSelected ? null : slot;
                        });
                        widget.onSlotSelected(_selectedSlot);
                      }
                    : null,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: !slot.isAvailable
                        ? Colors.grey[200]
                        : isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                    border: Border.all(
                      color: !slot.isAvailable
                          ? Colors.grey[300]!
                          : isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[400]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}',
                          style: TextStyle(
                            color: !slot.isAvailable
                                ? Colors.grey[600]
                                : isSelected
                                    ? Colors.white
                                    : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        if (slot.price != null)
                          Text(
                            '\$${slot.price!.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: !slot.isAvailable
                                  ? Colors.grey[600]
                                  : isSelected
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );

  String _formatTime(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}