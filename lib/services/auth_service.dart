import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_user;
import 'dart:math';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream de l'état de l'authentification
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  static User? get currentUser => _auth.currentUser;

  // Générer un code de parrainage unique
  static String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Inscription par email
  static Future<UserCredential?> signUpWithEmail({
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
    try {
      // Créer le compte Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Mettre à jour le displayName
      await user.updateDisplayName(displayName);

      // Créer le profil utilisateur dans Firestore
      final userProfile = app_user.User(
        uid: user.uid,
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
        preferences: {
          'theme': 'fun',
          'notifications': {
            'letters': true,
            'bars': true,
            'matches': true,
          },
        },
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toFirestore());

      // Appliquer le code de parrainage si fourni
      if (referralCode != null && referralCode.isNotEmpty) {
        await _applyReferralCode(user.uid, referralCode);
      }

      return credential;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  // Connexion par email
  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour lastActive
      if (credential.user != null) {
        await _updateLastActive(credential.user!.uid);
      }

      return credential;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Alias pour signIn (utilisé par login_screen.dart)
  static Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    return signInWithEmail(email: email, password: password);
  }

  // Alias pour signUp (utilisé par register_screen.dart)
  static Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    String? city,
    String? bio,
    String? referralCode,
  }) async {
    // Calculer la date de naissance approximative à partir de l'âge
    final dateOfBirth = DateTime.now().subtract(Duration(days: age * 365));
    
    return signUpWithEmail(
      email: email,
      password: password,
      displayName: name,
      gender: 'other', // Valeur par défaut, peut être mise à jour plus tard
      dateOfBirth: dateOfBirth,
      interests: [],
      city: city,
      bio: bio,
      referralCode: referralCode,
    );
  }

  // Connexion avec Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        // Vérifier si c'est un nouvel utilisateur
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // Nouveau utilisateur Google - créer le profil de base
          final userProfile = app_user.User(
            uid: user.uid,
            displayName: user.displayName ?? '',
            email: user.email ?? '',
            gender: 'other', // À compléter dans l'onboarding
            dateOfBirth: DateTime.now().subtract(Duration(days: 25 * 365)), // 25 ans par défaut
            age: 25,
            interests: [],
            avatarUrl: user.photoURL,
            lastActive: DateTime.now(),
            refCode: _generateReferralCode(),
            createdAt: DateTime.now(),
            preferences: {
              'theme': 'fun',
              'notifications': {
                'letters': true,
                'bars': true,
                'matches': true,
              },
            },
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userProfile.toFirestore());
        } else {
          // Utilisateur existant - mettre à jour lastActive
          await _updateLastActive(user.uid);
        }
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Déconnexion
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Réinitialiser le mot de passe
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Supprimer le compte
  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Supprimer les données Firestore
    await _firestore.collection('users').doc(user.uid).delete();
    
    // Supprimer le compte Firebase Auth
    await user.delete();
  }

  // Obtenir le profil utilisateur
  static Future<app_user.User?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return app_user.User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Stream du profil utilisateur
  static Stream<app_user.User?> getUserProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? app_user.User.fromFirestore(doc) : null);
  }

  // Mettre à jour le profil
  static Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(uid).update(updates);
  }

  // Uploader une photo de certification
  static Future<void> uploadCertificationPhoto(String uid, String photoUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': photoUrl,
      'certificationPending': true,
      'certificationSubmittedAt': Timestamp.now(),
    });

    // Créer une tâche pour l'admin
    await _firestore.collection('certificationQueue').add({
      'uid': uid,
      'photoUrl': photoUrl,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  // Appliquer un code de parrainage
  static Future<bool> _applyReferralCode(String uid, String code) async {
    try {
      final referralQuery = await _firestore
          .collection('referrals')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (referralQuery.docs.isEmpty) {
        return false; // Code invalide
      }

      final referralDoc = referralQuery.docs.first;
      final inviterUid = referralDoc.data()['inviterUid'] as String;

      if (inviterUid == uid) {
        return false; // Ne peut pas se parrainer soi-même
      }

      // Mettre à jour l'utilisateur
      await _firestore.collection('users').doc(uid).update({
        'referredBy': code,
      });

      // Mettre à jour le referral
      await referralDoc.reference.update({
        'usedBy': FieldValue.arrayUnion([uid]),
      });

      return true;
    } catch (e) {
      print('Error applying referral code: $e');
      return false;
    }
  }

  // Mettre à jour la dernière activité
  static Future<void> _updateLastActive(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastActive': Timestamp.now(),
    });
  }

  // Vérifier si un email existe déjà
  static Future<bool> emailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
