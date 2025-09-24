// import 'dart:io'; // Supprimé car non utilisé
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class PhotoService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ImagePicker _picker = ImagePicker();

  // Prendre ou choisir une photo
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Erreur sélection photo: $e');
      return null;
    }
  }

  // Prendre plusieurs photos
  static Future<List<XFile>?> pickMultipleImages({int maxImages = 6}) async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (images != null && images.length > maxImages) {
        return images.take(maxImages).toList();
      }
      
      return images;
    } catch (e) {
      print('Erreur sélection multiple: $e');
      return null;
    }
  }

  // Upload d'une photo de profil
  static Future<String?> uploadProfilePhoto(XFile imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Redimensionner et compresser l'image
      final processedImageData = await _processImage(imageFile);
      if (processedImageData == null) return null;

      // Upload vers Firebase Storage
      final ref = _storage.ref().child('profile_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putData(processedImageData);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Mettre à jour le profil utilisateur
      await _firestore.collection('users').doc(user.uid).update({
        'profile.photos': FieldValue.arrayUnion([downloadUrl]),
      });

      return downloadUrl;
    } catch (e) {
      print('Erreur upload photo: $e');
      return null;
    }
  }

  // Upload de multiple photos
  static Future<List<String>> uploadMultiplePhotos(List<XFile> imageFiles, {
    Function(int uploaded, int total)? onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    List<String> uploadedUrls = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        
        // Redimensionner et compresser
        final processedImageData = await _processImage(imageFile);
        if (processedImageData == null) continue;

        // Upload vers Firebase Storage
        final ref = _storage.ref().child('profile_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
        final uploadTask = ref.putData(processedImageData);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        uploadedUrls.add(downloadUrl);
        
        // Callback de progression
        onProgress?.call(i + 1, imageFiles.length);
      }

      // Mettre à jour le profil avec toutes les photos
      if (uploadedUrls.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update({
          'profile.photos': FieldValue.arrayUnion(uploadedUrls),
        });
      }

      return uploadedUrls;
    } catch (e) {
      print('Erreur upload multiple: $e');
      return uploadedUrls;
    }
  }

  // Supprimer une photo
  static Future<bool> deletePhoto(String photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Supprimer de Firebase Storage
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();

      // Retirer de la liste des photos utilisateur
      await _firestore.collection('users').doc(user.uid).update({
        'profile.photos': FieldValue.arrayRemove([photoUrl]),
      });

      return true;
    } catch (e) {
      print('Erreur suppression photo: $e');
      return false;
    }
  }

  // Réorganiser l'ordre des photos
  static Future<bool> reorderPhotos(List<String> orderedPhotoUrls) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'profile.photos': orderedPhotoUrls,
      });
      return true;
    } catch (e) {
      print('Erreur réorganisation photos: $e');
      return false;
    }
  }

  // Upload photo de vérification d'identité
  static Future<String?> uploadVerificationPhoto(XFile imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Traitement spécial pour la vérification (moins de compression)
      final processedImageData = await _processImage(imageFile, forVerification: true);
      if (processedImageData == null) return null;

      // Upload dans un dossier séparé pour la vérification
      final ref = _storage.ref().child('verification_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putData(processedImageData);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Marquer comme en attente de vérification
      await _firestore.collection('users').doc(user.uid).update({
        'verificationPhoto': downloadUrl,
        'verificationStatus': 'pending',
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      print('Erreur upload vérification: $e');
      return null;
    }
  }

  // Upload photo pour chat (temporaire)
  static Future<String?> uploadChatPhoto(XFile imageFile, String conversationId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final processedImageData = await _processImage(imageFile);
      if (processedImageData == null) return null;

      final ref = _storage.ref().child('chat_photos/$conversationId/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putData(processedImageData);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Erreur upload photo chat: $e');
      return null;
    }
  }

  // Obtenir les photos d'un utilisateur
  static Future<List<String>> getUserPhotos(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        return List<String>.from(data['profile']?['photos'] ?? []);
      }
      return [];
    } catch (e) {
      print('Erreur récupération photos: $e');
      return [];
    }
  }

  // Analyser et modérer automatiquement une image
  static Future<Map<String, dynamic>> analyzeImage(Uint8List imageData) async {
    // TODO: Intégrer avec Google Vision API ou autre service de modération
    // Pour l'instant, retourne des valeurs par défaut
    return {
      'isAppropriate': true,
      'confidence': 0.95,
      'detectedObjects': [],
      'hasText': false,
      'adultContent': false,
      'violenceContent': false,
    };
  }

  // Créer une miniature
  static Future<Uint8List?> createThumbnail(XFile imageFile, {int size = 150}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;

      // Redimensionner en carré
      final thumbnail = img.copyResizeCropSquare(originalImage, size: size);
      
      // Encoder en JPEG
      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 85));
    } catch (e) {
      print('Erreur création miniature: $e');
      return null;
    }
  }

  // Méthodes privées

  static Future<Uint8List?> _processImage(XFile imageFile, {bool forVerification = false}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;

      // Redimensionner si nécessaire
      img.Image processedImage = originalImage;
      
      final maxWidth = forVerification ? 1920 : 1200;
      final maxHeight = forVerification ? 1920 : 1200;
      
      if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
        processedImage = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height ? maxWidth : null,
          height: originalImage.height > originalImage.width ? maxHeight : null,
        );
      }

      // Corriger l'orientation EXIF si nécessaire
      processedImage = img.bakeOrientation(processedImage);

      // Compression JPEG
      final quality = forVerification ? 95 : 85;
      return Uint8List.fromList(img.encodeJpg(processedImage, quality: quality));
    } catch (e) {
      print('Erreur traitement image: $e');
      return null;
    }
  }

  // Nettoyage des photos orphelines (à appeler périodiquement)
  static Future<void> cleanupOrphanedPhotos() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Récupérer toutes les photos dans le dossier de l'utilisateur
      final ref = _storage.ref().child('profile_photos/${user.uid}');
      final listResult = await ref.listAll();

      // Récupérer les photos actuellement utilisées
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final usedPhotos = List<String>.from(userDoc.data()?['profile']?['photos'] ?? []);

      // Supprimer les photos non utilisées
      for (final item in listResult.items) {
        final downloadUrl = await item.getDownloadURL();
        if (!usedPhotos.contains(downloadUrl)) {
          await item.delete();
          print('Photo orpheline supprimée: $downloadUrl');
        }
      }
    } catch (e) {
      print('Erreur nettoyage photos: $e');
    }
  }

  // Calculer la taille totale utilisée
  static Future<int> calculateStorageUsed() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final ref = _storage.ref().child('profile_photos/${user.uid}');
      final listResult = await ref.listAll();

      int totalSize = 0;
      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      return totalSize;
    } catch (e) {
      print('Erreur calcul taille: $e');
      return 0;
    }
  }

  // Vérifier les quotas et limites
  static Future<Map<String, dynamic>> checkLimits() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {'canUpload': false, 'reason': 'Non connecté'};

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final photos = List<String>.from(userDoc.data()?['profile']?['photos'] ?? []);
      
      const int maxPhotos = 6;
      const int maxSizeMB = 50;

      if (photos.length >= maxPhotos) {
        return {'canUpload': false, 'reason': 'Limite de $maxPhotos photos atteinte'};
      }

      final storageUsed = await calculateStorageUsed();
      final storageUsedMB = storageUsed / (1024 * 1024);

      if (storageUsedMB >= maxSizeMB) {
        return {'canUpload': false, 'reason': 'Limite de stockage atteinte (${maxSizeMB}MB)'};
      }

      return {
        'canUpload': true,
        'photosUsed': photos.length,
        'maxPhotos': maxPhotos,
        'storageUsedMB': storageUsedMB.round(),
        'maxStorageMB': maxSizeMB,
      };
    } catch (e) {
      return {'canUpload': false, 'reason': 'Erreur de vérification'};
    }
  }
}