import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Rejoindre un groupe/bar
export const joinBarGroup = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { barId } = data;
  if (!barId) {
    throw new functions.https.HttpsError('invalid-argument', 'barId requis');
  }
  const groupQuery = await admin.firestore().collection('groups').where('barId', '==', barId).where('isActive', '==', true).get();
  if (groupQuery.empty) {
    throw new functions.https.HttpsError('not-found', 'Aucun groupe actif pour ce bar');
  }
  const groupDoc = groupQuery.docs[0];
  try {
    await groupDoc.ref.update({
      members: admin.firestore.FieldValue.arrayUnion(context.auth.uid),
    });
    return { success: true, groupId: groupDoc.id };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de la jonction du groupe', error);
  }
});

// Quitter un groupe/bar
export const leaveBarGroup = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { barId } = data;
  if (!barId) {
    throw new functions.https.HttpsError('invalid-argument', 'barId requis');
  }
  const groupQuery = await admin.firestore().collection('groups').where('barId', '==', barId).where('isActive', '==', true).get();
  if (groupQuery.empty) {
    throw new functions.https.HttpsError('not-found', 'Aucun groupe actif pour ce bar');
  }
  const groupDoc = groupQuery.docs[0];
  try {
    await groupDoc.ref.update({
      members: admin.firestore.FieldValue.arrayRemove(context.auth.uid),
    });
    return { success: true, groupId: groupDoc.id };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de la sortie du groupe', error);
  }
});
