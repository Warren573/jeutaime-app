import 'dart:math';
import 'package:geolocator/geolocator.dart';

class MatchingAlgorithm {
  static const double _maxDistance = 50.0; // km
  static const Map<String, double> _weights = {
    'interests': 0.35,
    'age': 0.25,
    'distance': 0.20,
    'lifestyle': 0.15,
    'personality': 0.05,
  };

  /// Calcule le score de compatibilité entre deux profils
  static double calculateCompatibilityScore(
    UserProfile currentUser,
    UserProfile otherUser,
  ) {
    double totalScore = 0.0;

    // 1. Score basé sur les intérêts communs (35%)
    double interestsScore = _calculateInterestsScore(
      currentUser.interests,
      otherUser.interests,
    );
    totalScore += interestsScore * _weights['interests']!;

    // 2. Score basé sur l'âge (25%)
    double ageScore = _calculateAgeScore(
      currentUser.age,
      otherUser.age,
      currentUser.preferences.ageRange,
    );
    totalScore += ageScore * _weights['age']!;

    // 3. Score basé sur la distance (20%)
    double distanceScore = _calculateDistanceScore(
      currentUser.location,
      otherUser.location,
      currentUser.preferences.maxDistance,
    );
    totalScore += distanceScore * _weights['distance']!;

    // 4. Score basé sur le style de vie (15%)
    double lifestyleScore = _calculateLifestyleScore(
      currentUser.lifestyle,
      otherUser.lifestyle,
    );
    totalScore += lifestyleScore * _weights['lifestyle']!;

    // 5. Score basé sur la personnalité (5%)
    double personalityScore = _calculatePersonalityScore(
      currentUser.personality,
      otherUser.personality,
    );
    totalScore += personalityScore * _weights['personality']!;

    return (totalScore * 100).clamp(0.0, 100.0);
  }

  /// Calcule le score basé sur les intérêts communs
  static double _calculateInterestsScore(
    List<String> userInterests,
    List<String> otherInterests,
  ) {
    if (userInterests.isEmpty || otherInterests.isEmpty) return 0.0;

    final commonInterests = userInterests
        .where((interest) => otherInterests.contains(interest))
        .length;

    final totalInterests = userInterests.length + otherInterests.length;
    final uniqueInterests = (userInterests.toSet()..addAll(otherInterests)).length;

    // Score pondéré : intérêts communs vs diversité
    final commonScore = commonInterests / userInterests.length;
    final diversityScore = uniqueInterests / totalInterests;

    return (commonScore * 0.7 + diversityScore * 0.3).clamp(0.0, 1.0);
  }

  /// Calcule le score basé sur l'âge
  static double _calculateAgeScore(
    int userAge,
    int otherAge,
    AgeRange preferredRange,
  ) {
    // Vérifie si l'autre utilisateur est dans la tranche d'âge préférée
    if (otherAge < preferredRange.min || otherAge > preferredRange.max) {
      return 0.0;
    }

    // Score basé sur la proximité avec l'âge idéal (centre de la tranche)
    final idealAge = (preferredRange.min + preferredRange.max) / 2;
    final ageDifference = (otherAge - idealAge).abs();
    final maxDifference = (preferredRange.max - preferredRange.min) / 2;

    return (1.0 - (ageDifference / maxDifference)).clamp(0.0, 1.0);
  }

  /// Calcule le score basé sur la distance
  static double _calculateDistanceScore(
    UserLocation userLocation,
    UserLocation otherLocation,
    double maxPreferredDistance,
  ) {
    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      otherLocation.latitude,
      otherLocation.longitude,
    ) / 1000; // Conversion en km

    if (distance > maxPreferredDistance) return 0.0;
    if (distance > _maxDistance) return 0.0;

    // Score décroissant avec la distance
    return (1.0 - (distance / maxPreferredDistance)).clamp(0.0, 1.0);
  }

  /// Calcule le score basé sur le style de vie
  static double _calculateLifestyleScore(
    Lifestyle userLifestyle,
    Lifestyle otherLifestyle,
  ) {
    double score = 0.0;
    int factors = 0;

    // Activité sociale
    if (userLifestyle.socialActivity != null && 
        otherLifestyle.socialActivity != null) {
      final diff = (userLifestyle.socialActivity! - otherLifestyle.socialActivity!).abs();
      score += (1.0 - diff / 4.0).clamp(0.0, 1.0);
      factors++;
    }

    // Niveau de fitness
    if (userLifestyle.fitnessLevel != null && 
        otherLifestyle.fitnessLevel != null) {
      final diff = (userLifestyle.fitnessLevel! - otherLifestyle.fitnessLevel!).abs();
      score += (1.0 - diff / 4.0).clamp(0.0, 1.0);
      factors++;
    }

    // Habitudes alimentaires
    if (userLifestyle.dietType == otherLifestyle.dietType) {
      score += 1.0;
    } else if (userLifestyle.dietType != null && otherLifestyle.dietType != null) {
      score += 0.3; // Partiellement compatible
    }
    factors++;

    // Consommation d'alcool/tabac
    if (userLifestyle.drinking == otherLifestyle.drinking) score += 1.0;
    if (userLifestyle.smoking == otherLifestyle.smoking) score += 1.0;
    factors += 2;

    return factors > 0 ? score / factors : 0.0;
  }

  /// Calcule le score basé sur la personnalité
  static double _calculatePersonalityScore(
    Personality userPersonality,
    Personality otherPersonality,
  ) {
    double score = 0.0;
    int factors = 0;

    // Extraversion - les opposés peuvent s'attirer
    if (userPersonality.extraversion != null && 
        otherPersonality.extraversion != null) {
      final diff = (userPersonality.extraversion! - otherPersonality.extraversion!).abs();
      // Score optimal quand il y a une légère différence (complémentarité)
      score += (1.0 - (diff - 1.0).abs() / 3.0).clamp(0.0, 1.0);
      factors++;
    }

    // Ouverture d'esprit - similarité importante
    if (userPersonality.openness != null && 
        otherPersonality.openness != null) {
      final diff = (userPersonality.openness! - otherPersonality.openness!).abs();
      score += (1.0 - diff / 4.0).clamp(0.0, 1.0);
      factors++;
    }

    return factors > 0 ? score / factors : 0.0;
  }

  /// Filtre les profils selon les critères avancés
  static List<UserProfile> filterProfiles(
    List<UserProfile> profiles,
    UserProfile currentUser,
    AdvancedFilters filters,
  ) {
    return profiles.where((profile) {
      // Filtre par âge
      if (!filters.ageRange.contains(profile.age)) return false;

      // Filtre par distance
      final distance = Geolocator.distanceBetween(
        currentUser.location.latitude,
        currentUser.location.longitude,
        profile.location.latitude,
        profile.location.longitude,
      ) / 1000;
      if (distance > filters.maxDistance) return false;

      // Filtre par éducation
      if (filters.educationLevels.isNotEmpty && 
          !filters.educationLevels.contains(profile.education)) return false;

      // Filtre par profession
      if (filters.professionCategories.isNotEmpty && 
          !filters.professionCategories.contains(profile.professionCategory)) return false;

      // Filtre par intérêts obligatoires
      if (filters.requiredInterests.isNotEmpty) {
        final hasRequiredInterests = filters.requiredInterests
            .every((interest) => profile.interests.contains(interest));
        if (!hasRequiredInterests) return false;
      }

      // Filtre par style de vie
      if (filters.lifestyle != null) {
        if (filters.lifestyle!.smoking != null && 
            profile.lifestyle.smoking != filters.lifestyle!.smoking) return false;
        if (filters.lifestyle!.drinking != null && 
            profile.lifestyle.drinking != filters.lifestyle!.drinking) return false;
        if (filters.lifestyle!.dietType != null && 
            profile.lifestyle.dietType != filters.lifestyle!.dietType) return false;
      }

      return true;
    }).toList();
  }

  /// Trie les profils par score de compatibilité
  static List<MatchedUser> rankProfiles(
    List<UserProfile> profiles,
    UserProfile currentUser,
  ) {
    final matches = profiles.map((profile) {
      final score = calculateCompatibilityScore(currentUser, profile);
      return MatchedUser(
        profile: profile,
        compatibilityScore: score,
        matchReasons: _generateMatchReasons(currentUser, profile, score),
      );
    }).toList();

    // Tri par score de compatibilité décroissant
    matches.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));

    return matches;
  }

  /// Génère les raisons du match pour l'interface utilisateur
  static List<String> _generateMatchReasons(
    UserProfile currentUser,
    UserProfile otherUser,
    double score,
  ) {
    final reasons = <String>[];

    // Intérêts communs
    final commonInterests = currentUser.interests
        .where((interest) => otherUser.interests.contains(interest))
        .take(3)
        .toList();
    if (commonInterests.isNotEmpty) {
      reasons.add('Intérêts communs : ${commonInterests.join(', ')}');
    }

    // Proximité géographique
    final distance = Geolocator.distanceBetween(
      currentUser.location.latitude,
      currentUser.location.longitude,
      otherUser.location.latitude,
      otherUser.location.longitude,
    ) / 1000;
    if (distance < 5) {
      reasons.add('Très proche de vous (${distance.toStringAsFixed(1)} km)');
    } else if (distance < 15) {
      reasons.add('À proximité (${distance.toStringAsFixed(1)} km)');
    }

    // Compatibilité d'âge
    final ageDiff = (currentUser.age - otherUser.age).abs();
    if (ageDiff <= 3) {
      reasons.add('Âge similaire');
    }

    // Style de vie compatible
    if (currentUser.lifestyle.smoking == otherUser.lifestyle.smoking &&
        currentUser.lifestyle.drinking == otherUser.lifestyle.drinking) {
      reasons.add('Style de vie compatible');
    }

    // Score élevé
    if (score >= 85) {
      reasons.add('Compatibilité exceptionnelle !');
    } else if (score >= 70) {
      reasons.add('Très bonne compatibilité');
    }

    return reasons;
  }
}

// Classes de données pour l'algorithme
class UserProfile {
  final String id;
  final String name;
  final int age;
  final UserLocation location;
  final List<String> interests;
  final Lifestyle lifestyle;
  final Personality personality;
  final String education;
  final String professionCategory;
  final UserPreferences preferences;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.location,
    required this.interests,
    required this.lifestyle,
    required this.personality,
    required this.education,
    required this.professionCategory,
    required this.preferences,
  });
}

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

class Lifestyle {
  final int? socialActivity; // 1-5
  final int? fitnessLevel; // 1-5
  final String? dietType;
  final bool? smoking;
  final bool? drinking;

  const Lifestyle({
    this.socialActivity,
    this.fitnessLevel,
    this.dietType,
    this.smoking,
    this.drinking,
  });
}

class Personality {
  final int? extraversion; // 1-5
  final int? openness; // 1-5
  final int? conscientiousness; // 1-5

  const Personality({
    this.extraversion,
    this.openness,
    this.conscientiousness,
  });
}

class UserPreferences {
  final AgeRange ageRange;
  final double maxDistance;

  const UserPreferences({
    required this.ageRange,
    required this.maxDistance,
  });
}

class AgeRange {
  final int min;
  final int max;

  const AgeRange({required this.min, required this.max});

  bool contains(int age) => age >= min && age <= max;
}

class AdvancedFilters {
  final AgeRange ageRange;
  final double maxDistance;
  final List<String> educationLevels;
  final List<String> professionCategories;
  final List<String> requiredInterests;
  final Lifestyle? lifestyle;

  const AdvancedFilters({
    required this.ageRange,
    required this.maxDistance,
    this.educationLevels = const [],
    this.professionCategories = const [],
    this.requiredInterests = const [],
    this.lifestyle,
  });
}

class MatchedUser {
  final UserProfile profile;
  final double compatibilityScore;
  final List<String> matchReasons;

  const MatchedUser({
    required this.profile,
    required this.compatibilityScore,
    required this.matchReasons,
  });
}