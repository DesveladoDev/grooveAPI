import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/config/constants.dart';
import 'package:salas_beats/widgets/common/custom_button.dart';
import 'package:salas_beats/widgets/common/custom_text_field.dart';

class ReviewFilters extends StatefulWidget {

  const ReviewFilters({
    required this.searchQuery, required this.onFiltersChanged, required this.onClearFilters, super.key,
    this.selectedRating,
    this.startDate,
    this.endDate,
  });
  final int? selectedRating;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(int?, String, DateTime?, DateTime?) onFiltersChanged;
  final VoidCallback onClearFilters;

  @override
  State<ReviewFilters> createState() => _ReviewFiltersState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('selectedRating', selectedRating));
    properties.add(StringProperty('searchQuery', searchQuery));
    properties.add(DiagnosticsProperty<DateTime?>('startDate', startDate));
    properties.add(DiagnosticsProperty<DateTime?>('endDate', endDate));
    properties.add(ObjectFlagProperty<Function(int? p1, String p2, DateTime? p3, DateTime? p4)>.has('onFiltersChanged', onFiltersChanged));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onClearFilters', onClearFilters));
  }
}

class _ReviewFiltersState extends State<ReviewFilters> {
  late TextEditingController _searchController;
  int? _selectedRating;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _selectedRating = widget.selectedRating;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      _selectedRating,
      _searchController.text.trim(),
      _startDate,
      _endDate,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedRating = null;
      _searchController.clear();
      _startDate = null;
      _endDate = null;
    });
    widget.onClearFilters();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filtrar Reseñas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultSpacing),

          // Búsqueda por texto
          _buildSearchSection(theme),
          const SizedBox(height: AppConstants.largeSpacing),

          // Filtro por rating
          _buildRatingSection(theme),
          const SizedBox(height: AppConstants.largeSpacing),

          // Filtro por fecha
          _buildDateSection(theme),
          const SizedBox(height: AppConstants.extraLargeSpacing),

          // Botones de acción
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildSearchSection(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buscar en comentarios',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        CustomTextField(
          controller: _searchController,
          hint: 'Buscar palabras clave...',
          prefixIcon: const Icon(Icons.search),
          onChanged: (value) {
            // Búsqueda en tiempo real opcional
          },
        ),
      ],
    );

  Widget _buildRatingSection(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtrar por calificación',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Wrap(
          spacing: AppConstants.smallSpacing,
          children: _buildRatingChips(),
        ),
      ],
    );

  List<Widget> _buildRatingChips() => List.generate(6, (index) {
      if (index == 0) {
        // Opción "Todas"
        return FilterChip(
          label: const Text('Todas'),
          selected: _selectedRating == null,
          onSelected: (selected) {
            setState(() {
              _selectedRating = selected ? null : _selectedRating;
            });
          },
        );
      }
      
      final rating = index;
      return FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$rating'),
            const SizedBox(width: 4),
            const Icon(Icons.star, size: AppConstants.smallIconSize, color: Colors.amber),
          ],
        ),
        selected: _selectedRating == rating,
        onSelected: (selected) {
          setState(() {
            _selectedRating = selected ? rating : null;
          });
        },
      );
    });

  Widget _buildDateSection(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtrar por fecha',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        InkWell(
          onTap: _selectDateRange,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppConstants.smallSpacing),
                Expanded(
                  child: Text(
                    _getDateRangeText(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _startDate != null && _endDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (_startDate != null && _endDate != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

  Widget _buildActionButtons(ThemeData theme) => Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilters,
            child: const Text('Limpiar Filtros'),
          ),
        ),
        const SizedBox(width: AppConstants.smallSpacing),
        Expanded(
          child: CustomButton(
            text: 'Aplicar Filtros',
            onPressed: _applyFilters,
          ),
        ),
      ],
    );

  String _getDateRangeText() {
    if (_startDate == null || _endDate == null) {
      return 'Seleccionar rango de fechas';
    }
    
    final start = '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}';
    final end = '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
    
    return '$start - $end';
  }
}

class QuickFilters extends StatelessWidget {

  const QuickFilters({
    required this.onRatingSelected, required this.onClearFilters, super.key,
    this.selectedRating,
  });
  final int? selectedRating;
  final Function(int?) onRatingSelected;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Todas'),
            selected: selectedRating == null,
            onSelected: (selected) {
              if (selected) {
                onClearFilters();
              }
            },
          ),
          const SizedBox(width: AppConstants.smallSpacing),
          ...List.generate(5, (index) {
            final rating = 5 - index; // De 5 a 1
            return Padding(
              padding: const EdgeInsets.only(right: AppConstants.smallSpacing),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$rating'),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: AppConstants.smallIconSize, color: Colors.amber),
                  ],
                ),
                selected: selectedRating == rating,
                onSelected: (selected) {
                  onRatingSelected(selected ? rating : null);
                },
              ),
            );
          }),
        ],
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('selectedRating', selectedRating));
    properties.add(ObjectFlagProperty<Function(int? p1)>.has('onRatingSelected', onRatingSelected));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onClearFilters', onClearFilters));
  }
}

class SortOptions extends StatelessWidget {

  const SortOptions({
    required this.selectedSort, required this.onSortChanged, super.key,
  });
  final String selectedSort;
  final Function(String) onSortChanged;

  static const Map<String, String> _sortOptions = {
    'newest': 'Más recientes',
    'oldest': 'Más antiguos',
    'highest': 'Mejor calificados',
    'lowest': 'Peor calificados',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopupMenuButton<String>(
      initialValue: selectedSort,
      onSelected: onSortChanged,
      itemBuilder: (context) => _sortOptions.entries
          .map((entry) => PopupMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    Icon(
                      _getSortIcon(entry.key),
                      size: 20,
                      color: selectedSort == entry.key
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppConstants.smallSpacing),
                    Text(
                      entry.value,
                      style: TextStyle(
                        color: selectedSort == entry.key
                            ? theme.colorScheme.primary
                            : null,
                        fontWeight: selectedSort == entry.key
                            ? FontWeight.w600
                            : null,
                      ),
                    ),
                  ],
                ),
              ),)
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppConstants.smallSpacing),
            Text(
              _sortOptions[selectedSort] ?? 'Ordenar',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(String sortKey) {
    switch (sortKey) {
      case 'newest':
        return Icons.schedule;
      case 'oldest':
        return Icons.history;
      case 'highest':
        return Icons.trending_up;
      case 'lowest':
        return Icons.trending_down;
      default:
        return Icons.sort;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('selectedSort', selectedSort));
    properties.add(ObjectFlagProperty<Function(String p1)>.has('onSortChanged', onSortChanged));
  }
}