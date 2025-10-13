import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/models/notification_model.dart';

class NotificationFilters extends StatefulWidget {

  const NotificationFilters({
    required this.searchQuery, required this.onTypeChanged, required this.onReadStatusChanged, required this.onPriorityChanged, required this.onSearchChanged, required this.onClearFilters, super.key,
    this.selectedType,
    this.isRead,
    this.selectedPriority,
  });
  final String? selectedType;
  final bool? isRead;
  final NotificationPriority? selectedPriority;
  final String searchQuery;
  final Function(String?) onTypeChanged;
  final Function(bool?) onReadStatusChanged;
  final Function(NotificationPriority?) onPriorityChanged;
  final Function(String) onSearchChanged;
  final VoidCallback onClearFilters;

  @override
  State<NotificationFilters> createState() => _NotificationFiltersState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('selectedType', selectedType));
    properties.add(DiagnosticsProperty<bool?>('isRead', isRead));
    properties.add(EnumProperty<NotificationPriority?>('selectedPriority', selectedPriority));
    properties.add(StringProperty('searchQuery', searchQuery));
    properties.add(ObjectFlagProperty<Function(String? p1)>.has('onTypeChanged', onTypeChanged));
    properties.add(ObjectFlagProperty<Function(bool? p1)>.has('onReadStatusChanged', onReadStatusChanged));
    properties.add(ObjectFlagProperty<Function(NotificationPriority? p1)>.has('onPriorityChanged', onPriorityChanged));
    properties.add(ObjectFlagProperty<Function(String p1)>.has('onSearchChanged', onSearchChanged));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onClearFilters', onClearFilters));
  }
}

class _NotificationFiltersState extends State<NotificationFilters> {
  late TextEditingController _searchController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(theme),
            const SizedBox(height: AppConstants.defaultSpacing),
            _buildQuickFilters(theme),
            if (_isExpanded) ...[
              const SizedBox(height: AppConstants.defaultSpacing),
              _buildAdvancedFilters(theme),
            ],
            const SizedBox(height: AppConstants.smallSpacing),
            _buildFilterActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) => TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar notificaciones...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallSpacing),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      onChanged: widget.onSearchChanged,
    );

  Widget _buildQuickFilters(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros rápidos',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: AppConstants.smallSpacing,
          runSpacing: AppConstants.smallSpacing,
          children: [
            _buildFilterChip(
              label: 'No leídas',
              isSelected: widget.isRead == false,
              onTap: () => widget.onReadStatusChanged(
                widget.isRead == false ? null : false,
              ),
              icon: Icons.mark_email_unread,
            ),
            _buildFilterChip(
              label: 'Leídas',
              isSelected: widget.isRead ?? false,
              onTap: () => widget.onReadStatusChanged(
                widget.isRead ?? false ? null : true,
              ),
              icon: Icons.mark_email_read,
            ),
            _buildFilterChip(
              label: 'Alta prioridad',
              isSelected: widget.selectedPriority == NotificationPriority.high,
              onTap: () => widget.onPriorityChanged(
                widget.selectedPriority == NotificationPriority.high
                    ? null
                    : NotificationPriority.high,
              ),
              icon: Icons.priority_high,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );

  Widget _buildAdvancedFilters(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros avanzados',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        
        // Filtro por tipo
        _buildTypeFilter(theme),
        const SizedBox(height: AppConstants.defaultSpacing),
        
        // Filtro por prioridad
        _buildPriorityFilter(theme),
      ],
    );

  Widget _buildTypeFilter(ThemeData theme) {
    final types = [
      {'value': null, 'label': 'Todos los tipos', 'icon': Icons.all_inclusive},
      {'value': 'booking', 'label': 'Reservas', 'icon': Icons.event_available},
      {'value': 'payment', 'label': 'Pagos', 'icon': Icons.payment},
      {'value': 'chat', 'label': 'Mensajes', 'icon': Icons.chat},
      {'value': 'review', 'label': 'Reseñas', 'icon': Icons.star},
      {'value': 'host', 'label': 'Anfitrión', 'icon': Icons.home},
      {'value': 'system', 'label': 'Sistema', 'icon': Icons.settings},
      {'value': 'promotion', 'label': 'Promociones', 'icon': Icons.local_offer},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de notificación',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: AppConstants.smallSpacing,
          runSpacing: AppConstants.smallSpacing,
          children: types.map((type) {
            final isSelected = widget.selectedType == type['value'];
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type['icon']! as IconData,
                    size: AppConstants.smallIconSize,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(type['label']! as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                widget.onTypeChanged(
                  selected ? type['value'] as String? : null,
                );
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: theme.colorScheme.onPrimary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriorityFilter(ThemeData theme) {
    final priorities = [
      {'value': null, 'label': 'Todas las prioridades', 'color': Colors.grey},
      {'value': NotificationPriority.low, 'label': 'Baja', 'color': Colors.green},
      {'value': NotificationPriority.medium, 'label': 'Normal', 'color': Colors.blue},
      {'value': NotificationPriority.high, 'label': 'Alta', 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioridad',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: AppConstants.smallSpacing,
          runSpacing: AppConstants.smallSpacing,
          children: priorities.map((priority) {
            final isSelected = widget.selectedPriority == priority['value'];
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppConstants.smallSpacing,
                    height: AppConstants.smallSpacing,
                    decoration: BoxDecoration(
                      color: priority['color']! as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(priority['label']! as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                widget.onPriorityChanged(
                  selected ? priority['value'] as NotificationPriority? : null,
                );
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: theme.colorScheme.onPrimary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? color,
  }) {
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppConstants.smallIconSize,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : color ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: color ?? theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
    );
  }

  Widget _buildFilterActions(ThemeData theme) {
    final hasActiveFilters = widget.selectedType != null ||
        widget.isRead != null ||
        widget.selectedPriority != null ||
        widget.searchQuery.isNotEmpty;

    return Row(
      children: [
        // Botón expandir/contraer
        TextButton.icon(
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          icon: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
          ),
          label: Text(_isExpanded ? 'Menos filtros' : 'Más filtros'),
        ),
        
        const Spacer(),
        
        // Botón limpiar filtros
        if (hasActiveFilters)
          TextButton.icon(
            onPressed: widget.onClearFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpiar'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}

/// Widget para mostrar estadísticas de filtros aplicados
class FilterStats extends StatelessWidget {

  const FilterStats({
    required this.totalNotifications, required this.filteredNotifications, required this.unreadCount, required this.typeCount, super.key,
  });
  final int totalNotifications;
  final int filteredNotifications;
  final int unreadCount;
  final Map<String, int> typeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          // Estadísticas principales
          Row(
            children: [
              _buildStatItem(
                theme,
                'Total',
                totalNotifications.toString(),
                Icons.notifications,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                theme,
                'Filtradas',
                filteredNotifications.toString(),
                Icons.filter_list,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                theme,
                'No leídas',
                unreadCount.toString(),
                Icons.mark_email_unread,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          
          // Distribución por tipo
          if (typeCount.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Por tipo',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: typeCount.entries.map((entry) => Chip(
                  label: Text(
                    '${_getTypeDisplayName(entry.key)}: ${entry.value}',
                    style: theme.textTheme.bodySmall,
                  ),
                  backgroundColor: theme.colorScheme.surface,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) => Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'booking':
        return 'Reservas';
      case 'payment':
        return 'Pagos';
      case 'chat':
        return 'Mensajes';
      case 'review':
        return 'Reseñas';
      case 'host':
        return 'Anfitrión';
      case 'system':
        return 'Sistema';
      case 'promotion':
        return 'Promociones';
      default:
        return type;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('totalNotifications', totalNotifications));
    properties.add(IntProperty('filteredNotifications', filteredNotifications));
    properties.add(IntProperty('unreadCount', unreadCount));
    properties.add(DiagnosticsProperty<Map<String, int>>('typeCount', typeCount));
  }
}