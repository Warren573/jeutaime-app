import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Logger une action utilisateur
export const logUserAction = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { action, details } = data;
  if (!action) {
    throw new functions.https.HttpsError('invalid-argument', 'Action requise');
  }
  await admin.firestore().collection('logs').add({
    uid: context.auth.uid,
    action,
    details: details || {},
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { success: true };
});

// Récupérer des statistiques simples
export const getUserStats = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  // Exemple : nombre de lettres envoyées
  const messagesSnap = await admin.firestore().collection('letterMessages').where('authorUid', '==', context.auth.uid).get();
  const lettersSent = messagesSnap.size;
  // Exemple : nombre de groupes rejoints
  const groupsSnap = await admin.firestore().collection('groups').where('members', 'array-contains', context.auth.uid).get();
  const groupsJoined = groupsSnap.size;
  return { lettersSent, groupsJoined };
});
