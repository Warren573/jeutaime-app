// Trigger Firestore sur envoi de lettre (exemple)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onLetterSent = functions.firestore.document('letterMessages/{messageId}')
  .onCreate(async (snap: FirebaseFirestore.DocumentSnapshot, context: functions.EventContext) => {
    const message = snap.data();
    if (!message) return null;
    // Notifier le destinataire
    const threadSnap = await admin.firestore().collection('letterThreads').doc(message.threadId).get();
    const thread = threadSnap.data();
    if (thread && Array.isArray(thread.participants)) {
      const recipients = thread.participants.filter((uid: string) => uid !== message.authorUid);
      for (const uid of recipients) {
        await admin.firestore().collection('notifications').add({
          uid,
          type: 'letter',
          data: { message: 'Nouvelle lettre reçue', threadId: message.threadId },
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }
    // Mettre à jour le thread (lastMessageAt déjà géré côté sendLetter)
    return null;
  });
