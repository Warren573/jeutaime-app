// Job CRON bonus quotidien (exemple)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const dailyBonus = functions.pubsub.schedule('0 0 * * *').onRun(async (context) => {
  // Distribuer un bonus de coins à tous les utilisateurs actifs
  const usersSnap = await admin.firestore().collection('users').where('lastActive', '>=', Date.now() - 7 * 24 * 60 * 60 * 1000).get();
  for (const userDoc of usersSnap.docs) {
    await userDoc.ref.update({
      coins: admin.firestore.FieldValue.increment(5),
    });
    await admin.firestore().collection('notifications').add({
      uid: userDoc.id,
      type: 'bonus',
      data: { message: 'Bonus quotidien reçu !' },
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  return true;
});
