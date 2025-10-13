import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/services/auth_service.dart';

class ListingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  List<ListingModel> _listings = [];
  List<ListingModel> _hostListings = [];
  List<ListingModel> _filteredListings = [];
  bool _isLoading = false;
  String? _error;
  
  // Filtros
  String _searchQuery = '';
  double _minPrice = 0;
  double _maxPrice = 10000;
  int _minCapacity = 1;
  String? _studioType;
  List<String> _selectedAmenities = [];
  String? _selectedCity;
  
  // Getters
  List<ListingModel> get listings => _listings;
  List<ListingModel> get hostListings => _hostListings;
  List<ListingModel> get filteredListings => _filteredListings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  int get minCapacity => _minCapacity;
  String? get studioType => _studioType;
  List<String> get selectedAmenities => _selectedAmenities;
  String? get selectedCity => _selectedCity;
  
  // Cargar todos los listings activos
  Future<void> loadListings() async {
    try {
      _setLoading(true);
      _error = null;
      
      final querySnapshot = await _firestore
          .collection('listings')
          .where('active', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      _listings = querySnapshot.docs
          .map(ListingModel.fromFirestore)
          .toList();
      
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar listings: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Cargar listings del host actual
  Future<void> loadHostListings() async {
    try {
      _setLoading(true);
      _error = null;
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _error = 'Usuario no autenticado';
        return;
      }
      
      final querySnapshot = await _firestore
          .collection('listings')
          .where('hostId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      _hostListings = querySnapshot.docs
          .map(ListingModel.fromFirestore)
          .toList();
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar listings del host: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Obtener un listing por ID
  Future<ListingModel?> getListingById(String listingId) async {
    try {
      final doc = await _firestore
          .collection('listings')
          .doc(listingId)
          .get();
      
      if (doc.exists) {
        return ListingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _error = 'Error al obtener listing: $e';
      debugPrint(_error);
      return null;
    }
  }
  
  // Crear nuevo listing
  Future<String?> createListing(ListingModel listing) async {
    try {
      _setLoading(true);
      _error = null;
      
      final docRef = await _firestore
          .collection('listings')
          .add(listing.toFirestore());
      
      // Actualizar la lista local
      final newListing = listing.copyWith(id: docRef.id);
      _hostListings.insert(0, newListing);
      
      notifyListeners();
      return docRef.id;
    } catch (e) {
      _error = 'Error al crear listing: $e';
      debugPrint(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Actualizar listing
  Future<bool> updateListing(ListingModel listing) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _firestore
          .collection('listings')
          .doc(listing.id)
          .update(listing.toFirestore());
      
      // Actualizar en la lista local
      final index = _hostListings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _hostListings[index] = listing;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar listing: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Cambiar estado activo/inactivo
  Future<bool> toggleListingStatus(String listingId) async {
    try {
      final listing = _hostListings.firstWhere((l) => l.id == listingId);
      final updatedListing = listing.copyWith(
        active: !listing.active,
        updatedAt: DateTime.now(),
      );
      
      return await updateListing(updatedListing);
    } catch (e) {
      _error = 'Error al cambiar estado del listing: $e';
      debugPrint(_error);
      return false;
    }
  }
  
  // Eliminar listing
  Future<bool> deleteListing(String listingId) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _firestore
          .collection('listings')
          .doc(listingId)
          .delete();
      
      // Remover de la lista local
      _hostListings.removeWhere((l) => l.id == listingId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar listing: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Buscar listings
  void searchListings(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }
  
  // Aplicar filtros de precio
  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
    notifyListeners();
  }
  
  // Filtrar por capacidad
  void setMinCapacity(int capacity) {
    _minCapacity = capacity;
    _applyFilters();
    notifyListeners();
  }
  
  // Filtrar por tipo de estudio
  void setStudioType(String? type) {
    _studioType = type;
    _applyFilters();
    notifyListeners();
  }
  
  // Filtrar por amenidades
  void setAmenities(List<String> amenities) {
    _selectedAmenities = amenities;
    _applyFilters();
    notifyListeners();
  }
  
  // Filtrar por ciudad
  void setCity(String? city) {
    _selectedCity = city;
    _applyFilters();
    notifyListeners();
  }
  
  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _minPrice = 0;
    _maxPrice = 10000;
    _minCapacity = 1;
    _studioType = null;
    _selectedAmenities = [];
    _selectedCity = null;
    _applyFilters();
    notifyListeners();
  }
  
  // Aplicar todos los filtros
  void _applyFilters() {
    _filteredListings = _listings.where((listing) {
      // Filtro de búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!listing.title.toLowerCase().contains(query) &&
            !listing.description.toLowerCase().contains(query) &&
            !listing.location.city.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Filtro de precio
      if (listing.hourlyPrice < _minPrice || listing.hourlyPrice > _maxPrice) {
        return false;
      }
      
      // Filtro de capacidad
      if (listing.capacity < _minCapacity) {
        return false;
      }
      
      // Filtro de tipo de estudio
      if (_studioType != null && listing.studioType != _studioType) {
        return false;
      }
      
      // Filtro de amenidades
      if (_selectedAmenities.isNotEmpty) {
        if (!_selectedAmenities.every((amenity) => listing.amenities.contains(amenity))) {
          return false;
        }
      }
      
      // Filtro de ciudad
      if (_selectedCity != null && listing.location.city != _selectedCity) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  // Obtener ciudades disponibles
  List<String> getAvailableCities() => _listings
        .map((listing) => listing.location.city)
        .toSet()
        .toList()..sort();
  
  // Obtener amenidades disponibles
  List<String> getAvailableAmenities() {
    final amenities = <String>{};
    for (final listing in _listings) {
      amenities.addAll(listing.amenities);
    }
    return amenities.toList()..sort();
  }
  
  // Obtener tipos de estudio disponibles
  List<String> getAvailableStudioTypes() => _listings
        .where((listing) => listing.studioType != null)
        .map((listing) => listing.studioType!)
        .toSet()
        .toList()..sort();
  
  // Obtener estadísticas del host
  Map<String, dynamic> getHostStats() {
    final activeListings = _hostListings.where((l) => l.active).length;
    final totalViews = _hostListings.fold<int>(0, (sum, listing) => sum + (listing.reviewCount * 10)); // Aproximación
    final avgRating = _hostListings.isEmpty 
        ? 0.0 
        : _hostListings.fold<double>(0, (sum, listing) => sum + listing.rating) / _hostListings.length;
    
    return {
      'totalListings': _hostListings.length,
      'activeListings': activeListings,
      'totalViews': totalViews,
      'averageRating': avgRating,
    };
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Actualizar estado de listing
  Future<bool> updateListingStatus(String listingId, bool active) async {
    _setLoading(true);
    try {
      await _firestore.collection('listings').doc(listingId).update({
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Actualizar en la lista local
      final index = _hostListings.indexWhere((l) => l.id == listingId);
      if (index != -1) {
        _hostListings[index] = _hostListings[index].copyWith(active: active);
      }
      
      // También actualizar en la lista general si existe
      final generalIndex = _listings.indexWhere((l) => l.id == listingId);
      if (generalIndex != -1) {
        _listings[generalIndex] = _listings[generalIndex].copyWith(active: active);
      }
      
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar estado del listing: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}