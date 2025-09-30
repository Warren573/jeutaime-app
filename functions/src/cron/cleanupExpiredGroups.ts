// Job CRON nettoyage groupes expirés (exemple)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const cleanupExpiredGroups = functions.pubsub.schedule('0 1 * * *').onRun(async (context) => {
  // Supprimer les groupes expirés
  const now = Date.now();
  const groupsSnap = await admin.firestore().collection('groups').where('expiresAt', '<=', now).get();
  for (const groupDoc of groupsSnap.docs) {
    await groupDoc.ref.delete();
  }
  return true;
});
