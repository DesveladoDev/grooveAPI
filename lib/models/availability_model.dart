import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlot { // Razón si no está disponible

  TimeSlot({
    required this.start,
    required this.end,
    this.available = true,
    this.customPrice,
    this.reason,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) => TimeSlot(
      start: (map['start'] ?? '') as String,
      end: (map['end'] ?? '') as String,
      available: (map['available'] ?? true) as bool,
      customPrice: (map['customPrice'] as num?)?.toDouble(),
      reason: map['reason'] as String?,
    );
  final String start; // Formato HH:mm (ej: "09:00")
  final String end; // Formato HH:mm (ej: "10:00")
  final bool available;
  final double? customPrice; // Precio personalizado para este slot
  final String? reason;

  Map<String, dynamic> toMap() => {
      'start': start,
      'end': end,
      'available': available,
      'customPrice': customPrice,
      'reason': reason,
    };

  TimeSlot copyWith({
    String? start,
    String? end,
    bool? available,
    double? customPrice,
    String? reason,
  }) => TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
      available: available ?? this.available,
      customPrice: customPrice ?? this.customPrice,
      reason: reason ?? this.reason,
    );

  // Getters útiles
  String get timeRange => '$start - $end';
  bool get hasCustomPrice => customPrice != null;
  bool get isBlocked => !available;
  
  Duration get duration {
    final startParts = start.split(':');
    final endParts = end.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return Duration(minutes: endMinutes - startMinutes);
  }

  @override
  String toString() => 'TimeSlot(start: $start, end: $end, available: $available)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

class AvailabilityModel { // Información adicional

  AvailabilityModel({
    required this.id,
    required this.listingId,
    required this.date,
    required this.timeSlots,
    required this.createdAt,
    this.updatedAt,
    this.isBlocked = false,
    this.blockReason,
    this.metadata,
  });

  factory AvailabilityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return AvailabilityModel(
      id: doc.id,
      listingId: data['listingId'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeSlots: (data['timeSlots'] as List<dynamic>? ?? [])
          .map((slot) => TimeSlot.fromMap(slot as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isBlocked: data['isBlocked'] as bool? ?? false,
      blockReason: data['blockReason'] as String?,
      metadata: data['metadata'] != null ? Map<String, dynamic>.from(data['metadata'] as Map) : null,
    );
  }

  // Factory para crear disponibilidad por defecto
  factory AvailabilityModel.createDefault({
    required String listingId,
    required DateTime date,
    String startTime = '09:00',
    String endTime = '23:00',
    int slotDurationMinutes = 60,
  }) {
    final slots = <TimeSlot>[];
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    for (var minutes = startMinutes; minutes < endMinutes; minutes += slotDurationMinutes) {
      final slotStart = '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
      final slotEndMinutes = minutes + slotDurationMinutes;
      final slotEnd = '${(slotEndMinutes ~/ 60).toString().padLeft(2, '0')}:${(slotEndMinutes % 60).toString().padLeft(2, '0')}';
      
      slots.add(TimeSlot(
        start: slotStart,
        end: slotEnd,
      ),);
    }
    
    return AvailabilityModel(
      id: '', // Se asignará al guardar
      listingId: listingId,
      date: date,
      timeSlots: slots,
      createdAt: DateTime.now(),
    );
  }
  final String id;
  final String listingId;
  final DateTime date;
  final List<TimeSlot> timeSlots;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isBlocked; // Si todo el día está bloqueado
  final String? blockReason; // Razón del bloqueo
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toFirestore() => {
      'listingId': listingId,
      'date': Timestamp.fromDate(date),
      'timeSlots': timeSlots.map((slot) => slot.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isBlocked': isBlocked,
      'blockReason': blockReason,
      'metadata': metadata,
    };

  AvailabilityModel copyWith({
    String? id,
    String? listingId,
    DateTime? date,
    List<TimeSlot>? timeSlots,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBlocked,
    String? blockReason,
    Map<String, dynamic>? metadata,
  }) => AvailabilityModel(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      date: date ?? this.date,
      timeSlots: timeSlots ?? this.timeSlots,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      metadata: metadata ?? this.metadata,
    );

  // Métodos útiles
  List<TimeSlot> get availableSlots => timeSlots.where((slot) => slot.available).toList();
  List<TimeSlot> get blockedSlots => timeSlots.where((slot) => !slot.available).toList();
  
  bool get hasAvailableSlots => availableSlots.isNotEmpty && !isBlocked;
  int get totalSlots => timeSlots.length;
  int get availableSlotsCount => availableSlots.length;
  int get blockedSlotsCount => blockedSlots.length;
  
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  
  // Verificar si un rango de tiempo está disponible
  bool isTimeRangeAvailable(String startTime, String endTime) {
    if (isBlocked) return false;
    
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    for (final slot in timeSlots) {
      final slotStartParts = slot.start.split(':');
      final slotEndParts = slot.end.split(':');
      final slotStartMinutes = int.parse(slotStartParts[0]) * 60 + int.parse(slotStartParts[1]);
      final slotEndMinutes = int.parse(slotEndParts[0]) * 60 + int.parse(slotEndParts[1]);
      
      // Verificar si hay solapamiento
      if (startMinutes < slotEndMinutes && endMinutes > slotStartMinutes) {
        if (!slot.available) return false;
      }
    }
    
    return true;
  }
  
  // Bloquear un rango de tiempo
  AvailabilityModel blockTimeRange(String startTime, String endTime, {String? reason}) {
    final updatedSlots = timeSlots.map((slot) {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      final slotStartParts = slot.start.split(':');
      final slotEndParts = slot.end.split(':');
      final slotStartMinutes = int.parse(slotStartParts[0]) * 60 + int.parse(slotStartParts[1]);
      final slotEndMinutes = int.parse(slotEndParts[0]) * 60 + int.parse(slotEndParts[1]);
      
      // Verificar si hay solapamiento
      if (startMinutes < slotEndMinutes && endMinutes > slotStartMinutes) {
        return slot.copyWith(available: false, reason: reason);
      }
      
      return slot;
    }).toList();
    
    return copyWith(
      timeSlots: updatedSlots,
      updatedAt: DateTime.now(),
    );
  }
  
  // Liberar un rango de tiempo
  AvailabilityModel unblockTimeRange(String startTime, String endTime) {
    final updatedSlots = timeSlots.map((slot) {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      final slotStartParts = slot.start.split(':');
      final slotEndParts = slot.end.split(':');
      final slotStartMinutes = int.parse(slotStartParts[0]) * 60 + int.parse(slotStartParts[1]);
      final slotEndMinutes = int.parse(slotEndParts[0]) * 60 + int.parse(slotEndParts[1]);
      
      // Verificar si hay solapamiento
      if (startMinutes < slotEndMinutes && endMinutes > slotStartMinutes) {
        return slot.copyWith(available: true);
      }
      
      return slot;
    }).toList();
    
    return copyWith(
      timeSlots: updatedSlots,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() => 'AvailabilityModel(id: $id, listingId: $listingId, date: $formattedDate, slots: ${timeSlots.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvailabilityModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}