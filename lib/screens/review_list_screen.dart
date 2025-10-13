import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/review_model.dart';
import 'package:salas_beats/providers/review_provider.dart';
import 'package:salas_beats/widgets/common/empty_state.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';
import 'package:salas_beats/widgets/review/review_card.dart';
import 'package:salas_beats/widgets/review/review_filters.dart';
import 'package:salas_beats/widgets/review/review_stats.dart';

class ReviewListScreen extends StatefulWidget {

  const ReviewListScreen({
    required this.title, super.key,
    this.listingId,
    this.userId,
    this.showStats = true,
  });
  final String? listingId;
  final String? userId;
  final String title;
  final bool showStats;

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('listingId', listingId));
    properties.add(StringProperty('userId', userId));
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<bool>('showStats', showStats));
  }
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Filtros
  int? _selectedRating;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  
  List<ReviewModel> _filteredReviews = [];
  List<ReviewModel> _allReviews = [];

  @override
  void initState() {
    super.initState();
    _setupReviewStream();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupReviewStream() {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.listingId != null) {
        reviewProvider.setupListingReviewsStream(widget.listingId!);
      } else if (widget.userId != null) {
        reviewProvider.setupUserReviewsStream(widget.userId!);
        if (widget.showStats) {
          reviewProvider.loadUserReviewStats(widget.userId!);
        }
      }
    });
  }

  void _applyFilters() {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    
    final reviews = widget.listingId != null
        ? reviewProvider.listingReviews
        : reviewProvider.receivedReviews;
    
    _allReviews = List.from(reviews);
    _filteredReviews = List.from(reviews);

    // Filtrar por rating
    if (_selectedRating != null) {
      _filteredReviews = reviewProvider.filterReviewsByRating(
        _filteredReviews,
        _selectedRating!,
      );
    }

    // Filtrar por fecha
    if (_startDate != null && _endDate != null) {
      _filteredReviews = reviewProvider.filterReviewsByDate(
        _filteredReviews,
        _startDate!,
        _endDate!,
      );
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      _filteredReviews = reviewProvider.searchReviews(
        _filteredReviews,
        _searchQuery,
      );
    }

    setState(() {});
  }

  void _clearFilters() {
    setState(() {
      _selectedRating = null;
      _searchQuery = '';
      _startDate = null;
      _endDate = null;
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReviewFilters(
        selectedRating: _selectedRating,
        searchQuery: _searchQuery,
        startDate: _startDate,
        endDate: _endDate,
        onFiltersChanged: (rating, query, start, end) {
          setState(() {
            _selectedRating = rating;
            _searchQuery = query;
            _startDate = start;
            _endDate = end;
          });
          _applyFilters();
          Navigator.pop(context);
        },
        onClearFilters: () {
          _clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_hasActiveFilters())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Consumer<ReviewProvider>(builder: (context, reviewProvider, child) {
        if (reviewProvider.isLoading && _allReviews.isEmpty) {
          return const LoadingWidget();
        }

        // Aplicar filtros cuando cambien las reseñas
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _applyFilters();
        });

        return RefreshIndicator(
          onRefresh: () async {
            _setupReviewStream();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Estadísticas (solo para usuarios)
              if (widget.showStats && widget.userId != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ReviewStats(
                      stats: reviewProvider.reviewStats,
                      reviews: _allReviews,
                    ),
                  ),
                ),

              // Información de filtros activos
              if (_hasActiveFilters())
                SliverToBoxAdapter(
                  child: _buildActiveFiltersInfo(),
                ),

              // Lista de reseñas
              if (_filteredReviews.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.rate_review_outlined,
                    title: _hasActiveFilters()
                        ? 'No hay reseñas que coincidan'
                        : 'No hay reseñas aún',
                    message: _hasActiveFilters()
                        ? 'Intenta ajustar los filtros'
                        : 'Las reseñas aparecerán aquí cuando estén disponibles',
                    actionText: _hasActiveFilters() ? 'Limpiar filtros' : null,
                    onAction: _hasActiveFilters() ? _clearFilters : null,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final review = _filteredReviews[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ReviewCard(
                            review: review,
                            showActions: false,
                          ),
                        );
                      },
                      childCount: _filteredReviews.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },),
    );

  bool _hasActiveFilters() => _selectedRating != null ||
        _searchQuery.isNotEmpty ||
        _startDate != null ||
        _endDate != null;

  Widget _buildActiveFiltersInfo() {
    final theme = Theme.of(context);
    final activeFilters = <String>[];

    if (_selectedRating != null) {
      activeFilters.add('$_selectedRating estrellas');
    }
    if (_searchQuery.isNotEmpty) {
      activeFilters.add('"$_searchQuery"');
    }
    if (_startDate != null && _endDate != null) {
      activeFilters.add('Rango de fechas');
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filtros activos: ${activeFilters.join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Limpiar',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}