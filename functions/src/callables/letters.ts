// Fonction callable pour gestion des lettres (exemple)
import * as functions from 'firebase-functions';

import { CallableContext } from 'firebase-functions/v1/https';
import * as admin from 'firebase-admin';

// Envoyer une lettre
export const sendLetter = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { threadId, content, attachments } = data;
  if (!threadId || !content) {
    throw new functions.https.HttpsError('invalid-argument', 'Thread et contenu requis');
  }
  const messageRef = admin.firestore().collection('letterMessages').doc();
  const messageData = {
    messageId: messageRef.id,
    threadId,
    authorUid: context.auth.uid,
    content,
    attachments: attachments || [],
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
  };
  try {
    await messageRef.set(messageData);
    await admin.firestore().collection('letterThreads').doc(threadId).update({
      lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // TODO: notification destinataire
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de l’envoi de la lettre', error);
  }
});

// Créer un thread de lettres
export const createLetterThread = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { participants } = data;
  if (!participants || !Array.isArray(participants) || participants.length !== 2) {
    throw new functions.https.HttpsError('invalid-argument', 'Deux participants requis');
  }
  if (!participants.includes(context.auth.uid)) {
    throw new functions.https.HttpsError('permission-denied', 'L’utilisateur doit être participant');
  }
  const threadRef = admin.firestore().collection('letterThreads').doc();
  const threadData = {
    threadId: threadRef.id,
    participants,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastMessageAt: null,
  };
  try {
    await threadRef.set(threadData);
    return { success: true, threadId: threadRef.id };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de la création du thread', error);
  }
});
