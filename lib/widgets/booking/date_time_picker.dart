import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';
import 'package:table_calendar/table_calendar.dart';

class DateTimePicker extends StatefulWidget {
  
  const DateTimePicker({
    required this.onStartDateChanged, required this.onEndDateChanged, required this.onStartTimeChanged, required this.onEndTimeChanged, super.key,
    this.selectedStartDate,
    this.selectedEndDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.unavailableDates = const [],
    this.allowSameDay = true,
    this.minimumDuration,
    this.maximumDuration,
  });
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final TimeOfDay? selectedStartTime;
  final TimeOfDay? selectedEndTime;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final ValueChanged<TimeOfDay?> onStartTimeChanged;
  final ValueChanged<TimeOfDay?> onEndTimeChanged;
  final List<DateTime> unavailableDates;
  final bool allowSameDay;
  final Duration? minimumDuration;
  final Duration? maximumDuration;
  
  @override
  State<DateTimePicker> createState() => _DateTimePickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime?>('selectedStartDate', selectedStartDate));
    properties.add(DiagnosticsProperty<DateTime?>('selectedEndDate', selectedEndDate));
    properties.add(DiagnosticsProperty<TimeOfDay?>('selectedStartTime', selectedStartTime));
    properties.add(DiagnosticsProperty<TimeOfDay?>('selectedEndTime', selectedEndTime));
    properties.add(ObjectFlagProperty<ValueChanged<DateTime?>>.has('onStartDateChanged', onStartDateChanged));
    properties.add(ObjectFlagProperty<ValueChanged<DateTime?>>.has('onEndDateChanged', onEndDateChanged));
    properties.add(ObjectFlagProperty<ValueChanged<TimeOfDay?>>.has('onStartTimeChanged', onStartTimeChanged));
    properties.add(ObjectFlagProperty<ValueChanged<TimeOfDay?>>.has('onEndTimeChanged', onEndTimeChanged));
    properties.add(IterableProperty<DateTime>('unavailableDates', unavailableDates));
    properties.add(DiagnosticsProperty<bool>('allowSameDay', allowSameDay));
    properties.add(DiagnosticsProperty<Duration?>('minimumDuration', minimumDuration));
    properties.add(DiagnosticsProperty<Duration?>('maximumDuration', maximumDuration));
  }
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  
  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }
  
  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          'Selecciona fechas y horarios',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Calendario
        _buildCalendar(),
        const SizedBox(height: 24),
        
        // Selección de horarios
        if (widget.selectedStartDate != null) ...[
          _buildTimeSelection(),
          const SizedBox(height: 16),
        ],
        
        // Resumen de selección
        if (widget.selectedStartDate != null) _buildSelectionSummary(),
      ],
    );
  
  Widget _buildCalendar() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar<DateTime>(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          
          // Fechas seleccionadas
          selectedDayPredicate: (day) => isSameDay(widget.selectedStartDate, day),
          
          rangeStartDay: widget.selectedStartDate,
          rangeEndDay: widget.selectedEndDate,
          
          // Callbacks
          onDaySelected: _onDaySelected,
          onRangeSelected: _onRangeSelected,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          
          // Configuración de disponibilidad
          enabledDayPredicate: (day) => !widget.unavailableDates.any((unavailable) => 
                isSameDay(day, unavailable),),
          
          // Estilos
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            holidayTextStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            
            // Días seleccionados
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            
            // Rango seleccionado
            rangeStartDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            rangeEndDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            rangeHighlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
            
            // Días no disponibles
            disabledDecoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            disabledTextStyle: TextStyle(
              color: Colors.grey[500],
            ),
            
            // Día de hoy
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            formatButtonTextStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  
  Widget _buildTimeSelection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horarios',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Hora de inicio
                Expanded(
                  child: _buildTimeSelector(
                    label: 'Hora de inicio',
                    selectedTime: widget.selectedStartTime,
                    onTimeSelected: widget.onStartTimeChanged,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Hora de fin
                Expanded(
                  child: _buildTimeSelector(
                    label: 'Hora de fin',
                    selectedTime: widget.selectedEndTime,
                    onTimeSelected: widget.onEndTimeChanged,
                  ),
                ),
              ],
            ),
            
            // Horarios sugeridos
            const SizedBox(height: 16),
            _buildSuggestedTimes(),
          ],
        ),
      ),
    );
  
  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay? selectedTime,
    required ValueChanged<TimeOfDay?> onTimeSelected,
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(onTimeSelected),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTime?.format(context) ?? 'Seleccionar',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selectedTime != null 
                        ? Colors.black 
                        : Colors.grey[600],
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  
  Widget _buildSuggestedTimes() {
    final suggestedTimes = [
      {'label': 'Mañana', 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 12, minute: 0)},
      {'label': 'Tarde', 'start': const TimeOfDay(hour: 14, minute: 0), 'end': const TimeOfDay(hour: 18, minute: 0)},
      {'label': 'Noche', 'start': const TimeOfDay(hour: 19, minute: 0), 'end': const TimeOfDay(hour: 23, minute: 0)},
      {'label': 'Todo el día', 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 22, minute: 0)},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horarios sugeridos',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestedTimes.map((timeSlot) => InkWell(
              onTap: () {
                widget.onStartTimeChanged(timeSlot['start']! as TimeOfDay);
                widget.onEndTimeChanged(timeSlot['end']! as TimeOfDay);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  timeSlot['label']! as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),).toList(),
        ),
      ],
    );
  }
  
  Widget _buildSelectionSummary() {
    if (widget.selectedStartDate == null) return const SizedBox.shrink();
    
    final duration = _calculateDuration();
    
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumen de reserva',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Fecha
            _buildSummaryRow(
              icon: Icons.calendar_today,
              label: 'Fecha',
              value: _formatDateRange(),
            ),
            
            // Horario
            if (widget.selectedStartTime != null && widget.selectedEndTime != null)
              _buildSummaryRow(
                icon: Icons.access_time,
                label: 'Horario',
                value: '${widget.selectedStartTime!.format(context)} - ${widget.selectedEndTime!.format(context)}',
              ),
            
            // Duración
            if (duration != null)
              _buildSummaryRow(
                icon: Icons.timer,
                label: 'Duración',
                value: _formatDuration(duration),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  
  // Métodos de funcionalidad
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(widget.selectedStartDate, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      
      widget.onStartDateChanged(selectedDay);
      widget.onEndDateChanged(null);
    }
  }
  
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
    
    widget.onStartDateChanged(start);
    widget.onEndDateChanged(end);
  }
  
  Future<void> _selectTime(ValueChanged<TimeOfDay?> onTimeSelected) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        ),
    );
    
    if (picked != null) {
      onTimeSelected(picked);
    }
  }
  
  String _formatDateRange() {
    if (widget.selectedStartDate == null) return '';
    
    final startDate = widget.selectedStartDate!;
    final endDate = widget.selectedEndDate;
    
    if (endDate == null || isSameDay(startDate, endDate)) {
      return _formatDate(startDate);
    }
    
    return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  Duration? _calculateDuration() {
    if (widget.selectedStartTime == null || widget.selectedEndTime == null) {
      return null;
    }
    
    final startMinutes = widget.selectedStartTime!.hour * 60 + widget.selectedStartTime!.minute;
    final endMinutes = widget.selectedEndTime!.hour * 60 + widget.selectedEndTime!.minute;
    
    var durationMinutes = endMinutes - startMinutes;
    if (durationMinutes < 0) {
      durationMinutes += 24 * 60; // Agregar 24 horas si cruza medianoche
    }
    
    return Duration(minutes: durationMinutes);
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }
}

// Widget simplificado para selección rápida de fechas
class QuickDatePicker extends StatelessWidget {
  
  const QuickDatePicker({
    required this.onDateChanged, super.key,
    this.selectedDate,
    this.label = 'Seleccionar fecha',
    this.unavailableDates = const [],
  });
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;
  final String label;
  final List<DateTime> unavailableDates;
  
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: () => _showDatePicker(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null 
                  ? _formatDate(selectedDate!)
                  : label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: selectedDate != null 
                    ? Colors.black 
                    : Colors.grey[600],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  
  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (day) => !unavailableDates.any((unavailable) => 
            isSameDay(day, unavailable),),
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        ),
    );
    
    if (picked != null) {
      onDateChanged(picked);
    }
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime?>('selectedDate', selectedDate));
    properties.add(ObjectFlagProperty<ValueChanged<DateTime?>>.has('onDateChanged', onDateChanged));
    properties.add(StringProperty('label', label));
    properties.add(IterableProperty<DateTime>('unavailableDates', unavailableDates));
  }
}