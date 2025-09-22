import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LetterService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ... Tes autres méthodes LetterService (envoi, réponse, etc.) ...

  // Obtenir les lettres reçues
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
  }

  // Archiver une lettre pour l'utilisateur courant
  static Future<void> archiveLetterForUser(String letterId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('letters').doc(letterId).get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    await _firestore.collection('memory_box').add({
      'userId': user.uid,
      'type': data['senderId'] == user.uid ? 'letter_sent' : 'letter_received',
      'title': 'Lettre: ${data['subject']}',
      'description': data['isAnonymous'] ?? false
          ? 'Lettre anonyme depuis JeuTaime'
          : 'Lettre de ${data['senderId'] == user.uid ? "vous" : data['senderName'] ?? "un utilisateur"}',
      'data': {
        'letterId': letterId,
        'subject': data['subject'],
        'content': data['content'],
        'isAnonymous': data['isAnonymous'] ?? false,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'barContext': data['barContext'] ?? '',
    });
  }
}
