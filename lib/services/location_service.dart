import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  Position? _currentPosition;
  Placemark? _currentPlacemark;
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Vérifie et demande les permissions de localisation
  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Les services de localisation ne sont pas activés
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions refusées
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions refusées définitivement
      return false;
    }

    return true;
  }

  /// Obtient la position actuelle de l'utilisateur
  Future<Position?> getCurrentPosition({bool forceRefresh = false}) async {
    if (_currentPosition != null && !forceRefresh) {
      return _currentPosition;
    }

    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return null;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Met à jour les informations de lieu
      if (_currentPosition != null) {
        await _updatePlacemark(_currentPosition!);
      }

      return _currentPosition;
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  /// Met à jour les informations de lieu (ville, pays, etc.)
  Future<void> _updatePlacemark(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        _currentPlacemark = placemarks.first;
      }
    } catch (e) {
      print('Erreur lors de l\'obtention du lieu: $e');
    }
  }

  /// Obtient les informations de lieu actuelles
  Placemark? getCurrentPlacemark() => _currentPlacemark;

  /// Calcule la distance entre deux positions en kilomètres
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Conversion en km
  }

  /// Commence le suivi de position en temps réel
  Stream<Position> startLocationTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // mètres
  }) {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  /// Arrête le suivi de position
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Obtient les utilisateurs dans un rayon donné
  List<T> getUsersInRadius<T extends HasLocation>(
    List<T> users,
    Position centerPosition,
    double radiusKm,
  ) {
    return users.where((user) {
      final distance = calculateDistance(
        centerPosition.latitude,
        centerPosition.longitude,
        user.latitude,
        user.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Trie les utilisateurs par distance
  List<T> sortUsersByDistance<T extends HasLocation>(
    List<T> users,
    Position referencePosition,
  ) {
    users.sort((a, b) {
      final distanceA = calculateDistance(
        referencePosition.latitude,
        referencePosition.longitude,
        a.latitude,
        a.longitude,
      );

      final distanceB = calculateDistance(
        referencePosition.latitude,
        referencePosition.longitude,
        b.latitude,
        b.longitude,
      );

      return distanceA.compareTo(distanceB);
    });

    return users;
  }

  /// Obtient une adresse lisible à partir de coordonnées
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality ?? ''}, ${place.country ?? ''}';
      }
    } catch (e) {
      print('Erreur lors de l\'obtention de l\'adresse: $e');
    }
    
    return 'Lieu inconnu';
  }

  /// Obtient des coordonnées à partir d'une adresse
  static Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          longitude: location.longitude,
          latitude: location.latitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } catch (e) {
      print('Erreur lors de l\'obtention des coordonnées: $e');
    }
    
    return null;
  }

  /// Vérifie si une position est dans une zone géographique donnée
  static bool isPositionInArea(
    Position position,
    Position centerPosition,
    double radiusKm,
  ) {
    final distance = calculateDistance(
      position.latitude,
      position.longitude,
      centerPosition.latitude,
      centerPosition.longitude,
    );
    
    return distance <= radiusKm;
  }

  /// Génère des points aléatoires dans un rayon (pour les tests)
  static List<Position> generateRandomPositionsInRadius(
    Position center,
    double radiusKm,
    int count,
  ) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final positions = <Position>[];

    for (int i = 0; i < count; i++) {
      // Conversion rayon km vers degrés (approximation)
      final radiusDegrees = radiusKm / 111.32;
      
      // Génération aléatoire dans le cercle
      final angle = (random + i) % 360 * (3.14159 / 180);
      final distance = (random % 1000) / 1000.0 * radiusDegrees;
      
      final lat = center.latitude + distance * (angle % 2 == 0 ? 1 : -1);
      final lon = center.longitude + distance * (angle % 4 < 2 ? 1 : -1);
      
      positions.add(Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
      ));
    }

    return positions;
  }

  /// Nettoie les ressources
  void dispose() {
    stopLocationTracking();
  }
}

/// Mixin pour les objets qui ont une localisation
mixin HasLocation {
  double get latitude;
  double get longitude;
}

/// Extension pour Position
extension PositionExtension on Position {
  /// Convertit en UserLocation pour l'algorithme de matching
  Future<UserLocation> toUserLocation() async {
    final address = await LocationService.getAddressFromCoordinates(
      latitude,
      longitude,
    );
    
    final parts = address.split(', ');
    return UserLocation(
      latitude: latitude,
      longitude: longitude,
      city: parts.isNotEmpty ? parts.first : 'Ville inconnue',
      country: parts.length > 1 ? parts.last : 'Pays inconnu',
    );
  }
}

/// Classe pour représenter une zone géographique
class GeoArea {
  final Position center;
  final double radiusKm;
  final String name;

  const GeoArea({
    required this.center,
    required this.radiusKm,
    required this.name,
  });

  bool contains(Position position) {
    return LocationService.isPositionInArea(position, center, radiusKm);
  }
}

/// Utilitaires pour les zones urbaines communes
class UrbanAreas {
  static const paris = GeoArea(
    center: Position(
      latitude: 48.8566,
      longitude: 2.3522,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    ),
    radiusKm: 20,
    name: 'Paris',
  );

  static const lyon = GeoArea(
    center: Position(
      latitude: 45.7640,
      longitude: 4.8357,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    ),
    radiusKm: 15,
    name: 'Lyon',
  );

  static const marseille = GeoArea(
    center: Position(
      latitude: 43.2965,
      longitude: 5.3698,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    ),
    radiusKm: 15,
    name: 'Marseille',
  );
}

// Import nécessaire pour UserLocation
class UserLocation {
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });
}