
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();
  
  // Firebase instances
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;
  
  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  // Current user
  User? get currentUser => auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
  // Auth methods
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential result = await auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print('Erreur connexion anonyme: $e');
      return null;
    }
  }
  
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Erreur connexion email: $e');
      return null;
    }
  }

  // Admin methods
  Future<bool> checkAdminAccess() async {
    try {
      if (currentUser == null) return false;
      
      final adminDoc = await firestore
          .collection('admins')
          .doc(currentUser!.uid)
          .get();
      
      return adminDoc.exists;
    } catch (e) {
      print('Erreur vérification admin: $e');
      return false;
    }
  }

  Future<bool> createAdminAccount({
    required String userId,
    required String email,
    required String displayName,
    int coins = 1000,
  }) async {
    try {
      // Create admin document
      await firestore.collection('admins').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'permissions': [
          'users_management',
          'bars_management',
          'games_management',
          'reports_management',
          'settings_management',
        ],
      });

      // Also create user profile
      await firestore.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'coins': coins,
        'level': 99,
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erreur création admin: $e');
      return false;
    }
  }

  // Get app statistics
  Future<Map<String, dynamic>> getAppStatistics() async {
    try {
      final usersCount = await firestore.collection('users').count().get();
      final barsCount = await firestore.collection('bars').count().get();
      final reportsCount = await firestore.collection('reports').where('status', isEqualTo: 'open').count().get();

      // Get active users (last 24 hours)
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      final activeUsersQuery = await firestore
          .collection('users')
          .where('lastActive', isGreaterThan: Timestamp.fromDate(yesterday))
          .count()
          .get();

      return {
        'totalUsers': usersCount.count,
        'activeUsers': activeUsersQuery.count,
        'totalBars': barsCount.count,
        'openReports': reportsCount.count,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Erreur récupération stats: $e');
      return {};
    }
  }

  // Get users list with pagination
  Future<List<Map<String, dynamic>>> getUsers({int limit = 50}) async {
    try {
      final usersQuery = await firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return usersQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Erreur récupération utilisateurs: $e');
      return [];
    }
  }

  // Get reports
  Future<List<Map<String, dynamic>>> getReports({String status = 'open'}) async {
    try {
      final reportsQuery = await firestore
          .collection('reports')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return reportsQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Erreur récupération rapports: $e');
      return [];
    }
  }

  // Ban user
  Future<bool> banUser(String userId, {String? reason}) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'isBanned': true,
        'banReason': reason ?? 'Violation des conditions d\'utilisation',
        'bannedAt': FieldValue.serverTimestamp(),
      });

      // Add to banned users collection
      await firestore.collection('banned_users').doc(userId).set({
        'reason': reason ?? 'Violation des conditions d\'utilisation',
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedBy': currentUser?.uid,
      });

      return true;
    } catch (e) {
      print('Erreur bannissement: $e');
      return false;
    }
  }

  // Create new bar
  Future<bool> createBar({
    required String name,
    required String type,
    required String description,
    int maxParticipants = 8,
    bool isPremiumOnly = false,
    List<String> availableGames = const [],
  }) async {
    try {
      await firestore.collection('bars').add({
        'name': name,
        'type': type,
        'description': description,
        'maxParticipants': maxParticipants,
        'isPremiumOnly': isPremiumOnly,
        'availableGames': availableGames,
        'isActive': true,
        'activeUsers': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser?.uid,
      });

      return true;
    } catch (e) {
      print('Erreur création bar: $e');
      return false;
    }
  }

  // Update bar
  Future<bool> updateBar(String barId, Map<String, dynamic> updates) async {
    try {
      await firestore.collection('bars').doc(barId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': currentUser?.uid,
      });

      return true;
    } catch (e) {
      print('Erreur mise à jour bar: $e');
      return false;
    }
  }

  // Resolve report
  Future<bool> resolveReport(String reportId, {String? adminComment}) async {
    try {
      await firestore.collection('reports').doc(reportId).update({
        'status': 'resolved',
        'adminComment': adminComment ?? '',
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': currentUser?.uid,
      });

      return true;
    } catch (e) {
      print('Erreur résolution rapport: $e');
      return false;
    }
  }
  
  Future<User?> createAccount(String email, String password) async {
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Erreur création compte: $e');
      return null;
    }
  }
  
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print('Erreur déconnexion: $e');
    }
  }
  
  // User profile methods
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Erreur récupération profil: $e');
      return null;
    }
  }
  
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Erreur mise à jour profil: $e');
      return false;
    }
  }
  
  Future<bool> createUserProfile({
    required String userId,
    required String email,
    required String displayName,
    int coins = 100, // Pièces de départ
  }) async {
    try {
      await firestore.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'coins': coins,
        'premium': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastDailyBonus': null,
        'ghostingStrikes': 0,
        'badges': [],
        'profilePhotoUrl': null,
        'isPhotoVerified': false,
        'referralCode': FirebaseService.generateReferralCode(),
        'referredBy': null,
      });
      return true;
    } catch (e) {
      print('Erreur création profil: $e');
      return false;
    }
  }
  
  Future<bool> createAdminAccount({
    required String userId,
    required String email,
    required String displayName,
    int coins = 1000,
  }) async {
    try {
      await firestore.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'coins': coins,
        'premium': true,
        'admin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastDailyBonus': null,
        'ghostingStrikes': 0,
        'badges': ['admin', 'premium', 'founder'],
        'profilePhotoUrl': null,
        'isPhotoVerified': true,
        'referralCode': FirebaseService.generateReferralCode(),
        'referredBy': null,
        'accessLevel': 'full',
      });
      return true;
    } catch (e) {
      print('Erreur création compte admin: $e');
      return false;
    }
  }

  static String generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (index) => chars[(random + index) % chars.length]).join();
  }
}
