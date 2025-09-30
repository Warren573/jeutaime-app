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
        'referralCode': _generateReferralCode(),
        'referredBy': null,
        'accessLevel': 'full',
      });
      return true;
    } catch (e) {
      print('Erreur création compte admin: $e');
      return false;
    }
  }
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
        'referralCode': _generateReferralCode(),
        'referredBy': null,
      });
      return true;
    } catch (e) {
      print('Erreur création profil: $e');
      return false;
    }
  }
  
  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (index) => chars[(random + index) % chars.length]).join();
  }
}