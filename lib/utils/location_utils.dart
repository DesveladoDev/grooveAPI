import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:salas_beats/utils/exceptions.dart';

class LocationCoordinates {
  
  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
    required this.timestamp, this.altitude,
    this.accuracy,
    this.heading,
    this.speed,
  });
  
  factory LocationCoordinates.fromPosition(geolocator.Position position) => LocationCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      heading: position.heading,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? heading;
  final double? speed;
  final DateTime timestamp;
  
  geolocator.Position toPosition() => geolocator.Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      accuracy: accuracy ?? 0.0,
      altitude: altitude ?? 0.0,
      heading: heading ?? 0.0,
      speed: speed ?? 0.0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  
  // Calculate distance to another location in meters
  double distanceTo(LocationCoordinates other) => geolocator.Geolocator.distanceBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  
  // Calculate bearing to another location in degrees
  double bearingTo(LocationCoordinates other) => geolocator.Geolocator.bearingBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  
  // Check if location is within radius of another location
  bool isWithinRadius(LocationCoordinates center, double radiusMeters) => distanceTo(center) <= radiusMeters;
  
  // Get location with offset in meters
  LocationCoordinates offsetBy(double distanceMeters, double bearingDegrees) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final bearingRadians = bearingDegrees * (math.pi / 180);
    final latRadians = latitude * (math.pi / 180);
    final lonRadians = longitude * (math.pi / 180);
    
    final newLatRadians = math.asin(
      math.sin(latRadians) * math.cos(distanceMeters / earthRadius) +
      math.cos(latRadians) * math.sin(distanceMeters / earthRadius) * math.cos(bearingRadians),
    );
    
    final newLonRadians = lonRadians + math.atan2(
      math.sin(bearingRadians) * math.sin(distanceMeters / earthRadius) * math.cos(latRadians),
      math.cos(distanceMeters / earthRadius) - math.sin(latRadians) * math.sin(newLatRadians),
    );
    
    return LocationCoordinates(
      latitude: newLatRadians * (180 / math.pi),
      longitude: newLonRadians * (180 / math.pi),
      timestamp: DateTime.now(),
    );
  }
  
  @override
  String toString() => 'LocationCoordinates(lat: $latitude, lng: $longitude)';
  
  @override
  bool operator ==(Object other) => other is LocationCoordinates &&
           other.latitude == latitude &&
           other.longitude == longitude;
  
  @override
  int get hashCode => Object.hash(latitude, longitude);
}

class LocationAddress {
  
  const LocationAddress({
    this.street,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.postalCode,
    this.country,
    this.countryCode,
    this.thoroughfare,
    this.subThoroughfare,
    this.coordinates,
  });
  
  factory LocationAddress.fromPlacemark(Placemark placemark) => LocationAddress(
      street: placemark.street,
      locality: placemark.locality,
      subLocality: placemark.subLocality,
      administrativeArea: placemark.administrativeArea,
      subAdministrativeArea: placemark.subAdministrativeArea,
      postalCode: placemark.postalCode,
      country: placemark.country,
      countryCode: placemark.isoCountryCode,
      thoroughfare: placemark.thoroughfare,
      subThoroughfare: placemark.subThoroughfare,
    );
  final String? street;
  final String? locality;
  final String? subLocality;
  final String? administrativeArea;
  final String? subAdministrativeArea;
  final String? postalCode;
  final String? country;
  final String? countryCode;
  final String? thoroughfare;
  final String? subThoroughfare;
  final LocationCoordinates? coordinates;
  
  String get formattedAddress {
    final parts = <String>[];
    
    if (subThoroughfare != null && thoroughfare != null) {
      parts.add('$subThoroughfare $thoroughfare');
    } else if (thoroughfare != null) {
      parts.add(thoroughfare!);
    } else if (street != null) {
      parts.add(street!);
    }
    
    if (subLocality != null) {
      parts.add(subLocality!);
    }
    
    if (locality != null) {
      parts.add(locality!);
    }
    
    if (administrativeArea != null) {
      parts.add(administrativeArea!);
    }
    
    if (postalCode != null) {
      parts.add(postalCode!);
    }
    
    if (country != null) {
      parts.add(country!);
    }
    
    return parts.join(', ');
  }
  
  String get shortAddress {
    final parts = <String>[];
    
    if (locality != null) {
      parts.add(locality!);
    }
    
    if (administrativeArea != null) {
      parts.add(administrativeArea!);
    }
    
    return parts.join(', ');
  }
  
  @override
  String toString() => formattedAddress;
}

class LocationBounds {
  
  const LocationBounds({
    required this.southwest,
    required this.northeast,
  });
  final LocationCoordinates southwest;
  final LocationCoordinates northeast;
  
  LocationCoordinates get center {
    final centerLat = (southwest.latitude + northeast.latitude) / 2;
    final centerLng = (southwest.longitude + northeast.longitude) / 2;
    
    return LocationCoordinates(
      latitude: centerLat,
      longitude: centerLng,
      timestamp: DateTime.now(),
    );
  }
  
  double get width => northeast.longitude - southwest.longitude;
  
  double get height => northeast.latitude - southwest.latitude;
  
  bool contains(LocationCoordinates location) => location.latitude >= southwest.latitude &&
           location.latitude <= northeast.latitude &&
           location.longitude >= southwest.longitude &&
           location.longitude <= northeast.longitude;
  
  LocationBounds expandToInclude(LocationCoordinates location) => LocationBounds(
      southwest: LocationCoordinates(
        latitude: math.min(southwest.latitude, location.latitude),
        longitude: math.min(southwest.longitude, location.longitude),
        timestamp: DateTime.now(),
      ),
      northeast: LocationCoordinates(
        latitude: math.max(northeast.latitude, location.latitude),
        longitude: math.max(northeast.longitude, location.longitude),
        timestamp: DateTime.now(),
      ),
    );
  
  LocationBounds expandByDistance(double distanceMeters) {
    const double earthRadius = 6371000;
    final latOffset = (distanceMeters / earthRadius) * (180 / math.pi);
    final lngOffset = (distanceMeters / earthRadius) * 
                            (180 / math.pi) / math.cos(center.latitude * math.pi / 180);
    
    return LocationBounds(
      southwest: LocationCoordinates(
        latitude: southwest.latitude - latOffset,
        longitude: southwest.longitude - lngOffset,
        timestamp: DateTime.now(),
      ),
      northeast: LocationCoordinates(
        latitude: northeast.latitude + latOffset,
        longitude: northeast.longitude + lngOffset,
        timestamp: DateTime.now(),
      ),
    );
  }
}

enum LocationAccuracy {
  lowest,
  low,
  medium,
  high,
  best,
  bestForNavigation,
}

class LocationSettings {
  
  const LocationSettings({
    this.accuracy = LocationAccuracy.high,
    this.distanceFilter = 10,
    this.timeLimit,
    this.forceAndroidLocationManager = false,
  });
  final LocationAccuracy accuracy;
  final int distanceFilter;
  final Duration? timeLimit;
  final bool forceAndroidLocationManager;
  
  LocationSettings copyWith({
    LocationAccuracy? accuracy,
    int? distanceFilter,
    Duration? timeLimit,
    bool? forceAndroidLocationManager,
  }) => LocationSettings(
      accuracy: accuracy ?? this.accuracy,
      distanceFilter: distanceFilter ?? this.distanceFilter,
      timeLimit: timeLimit ?? this.timeLimit,
      forceAndroidLocationManager: forceAndroidLocationManager ?? this.forceAndroidLocationManager,
    );
}

class LocationManager {
  
  LocationManager._();
  static LocationManager? _instance;
  static LocationManager get instance => _instance ??= LocationManager._();
  
  final StreamController<LocationCoordinates> _locationController = 
      StreamController<LocationCoordinates>.broadcast();
  
  StreamSubscription<geolocator.Position>? _positionSubscription;
  LocationCoordinates? _lastKnownLocation;
  bool _isTracking = false;
  
  // Getters
  Stream<LocationCoordinates> get locationStream => _locationController.stream;
  LocationCoordinates? get lastKnownLocation => _lastKnownLocation;
  bool get isTracking => _isTracking;
  
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async => geolocator.Geolocator.isLocationServiceEnabled();
  
  // Check location permission status
  Future<geolocator.LocationPermission> checkPermission() async => geolocator.Geolocator.checkPermission();
  
  // Request location permission
  Future<geolocator.LocationPermission> requestPermission() async => geolocator.Geolocator.requestPermission();
  
  // Get current location
  Future<LocationCoordinates> getCurrentLocation({
    LocationSettings? settings,
  }) async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException.serviceDisabled();
      }
      
      // Check permissions
      var permission = await checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == geolocator.LocationPermission.denied) {
          throw LocationException.permissionDenied();
        }
      }
      
      if (permission == geolocator.LocationPermission.deniedForever) {
        throw LocationException.permissionDenied();
      }
      
      // Get location settings
      final locationSettings = settings ?? const LocationSettings();
      
      // Get current position
      final position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: _mapAccuracy(locationSettings.accuracy),
        timeLimit: locationSettings.timeLimit,
      );
      
      final coordinates = LocationCoordinates.fromPosition(position);
      _lastKnownLocation = coordinates;
      
      return coordinates;
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException.unknown('Failed to get current location: $e');
    }
  }
  
  // Start location tracking
  Future<void> startTracking({
    LocationSettings? settings,
    void Function(LocationCoordinates)? onLocationChanged,
  }) async {
    try {
      if (_isTracking) {
        throw LocationException.alreadyTracking('Location tracking already started');
      }
      
      // Check permissions first
      await getCurrentLocation(settings: settings);
      
      final locationSettings = settings ?? const LocationSettings();
      
      // Start position stream
      _positionSubscription = geolocator.Geolocator.getPositionStream(
        locationSettings: geolocator.LocationSettings(
          accuracy: _mapAccuracy(locationSettings.accuracy),
          distanceFilter: locationSettings.distanceFilter,
        ),
      ).listen(
        (position) {
          final coordinates = LocationCoordinates.fromPosition(position);
          _lastKnownLocation = coordinates;
          _locationController.add(coordinates);
          onLocationChanged?.call(coordinates);
        },
        onError: (error) {
          debugPrint('Location tracking error: $error');
          _locationController.addError(
            LocationException.trackingError('Location tracking error: $error'),
          );
        },
      );
      
      _isTracking = true;
      debugPrint('Location tracking started');
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException.trackingError('Failed to start location tracking: $e');
    }
  }
  
  // Stop location tracking
  Future<void> stopTracking() async {
    try {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      _isTracking = false;
      debugPrint('Location tracking stopped');
    } catch (e) {
      throw LocationException.trackingError('Failed to stop location tracking: $e');
    }
  }
  
  // Map LocationAccuracy to Geolocator LocationAccuracy
  geolocator.LocationAccuracy _mapAccuracy(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return geolocator.LocationAccuracy.lowest;
      case LocationAccuracy.low:
        return geolocator.LocationAccuracy.low;
      case LocationAccuracy.medium:
        return geolocator.LocationAccuracy.medium;
      case LocationAccuracy.high:
        return geolocator.LocationAccuracy.high;
      case LocationAccuracy.best:
        return geolocator.LocationAccuracy.best;
      case LocationAccuracy.bestForNavigation:
        return geolocator.LocationAccuracy.bestForNavigation;
    }
  }
  
  // Get last known location from device
  Future<LocationCoordinates?> getLastKnownLocation() async {
    try {
      final position = await geolocator.Geolocator.getLastKnownPosition();
      if (position != null) {
        final coordinates = LocationCoordinates.fromPosition(position);
        _lastKnownLocation = coordinates;
        return coordinates;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get last known location: $e');
      return null;
    }
  }
  
  // Open location settings
  Future<bool> openLocationSettings() async => geolocator.Geolocator.openLocationSettings();
  
  // Open app settings
  Future<bool> openAppSettings() async => geolocator.Geolocator.openAppSettings();
  
  // Dispose resources
  void dispose() {
    _positionSubscription?.cancel();
    _locationController.close();
  }
}

class GeocodingManager {
  
  GeocodingManager._();
  static GeocodingManager? _instance;
  static GeocodingManager get instance => _instance ??= GeocodingManager._();
  
  // Convert coordinates to address (reverse geocoding)
  Future<LocationAddress?> getAddressFromCoordinates(
    LocationCoordinates coordinates,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return LocationAddress.fromPlacemark(placemark).copyWith(
          coordinates: coordinates,
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
      throw LocationException.geocodingError('Failed to get address from coordinates: $e');
    }
  }
  
  // Convert address to coordinates (forward geocoding)
  Future<List<LocationCoordinates>> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final locations = await locationFromAddress(address);
      
      return locations.map((location) => LocationCoordinates(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
        ),).toList();
    } catch (e) {
      debugPrint('Forward geocoding failed: $e');
      throw LocationException.geocodingError('Failed to get coordinates from address: $e');
    }
  }
  
  // Search for places
  Future<List<LocationAddress>> searchPlaces(
    String query, {
    LocationCoordinates? nearLocation,
    double? radiusKm,
  }) async {
    try {
      // This is a simplified implementation
      // In practice, you'd use a proper places API like Google Places
      final coordinates = await getCoordinatesFromAddress(query);
      
      final addresses = <LocationAddress>[];
      for (final coord in coordinates) {
        final address = await getAddressFromCoordinates(coord);
        if (address != null) {
          addresses.add(address);
        }
      }
      
      return addresses;
    } catch (e) {
      debugPrint('Place search failed: $e');
      throw LocationException.searchError('Failed to search places: $e');
    }
  }
}

class LocationUtils {
  // Calculate distance between two coordinates
  static double calculateDistance(
    LocationCoordinates from,
    LocationCoordinates to,
  ) => geolocator.Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  
  // Calculate bearing between two coordinates
  static double calculateBearing(
    LocationCoordinates from,
    LocationCoordinates to,
  ) => geolocator.Geolocator.bearingBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  
  // Format distance for display
  static String formatDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m';
    } else {
      final km = distanceMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }
  
  // Format bearing for display
  static String formatBearing(double bearingDegrees) {
    final directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW',
    ];
    
    final index = ((bearingDegrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
  
  // Check if location is within bounds
  static bool isLocationInBounds(
    LocationCoordinates location,
    LocationBounds bounds,
  ) => bounds.contains(location);
  
  // Get center point of multiple locations
  static LocationCoordinates getCenterPoint(
    List<LocationCoordinates> locations,
  ) {
    if (locations.isEmpty) {
      throw ArgumentError('Cannot calculate center of empty location list');
    }
    
    if (locations.length == 1) {
      return locations.first;
    }
    
    double totalLat = 0;
    double totalLng = 0;
    
    for (final location in locations) {
      totalLat += location.latitude;
      totalLng += location.longitude;
    }
    
    return LocationCoordinates(
      latitude: totalLat / locations.length,
      longitude: totalLng / locations.length,
      timestamp: DateTime.now(),
    );
  }
  
  // Get bounds that contain all locations
  static LocationBounds getBoundsForLocations(
    List<LocationCoordinates> locations,
  ) {
    if (locations.isEmpty) {
      throw ArgumentError('Cannot calculate bounds of empty location list');
    }
    
    if (locations.length == 1) {
      final location = locations.first;
      return LocationBounds(
        southwest: location,
        northeast: location,
      );
    }
    
    var minLat = locations.first.latitude;
    var maxLat = locations.first.latitude;
    var minLng = locations.first.longitude;
    var maxLng = locations.first.longitude;
    
    for (final location in locations) {
      minLat = math.min(minLat, location.latitude);
      maxLat = math.max(maxLat, location.latitude);
      minLng = math.min(minLng, location.longitude);
      maxLng = math.max(maxLng, location.longitude);
    }
    
    return LocationBounds(
      southwest: LocationCoordinates(
        latitude: minLat,
        longitude: minLng,
        timestamp: DateTime.now(),
      ),
      northeast: LocationCoordinates(
        latitude: maxLat,
        longitude: maxLng,
        timestamp: DateTime.now(),
      ),
    );
  }
  
  // Find nearest location from a list
  static LocationCoordinates? findNearestLocation(
    LocationCoordinates reference,
    List<LocationCoordinates> locations,
  ) {
    if (locations.isEmpty) return null;
    
    LocationCoordinates? nearest;
    var minDistance = double.infinity;
    
    for (final location in locations) {
      final distance = calculateDistance(reference, location);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = location;
      }
    }
    
    return nearest;
  }
  
  // Filter locations within radius
  static List<LocationCoordinates> filterLocationsWithinRadius(
    LocationCoordinates center,
    List<LocationCoordinates> locations,
    double radiusMeters,
  ) => locations.where((location) => calculateDistance(center, location) <= radiusMeters).toList();
  
  // Sort locations by distance from reference point
  static List<LocationCoordinates> sortLocationsByDistance(
    LocationCoordinates reference,
    List<LocationCoordinates> locations,
  ) {
    final sortedLocations = List<LocationCoordinates>.from(locations);
    
    sortedLocations.sort((a, b) {
      final distanceA = calculateDistance(reference, a);
      final distanceB = calculateDistance(reference, b);
      return distanceA.compareTo(distanceB);
    });
    
    return sortedLocations;
  }
  
  // Check if coordinates are valid
  static bool isValidCoordinates(double latitude, double longitude) => latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  
  // Generate random location within bounds
  static LocationCoordinates generateRandomLocation(LocationBounds bounds) {
    final random = math.Random();
    
    final lat = bounds.southwest.latitude + 
                random.nextDouble() * (bounds.northeast.latitude - bounds.southwest.latitude);
    final lng = bounds.southwest.longitude + 
                random.nextDouble() * (bounds.northeast.longitude - bounds.southwest.longitude);
    
    return LocationCoordinates(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
    );
  }
}

// Location extensions
extension LocationAddressExtension on LocationAddress {
  LocationAddress copyWith({
    String? street,
    String? locality,
    String? subLocality,
    String? administrativeArea,
    String? subAdministrativeArea,
    String? postalCode,
    String? country,
    String? countryCode,
    String? thoroughfare,
    String? subThoroughfare,
    LocationCoordinates? coordinates,
  }) => LocationAddress(
      street: street ?? this.street,
      locality: locality ?? this.locality,
      subLocality: subLocality ?? this.subLocality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      subAdministrativeArea: subAdministrativeArea ?? this.subAdministrativeArea,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      thoroughfare: thoroughfare ?? this.thoroughfare,
      subThoroughfare: subThoroughfare ?? this.subThoroughfare,
      coordinates: coordinates ?? this.coordinates,
    );
}