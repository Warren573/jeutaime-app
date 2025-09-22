import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle utilisateur pour l'application JeuTaime
/// Gère toutes les informations de profil et statistiques
class UserModel {
  final String uid;
  final String name;
  final int age;
  final String email;
  final String bio;
  final List<String> photos;
  final List<String> interests;
  final String loveLanguage;
  final String lookingFor;
  final int coins;
  final bool isVerified;
  final DateTime lastActive;
  final DateTime createdAt;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> preferences;
  final String currentBar;
  final double reliabilityScore;
  final int ghostingCount;
  final int totalConversations;
  final int activeConversations;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.email,
    required this.bio,
    required this.photos,
    required this.interests,
    required this.loveLanguage,
    required this.lookingFor,
    required this.coins,
    required this.isVerified,
    required this.lastActive,
    required this.createdAt,
    required this.stats,
    required this.preferences,
    this.currentBar = '',
    this.reliabilityScore = 1000.0,
    this.ghostingCount = 0,
    this.totalConversations = 0,
    this.activeConversations = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 18,
      email: data['email'] ?? '',
      bio: data['profile']?['bio'] ?? '',
      photos: List<String>.from(data['profile']?['photos'] ?? []),
      interests: List<String>.from(data['profile']?['interests'] ?? []),
      loveLanguage: data['profile']?['loveLanguage'] ?? '',
      lookingFor: data['profile']?['lookingFor'] ?? '',
      coins: data['coins'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stats: Map<String, dynamic>.from(data['stats'] ?? {}),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      currentBar: data['currentBar'] ?? '',
      reliabilityScore: (data['stats']?['reliabilityScore'] ?? 1000).toDouble(),
      ghostingCount: data['stats']?['ghostingCount'] ?? 0,
      totalConversations: data['stats']?['totalConversations'] ?? 0,
      activeConversations: data['stats']?['activeConversations'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'profile': {
        'bio': bio,
        'photos': photos,
        'interests': interests,
        'loveLanguage': loveLanguage,
        'lookingFor': lookingFor,
      },
      'coins': coins,
      'isVerified': isVerified,
      'lastActive': FieldValue.serverTimestamp(),
      'createdAt': createdAt,
      'stats': {
        ...stats,
        'reliabilityScore': reliabilityScore,
        'ghostingCount': ghostingCount,
        'totalConversations': totalConversations,
        'activeConversations': activeConversations,
      },
      'preferences': preferences,
      'currentBar': currentBar,
    };
  }

  // Getters utiles
  String get mainPhoto => photos.isNotEmpty ? photos[0] : '';
  bool get isOnline => DateTime.now().difference(lastActive).inMinutes < 15;
  String get onlineStatus => isOnline ? 'En ligne' : 'Vu il y a ${_formatLastSeen()}';
  
  String _formatLastSeen() {
    final difference = DateTime.now().difference(lastActive);
    if (difference.inMinutes < 60) return '${difference.inMinutes}min';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}j';
  }

  /// Calcule la compatibilité avec un autre utilisateur
  double getCompatibilityWith(UserModel other) {
    double score = 0.0;
    
    // Langages d'amour compatibles
    if (loveLanguage == other.loveLanguage) score += 30;
    
    // Intérêts communs
    int commonInterests = interests.where((interest) => other.interests.contains(interest)).length;
    score += (commonInterests * 10).clamp(0, 40);
    
    // Différence d'âge
    int ageDiff = (age - other.age).abs();
    if (ageDiff <= 3) score += 20;
    else if (ageDiff <= 7) score += 10;
    
    // Score de fiabilité
    score += (reliabilityScore / 100).clamp(0, 10);
    
    return score.clamp(0, 100);
  }

  /// Copie l'utilisateur avec des modifications
  UserModel copyWith({
    String? name,
    int? age,
    String? bio,
    List<String>? photos,
    List<String>? interests,
    String? loveLanguage,
    String? lookingFor,
    int? coins,
    bool? isVerified,
    DateTime? lastActive,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? preferences,
    String? currentBar,
    double? reliabilityScore,
    int? ghostingCount,
    int? totalConversations,
    int? activeConversations,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      age: age ?? this.age,
      email: email,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      interests: interests ?? this.interests,
      loveLanguage: loveLanguage ?? this.loveLanguage,
      lookingFor: lookingFor ?? this.lookingFor,
      coins: coins ?? this.coins,
      isVerified: isVerified ?? this.isVerified,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt,
      stats: stats ?? this.stats,
      preferences: preferences ?? this.preferences,
      currentBar: currentBar ?? this.currentBar,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      ghostingCount: ghostingCount ?? this.ghostingCount,
      totalConversations: totalConversations ?? this.totalConversations,
      activeConversations: activeConversations ?? this.activeConversations,
    );
  }
}
