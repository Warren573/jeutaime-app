import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LetterService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Envoyer une lettre
  static Future<void> sendLetter({
    required String recipientId,
    required String subject,
    required String content,
    required String paperType,
    required String inkColor,
    required bool isAnonymous,
    required int cost,
  }) async {
    if (_auth.currentUser == null) throw 'Utilisateur non connecté';

    String senderId = _auth.currentUser!.uid;

    // Vérifier si l'utilisateur a assez de coins
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(senderId).get();
    int currentCoins = userDoc.get('coins') ?? 0;
    
    if (currentCoins < cost) {
      throw 'Pas assez de coins pour envoyer cette lettre (${cost} requis, ${currentCoins} disponibles)';
    }

    // Créer la lettre
    DocumentReference letterRef = await _firestore.collection('letters').add({
      'senderId': senderId,
      'recipientId': recipientId,
      'subject': subject,
      'content': content,
      'paperType': paperType,
      'inkColor': inkColor,
      'isAnonymous': isAnonymous,
      'cost': cost,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'isArchived': false,
      'responses': [], // Pour les échanges de lettres
      'barContext': 'romantic', // D'où vient la lettre
    });

    // Débiter les coins
    await _firestore.collection('users').doc(senderId).update({
      'coins': FieldValue.increment(-cost),
      'stats.lettersSent': FieldValue.increment(1),
    });

    // Récompenser le destinataire (pour l'encourager à répondre)
    await _firestore.collection('users').doc(recipientId).update({
      'coins': FieldValue.increment(2), // Petit bonus
      'stats.lettersReceived': FieldValue.increment(1),
    });

    // Créer une notification
    await _firestore.collection('notifications').add({
      'userId': recipientId,
      'type': 'letter_received',
      'title': isAnonymous ? '💌 Lettre mystère !' : '💌 Nouvelle lettre !',
      'message': isAnonymous 
        ? 'Vous avez reçu une lettre anonyme'
        : 'Vous avez reçu une lettre avec le sujet: "$subject"',
      'data': {
        'letterId': letterRef.id,
        'isAnonymous': isAnonymous,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Archiver dans la boîte à souvenirs de l'expéditeur
    await _archiveLetterForSender(letterRef.id, senderId, recipientId, subject);
  }

  // Archiver une lettre envoyée
  static Future<void> _archiveLetterForSender(
    String letterId, 
    String senderId, 
    String recipientId, 
    String subject
  ) async {
    await _firestore.collection('memory_box').add({
      'userId': senderId,
      'type': 'letter_sent',
      'title': 'Lettre envoyée: $subject',
      'description': 'Lettre envoyée dans le Bar Romantique',
      'data': {
        'letterId': letterId,
        'recipientId': recipientId,
        'subject': subject,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'barContext': 'romantic',
    });
  }

  // Récupérer les lettres reçues
  static Future<List<Map<String, dynamic>>> getReceivedLetters() async {
    if (_auth.currentUser == null) return [];

    QuerySnapshot snapshot = await _firestore.collection('letters')
      .where('recipientId', isEqualTo: _auth.currentUser!.uid)
      .orderBy('sentAt', descending: true)
      .get();

    List<Map<String, dynamic>> letters = [];
    
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic> letterData = doc.data() as Map<String, dynamic>;
      letterData['id'] = doc.id;
      
      // Récupérer les infos de l'expéditeur (sauf si anonyme)
      if (!letterData['isAnonymous']) {
        DocumentSnapshot senderDoc = await _firestore
          .collection('users')
          .doc(letterData['senderId'])
          .get();
        
        if (senderDoc.exists) {
          letterData['senderName'] = senderDoc.get('name');
          letterData['senderPhoto'] = senderDoc.get('profile.photos')?[0] ?? '';
        }
      }
      
      letters.add(letterData);
    }

    return letters;
  }

  // Marquer une lettre comme lue
  static Future<void> markAsRead(String letterId) async {
    await _firestore.collection('letters').doc(letterId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });

    // Archiver dans la boîte à souvenirs du destinataire
    DocumentSnapshot letterDoc = await _firestore.collection('letters').doc(letterId).get();
    if (letterDoc.exists) {
      Map<String, dynamic> letterData = letterDoc.data() as Map<String, dynamic>;
      
      await _firestore.collection('memory_box').add({
        'userId': _auth.currentUser!.uid,
        'type': 'letter_received',
        'title': 'Lettre reçue: ${letterData['subject']}',
        'description': letterData['isAnonymous'] 
          ? 'Lettre mystère du Bar Romantique'
          : 'Lettre reçue dans le Bar Romantique',
        'data': {
          'letterId': letterId,
          'subject': letterData['subject'],
          'content': letterData['content'],
          'isAnonymous': letterData['isAnonymous'],
        },
        'createdAt': FieldValue.serverTimestamp(),
        'barContext': 'romantic',
      });
    }
  }

  // Répondre à une lettre
  static Future<void> replyToLetter({
    required String originalLetterId,
    required String content,
    required String paperType,
    required String inkColor,
    required int cost,
  }) async {
    if (_auth.currentUser == null) throw 'Utilisateur non connecté';

    // Récupérer la lettre originale
    DocumentSnapshot originalLetter = await _firestore
      .collection('letters')
      .doc(originalLetterId)
      .get();
    
    if (!originalLetter.exists) throw 'Lettre originale introuvable';

    Map<String, dynamic> originalData = originalLetter.data() as Map<String, dynamic>;
    String originalSenderId = originalData['senderId'];

    // Vérifier les coins
    DocumentSnapshot userDoc = await _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .get();
    int currentCoins = userDoc.get('coins') ?? 0;
    
    if (currentCoins < cost) {
      throw 'Pas assez de coins pour envoyer cette réponse';
    }

    // Ajouter la réponse à la lettre originale
    await _firestore.collection('letters').doc(originalLetterId).update({
      'responses': FieldValue.arrayUnion([{
        'from': _auth.currentUser!.uid,
        'content': content,
        'paperType': paperType,
        'inkColor': inkColor,
        'sentAt': FieldValue.serverTimestamp(),
      }])
    });

    // Débiter les coins
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'coins': FieldValue.increment(-cost),
    });

    // Notifier l'expéditeur original
    await _firestore.collection('notifications').add({
      'userId': originalSenderId,
      'type': 'letter_reply',
      'title': '💌 Réponse à votre lettre !',
      'message': 'Votre lettre "${originalData['subject']}" a reçu une réponse',
      'data': {
        'letterId': originalLetterId,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // Statistiques des lettres
  static Future<Map<String, int>> getLetterStats() async {
    if (_auth.currentUser == null) return {};

    DocumentSnapshot userDoc = await _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .get();

    Map<String, dynamic> stats = userDoc.get('stats') ?? {};
    
    return {
      'sent': stats['lettersSent'] ?? 0,
      'received': stats['lettersReceived'] ?? 0,
      'responses': stats['letterResponses'] ?? 0,
    };
  }

  // Stream des lettres reçues en temps réel
  static Stream<QuerySnapshot> getLettersStream() {
    if (_auth.currentUser == null) {
      return Stream.empty();
    }

    return _firestore.collection('letters')
      .where('recipientId', isEqualTo: _auth.currentUser!.uid)
      .orderBy('sentAt', descending: true)
      .snapshots();
  }
}
