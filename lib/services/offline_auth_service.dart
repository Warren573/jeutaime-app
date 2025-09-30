import 'dart:convert';
import 'dart:math';
import '../models/user.dart' as app_user;

/// Service d'authentification offline pour le mode de développement
/// Simule Firebase Auth avec des données locales
class OfflineAuthService {
  static final Map<String, app_user.User> _users = {};
  static app_user.User? _currentUser;
  static final List<Function(app_user.User?)> _authListeners = [];

  /// Utilisateur actuel
  static app_user.User? get currentUser => _currentUser;

  /// Stream de l'état de l'authentification
  static Stream<app_user.User?> get authStateChanges async* {
    yield _currentUser;
    // Simule un stream continu
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield _currentUser;
    }
  }

  /// Générer un UID unique
  static String _generateUID() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return 'offline_${List.generate(20, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  /// Générer un code de parrainage unique
  static String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Inscription par email (simulation)
  static Future<app_user.User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required DateTime dateOfBirth,
    required List<String> interests,
    String? city,
    String? bio,
    String? referralCode,
  }) async {
    // Simule un délai réseau
    await Future.delayed(Duration(milliseconds: 500));

    // Vérifier si l'email existe déjà
    if (_users.values.any((user) => user.email == email)) {
      throw Exception('Email déjà utilisé');
    }

    // Créer l'utilisateur
    final uid = _generateUID();
    final user = app_user.User(
      uid: uid,
      displayName: displayName,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
      age: app_user.User.calculateAge(dateOfBirth),
      interests: interests,
      city: city,
      bio: bio,
      lastActive: DateTime.now(),
      refCode: _generateReferralCode(),
      referredBy: referralCode,
      createdAt: DateTime.now(),
      // Commencer avec des ressources de base
      coins: 100,
      preferences: {
        'theme': 'fun',
        'notifications': {
          'letters': true,
          'bars': true,
          'matches': true,
        },
      },
    );

    // Stocker l'utilisateur
    _users[uid] = user;
    _currentUser = user;

    // Notifier les listeners
    _notifyAuthListeners();

    print('✅ Utilisateur créé en mode offline: ${user.displayName}');
    return user;
  }

  /// Alias pour signUp (compatibilité)
  static Future<app_user.User?> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    String? city,
    String? bio,
    String? referralCode,
  }) async {
    final dateOfBirth = DateTime.now().subtract(Duration(days: age * 365));
    
    return signUpWithEmail(
      email: email,
      password: password,
      displayName: name,
      gender: 'autre', // Valeur par défaut
      dateOfBirth: dateOfBirth,
      interests: [],
      city: city,
      bio: bio,
      referralCode: referralCode,
    );
  }

  /// Connexion par email (simulation)
  static Future<app_user.User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Simule un délai réseau
    await Future.delayed(Duration(milliseconds: 300));

    // Chercher l'utilisateur
    final user = _users.values.cast<app_user.User?>().firstWhere(
      (user) => user?.email == email,
      orElse: () => null,
    );

    if (user == null) {
      throw Exception('Utilisateur non trouvé');
    }

    // Mettre à jour lastActive - créer une nouvelle instance
    _users[user.uid] = user.copyWith(lastActive: DateTime.now());
    _currentUser = user;

    // Notifier les listeners
    _notifyAuthListeners();

    print('✅ Connexion réussie en mode offline: ${user.displayName}');
    return user;
  }

  /// Alias pour signIn (compatibilité)
  static Future<app_user.User?> signIn({
    required String email,
    required String password,
  }) async {
    return signInWithEmail(email: email, password: password);
  }

  /// Connexion Google (simulation avec utilisateur de test)
  static Future<app_user.User?> signInWithGoogle() async {
    await Future.delayed(Duration(milliseconds: 800));

    // Créer un utilisateur Google de test
    final uid = _generateUID();
    final user = app_user.User(
      uid: uid,
      displayName: 'Utilisateur Google Test',
      email: 'test.google@jeutaime.app',
      gender: 'autre',
      dateOfBirth: DateTime.now().subtract(Duration(days: 25 * 365)),
      age: 25,
      interests: ['voyage', 'cuisine', 'musique'],
      avatarUrl: 'https://via.placeholder.com/200/4CAF50/white?text=GT',
      lastActive: DateTime.now(),
      refCode: _generateReferralCode(),
      createdAt: DateTime.now(),
      coins: 150,
      preferences: {
        'theme': 'romantic',
        'notifications': {
          'letters': true,
          'bars': true,
          'matches': true,
        },
      },
    );

    _users[uid] = user;
    _currentUser = user;
    _notifyAuthListeners();

    print('✅ Connexion Google simulée: ${user.displayName}');
    return user;
  }

  /// Déconnexion
  static Future<void> signOut() async {
    await Future.delayed(Duration(milliseconds: 200));
    _currentUser = null;
    _notifyAuthListeners();
    print('✅ Déconnexion réussie');
  }

  /// Obtenir le profil utilisateur
  static Future<app_user.User?> getUserProfile(String uid) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _users[uid];
  }

  /// Stream du profil utilisateur
  static Stream<app_user.User?> getUserProfileStream(String uid) async* {
    yield _users[uid];
    // Simule des mises à jour
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      yield _users[uid];
    }
  }

  /// Mettre à jour le profil
  static Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    final user = _users[uid];
    if (user != null) {
      // Créer une nouvelle instance avec les mises à jour
      _users[uid] = user.copyWith(
        displayName: updates['displayName'] ?? user.displayName,
        bio: updates['bio'] ?? user.bio,
        city: updates['city'] ?? user.city,
        coins: updates['coins'] ?? user.coins,
        lastActive: DateTime.now(),
      );
      
      print('✅ Profil mis à jour: ${_users[uid]?.displayName}');
    }
  }

  /// Vérifier si un email existe
  static Future<bool> emailExists(String email) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _users.values.any((user) => user.email == email);
  }

  /// Créer des utilisateurs de test automatiquement
  static Future<void> initializeTestUsers() async {
    if (_users.isEmpty) {
      print('🎭 Création des utilisateurs de test...');
      
      // Utilisateur test 1 - Profil romantique
      await _createTestUser(
        displayName: 'Emma Martin',
        email: 'emma@test.com',
        gender: 'femme',
        age: 26,
        interests: ['romantique', 'cuisine', 'voyages'],
        bio: 'Passionnée de cuisine et de couchers de soleil 🌅',
        city: 'Paris',
        theme: 'romantic',
      );

      // Utilisateur test 2 - Profil humoristique
      await _createTestUser(
        displayName: 'Thomas Dupont',
        email: 'thomas@test.com',
        gender: 'homme',
        age: 28,
        interests: ['humour', 'cinéma', 'sport'],
        bio: 'Expert en blagues nulles et marathons Netflix 🎬',
        city: 'Lyon',
        theme: 'fun',
      );

      // Utilisateur test 3 - Profil pirate
      await _createTestUser(
        displayName: 'Captain Sarah',
        email: 'sarah@test.com',
        gender: 'femme',
        age: 24,
        interests: ['aventure', 'mer', 'mystères'],
        bio: 'À la recherche de trésors cachés et d\'aventures 🏴‍☠️',
        city: 'Marseille',
        theme: 'pirate',
      );

      print('✅ ${_users.length} utilisateurs de test créés');
    }
  }

  static Future<void> _createTestUser({
    required String displayName,
    required String email,
    required String gender,
    required int age,
    required List<String> interests,
    required String bio,
    required String city,
    required String theme,
  }) async {
    final uid = _generateUID();
    final user = app_user.User(
      uid: uid,
      displayName: displayName,
      email: email,
      gender: gender,
      dateOfBirth: DateTime.now().subtract(Duration(days: age * 365)),
      age: age,
      interests: interests,
      bio: bio,
      city: city,
      lastActive: DateTime.now().subtract(Duration(hours: Random().nextInt(24))),
      refCode: _generateReferralCode(),
      createdAt: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      coins: 50 + Random().nextInt(200),
      avatarUrl: 'https://via.placeholder.com/200/${_getThemeColor(theme)}/white?text=${displayName[0]}',
      preferences: {
        'theme': theme,
        'notifications': {
          'letters': true,
          'bars': true,
          'matches': true,
        },
      },
    );

    _users[uid] = user;
  }

  static String _getThemeColor(String theme) {
    switch (theme) {
      case 'romantic': return 'FF69B4';
      case 'fun': return '4CAF50';
      case 'pirate': return '8B4513';
      default: return '2196F3';
    }
  }

  /// Notifier les listeners d'état d'auth
  static void _notifyAuthListeners() {
    for (final listener in _authListeners) {
      try {
        listener(_currentUser);
      } catch (e) {
        print('Erreur dans auth listener: $e');
      }
    }
  }

  /// Ajouter un listener d'état d'auth
  static void addAuthStateListener(Function(app_user.User?) listener) {
    _authListeners.add(listener);
  }

  /// Retirer un listener d'état d'auth
  static void removeAuthStateListener(Function(app_user.User?) listener) {
    _authListeners.remove(listener);
  }

  /// Reset des données (utile pour les tests)
  static void reset() {
    _users.clear();
    _currentUser = null;
    _authListeners.clear();
  }
}