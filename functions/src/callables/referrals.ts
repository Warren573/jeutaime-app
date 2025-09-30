// Fonction callable pour gestion du parrainage (exemple)
import * as functions from 'firebase-functions';

import { CallableContext } from 'firebase-functions/v1/https';
import * as admin from 'firebase-admin';


// Parrainer un ami
export const referFriend = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { referredEmail } = data;
  if (!referredEmail) {
    throw new functions.https.HttpsError('invalid-argument', 'Email du filleul requis');
  }
  // Générer un code de parrainage unique
  const code = Math.random().toString(36).substring(2, 8).toUpperCase();
  const referralRef = admin.firestore().collection('referrals').doc();
  await referralRef.set({
    referralId: referralRef.id,
    referrerUid: context.auth.uid,
    referredEmail,
    code,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    bonusGiven: false,
  });
  // TODO: Envoyer un email d’invitation (à compléter)
  return { success: true, code };
});

// Valider le code de parrainage
export const validateReferralCode = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { code } = data;
  if (!code) {
    throw new functions.https.HttpsError('invalid-argument', 'Code de parrainage requis');
  }
  const referralSnap = await admin.firestore().collection('referrals').where('code', '==', code).get();
  if (referralSnap.empty) {
    throw new functions.https.HttpsError('not-found', 'Code de parrainage invalide');
  }
  const referralDoc = referralSnap.docs[0];
  if (referralDoc.data().bonusGiven) {
    throw new functions.https.HttpsError('already-exists', 'Bonus déjà attribué');
  }
  // Attribuer le bonus au filleul et au parrain
  await admin.firestore().collection('users').doc(context.auth.uid).update({ coins: admin.firestore.FieldValue.increment(10) });
  await admin.firestore().collection('users').doc(referralDoc.data().referrerUid).update({ coins: admin.firestore.FieldValue.increment(10) });
  await referralDoc.ref.update({ bonusGiven: true });
  return { success: true };
});
