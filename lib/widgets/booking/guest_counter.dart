import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class GuestCounter extends StatelessWidget {
  
  const GuestCounter({
    required this.guestCount, required this.maxGuests, required this.onChanged, super.key,
    this.minGuests = 1,
    this.label,
    this.description,
  });
  final int guestCount;
  final int maxGuests;
  final int minGuests;
  final ValueChanged<int> onChanged;
  final String? label;
  final String? description;
  
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...{
            Text(
              label!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          },
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Número de personas',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        'Máximo $maxGuests personas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Controles de contador
              Row(
                children: [
                  // Botón decrementar
                  _CounterButton(
                    icon: Icons.remove,
                    onPressed: guestCount > minGuests
                        ? () => onChanged(guestCount - 1)
                        : null,
                  ),
                  
                  // Número actual
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      guestCount.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Botón incrementar
                  _CounterButton(
                    icon: Icons.add,
                    onPressed: guestCount < maxGuests
                        ? () => onChanged(guestCount + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          
          // Indicador visual de capacidad
          const SizedBox(height: 12),
          _buildCapacityIndicator(context),
        ],
      ),
    );
  
  Widget _buildCapacityIndicator(BuildContext context) {
    final percentage = guestCount / maxGuests;
    Color indicatorColor;
    String statusText;
    
    if (percentage <= 0.5) {
      indicatorColor = Colors.green;
      statusText = 'Capacidad disponible';
    } else if (percentage <= 0.8) {
      indicatorColor = Colors.orange;
      statusText = 'Acercándose al límite';
    } else {
      indicatorColor = Colors.red;
      statusText = 'Cerca del máximo';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statusText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: indicatorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$guestCount/$maxGuests',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          minHeight: 4,
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('guestCount', guestCount));
    properties.add(IntProperty('maxGuests', maxGuests));
    properties.add(IntProperty('minGuests', minGuests));
    properties.add(ObjectFlagProperty<ValueChanged<int>>.has('onChanged', onChanged));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('description', description));
  }
}

class _CounterButton extends StatelessWidget {
  
  const _CounterButton({
    required this.icon,
    this.onPressed,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  
  @override
  Widget build(BuildContext context) => Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: onPressed != null ? Colors.grey[400]! : Colors.grey[300]!,
        ),
        color: onPressed != null ? Colors.white : Colors.grey[100],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: onPressed != null ? Colors.grey[700] : Colors.grey[400],
        ),
        padding: EdgeInsets.zero,
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }
}

// Widget más avanzado para múltiples tipos de huéspedes
class AdvancedGuestCounter extends StatefulWidget {
  
  const AdvancedGuestCounter({
    required this.guestCounts, required this.maxCounts, required this.labels, required this.onChanged, super.key,
    this.descriptions,
  });
  final Map<String, int> guestCounts;
  final Map<String, int> maxCounts;
  final Map<String, String> labels;
  final Map<String, String>? descriptions;
  final ValueChanged<Map<String, int>> onChanged;
  
  @override
  State<AdvancedGuestCounter> createState() => _AdvancedGuestCounterState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, int>>('guestCounts', guestCounts));
    properties.add(DiagnosticsProperty<Map<String, int>>('maxCounts', maxCounts));
    properties.add(DiagnosticsProperty<Map<String, String>>('labels', labels));
    properties.add(DiagnosticsProperty<Map<String, String>?>('descriptions', descriptions));
    properties.add(ObjectFlagProperty<ValueChanged<Map<String, int>>>.has('onChanged', onChanged));
  }
}

class _AdvancedGuestCounterState extends State<AdvancedGuestCounter> {
  late Map<String, int> _currentCounts;
  
  @override
  void initState() {
    super.initState();
    _currentCounts = Map.from(widget.guestCounts);
  }
  
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Número de personas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de contadores por tipo
          ...widget.labels.entries.map((entry) {
            final key = entry.key;
            final label = entry.value;
            final count = _currentCounts[key] ?? 0;
            final maxCount = widget.maxCounts[key] ?? 0;
            final description = widget.descriptions?[key];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildGuestTypeRow(
                key: key,
                label: label,
                description: description,
                count: count,
                maxCount: maxCount,
              ),
            );
          }),
          
          // Resumen total
          _buildTotalSummary(),
        ],
      ),
    );
  
  Widget _buildGuestTypeRow({
    required String key,
    required String label,
    required int count, required int maxCount, String? description,
  }) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Controles
        Row(
          children: [
            _CounterButton(
              icon: Icons.remove,
              onPressed: count > 0
                  ? () => _updateCount(key, count - 1)
                  : null,
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _CounterButton(
              icon: Icons.add,
              onPressed: count < maxCount
                  ? () => _updateCount(key, count + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  
  Widget _buildTotalSummary() {
    final totalGuests = _currentCounts.values.fold(0, (sum, count) => sum + count);
    final maxTotal = widget.maxCounts.values.fold(0, (sum, max) => sum + max);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total de personas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$totalGuests (máx. $maxTotal)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  void _updateCount(String key, int newCount) {
    setState(() {
      _currentCounts[key] = newCount;
    });
    widget.onChanged(_currentCounts);
  }
}