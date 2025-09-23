import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String displayName;
  final String email;
  final String gender; // 'male' | 'female' | 'other'
  final DateTime dateOfBirth;
  final int age;
  final List<String> interests;
  final String? avatarUrl;
  final String? bio;
  final String? city;
  final bool certified; // Photo vérifiée par admin
  final int coins; // Pièces virtuelles
  final bool premium;
  final DateTime? premiumExpiresAt;
  final List<String> badges; // Badges obtenus
  final DateTime lastActive;
  final bool disabled;
  final String refCode; // Code de parrainage unique
  final String? referredBy; // Code du parrain
  final DateTime createdAt;
  final Map<String, dynamic>? preferences; // Thème, notifications, etc.
  final double reliabilityScore; // Score de fiabilité (0-100)
  final Map<String, double>? location; // {'lat': double, 'lng': double}

  User({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    required this.age,
    this.interests = const [],
    this.avatarUrl,
    this.bio,
    this.city,
    this.certified = false,
    this.coins = 1000, // 1000 pièces de départ
    this.premium = false,
    this.premiumExpiresAt,
    this.badges = const [],
    required this.lastActive,
    this.disabled = false,
    required this.refCode,
    this.referredBy,
    required this.createdAt,
    this.preferences,
    this.reliabilityScore = 100.0,
    this.location,
  });

  // Factory constructor pour créer depuis Firestore
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return User(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? 'other',
      dateOfBirth: (data['dob'] as Timestamp).toDate(),
      age: data['age'] ?? 0,
      interests: List<String>.from(data['interests'] ?? []),
      avatarUrl: data['avatarUrl'],
      bio: data['bio'],
      city: data['city'],
      certified: data['certified'] ?? false,
      coins: data['coins'] ?? 1000,
      premium: data['premium'] ?? false,
      premiumExpiresAt: data['premiumExpiresAt'] != null 
          ? (data['premiumExpiresAt'] as Timestamp).toDate() 
          : null,
      badges: List<String>.from(data['badges'] ?? []),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      disabled: data['disabled'] ?? false,
      refCode: data['refCode'] ?? '',
      referredBy: data['referredBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      preferences: data['preferences'] as Map<String, dynamic>?,
      reliabilityScore: (data['reliabilityScore'] ?? 100.0).toDouble(),
      location: data['location'] != null 
          ? Map<String, double>.from(data['location']) 
          : null,
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'gender': gender,
      'dob': Timestamp.fromDate(dateOfBirth),
      'age': age,
      'interests': interests,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'city': city,
      'certified': certified,
      'coins': coins,
      'premium': premium,
      'premiumExpiresAt': premiumExpiresAt != null 
          ? Timestamp.fromDate(premiumExpiresAt!) 
          : null,
      'badges': badges,
      'lastActive': Timestamp.fromDate(lastActive),
      'disabled': disabled,
      'refCode': refCode,
      'referredBy': referredBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferences': preferences,
      'reliabilityScore': reliabilityScore,
      'location': location,
    };
  }

  // Calculer l'âge depuis la date de naissance
  static int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  // Copie avec modifications
  User copyWith({
    String? displayName,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    int? age,
    List<String>? interests,
    String? avatarUrl,
    String? bio,
    String? city,
    bool? certified,
    int? coins,
    bool? premium,
    DateTime? premiumExpiresAt,
    List<String>? badges,
    DateTime? lastActive,
    bool? disabled,
    String? refCode,
    String? referredBy,
    Map<String, dynamic>? preferences,
    double? reliabilityScore,
    Map<String, double>? location,
  }) {
    return User(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      certified: certified ?? this.certified,
      coins: coins ?? this.coins,
      premium: premium ?? this.premium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      badges: badges ?? this.badges,
      lastActive: lastActive ?? this.lastActive,
      disabled: disabled ?? this.disabled,
      refCode: refCode ?? this.refCode,
      referredBy: referredBy ?? this.referredBy,
      createdAt: createdAt,
      preferences: preferences ?? this.preferences,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      location: location ?? this.location,
    );
  }

  // Vérifier si Premium est actif
  bool get isPremiumActive {
    if (!premium) return false;
    if (premiumExpiresAt == null) return false;
    return DateTime.now().isBefore(premiumExpiresAt!);
  }

  // Alias pour la compatibilité
  bool get isPremium => isPremiumActive;

  // Obtenir le thème préféré
  String get preferredTheme {
    return preferences?['theme'] ?? 'fun';
  }

  // Vérifier si un badge est possédé
  bool hasBadge(String badgeId) {
    return badges.contains(badgeId);
  }
}