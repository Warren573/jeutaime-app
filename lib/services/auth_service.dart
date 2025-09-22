import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connexion
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Inscription
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Création du profil utilisateur
    await _createUserProfile(result.user!, name, age);

    return result;
  }

  // Création du profil utilisateur dans Firestore
  static Future<void> _createUserProfile(User user, String name, int age) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'age': age,
      'coins': 100, // Points de départ
      'isVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
      'profile': {
        'bio': '',
        'interests': [],
        'photos': [],
        'loveLanguage': '',
        'lookingFor': '',
      },
      'stats': {
        'totalMatches': 0,
        'totalConversations': 0,
        'ghostingScore': 0, // Négatif = ghosteur, positif = ghosté
        'reliabilityScore': 100, // Score de fiabilité
      },
      'preferences': {
        'funMode': true,
        'ageMin': 18,
        'ageMax': 35,
        'distance': 50,
        'showOnline': true,
      },
    });
  }

  // Déconnexion
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Utilisateur actuel
  static User? get currentUser => _auth.currentUser;

  // Stream des changements d'état
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}
