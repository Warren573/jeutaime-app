// Job CRON composition bar hebdo (exemple)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const weeklyBarComposition = functions.pubsub.schedule('0 1 * * 1').onRun(async (context) => {
  // Créer de nouveaux groupes pour chaque bar actif
  const barsSnap = await admin.firestore().collection('bars').where('isActive', '==', true).get();
  for (const barDoc of barsSnap.docs) {
    const groupRef = admin.firestore().collection('groups').doc();
    await groupRef.set({
      groupId: groupRef.id,
      name: `Groupe ${barDoc.data().name} ${new Date().toLocaleDateString()}`,
      members: [],
      barId: barDoc.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: Date.now() + 7 * 24 * 60 * 60 * 1000,
      isActive: true,
    });
  }
  return true;
});
