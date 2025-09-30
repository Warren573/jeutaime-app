import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableContext } from 'firebase-functions/v1/https';

// Utiliser un code promo
export const redeemPromoCode = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { code } = data;
  if (!code) {
    throw new functions.https.HttpsError('invalid-argument', 'Code promo requis');
  }
  const promoSnap = await admin.firestore().collection('promoCodes').doc(code).get();
  if (!promoSnap.exists || promoSnap.data()?.used) {
    throw new functions.https.HttpsError('not-found', 'Code promo invalide ou déjà utilisé');
  }
  // Appliquer le bonus (exemple : 20 coins)
  await admin.firestore().collection('users').doc(context.auth.uid).update({
    coins: admin.firestore.FieldValue.increment(20),
  });
  await promoSnap.ref.update({ used: true, usedBy: context.auth.uid, usedAt: admin.firestore.FieldValue.serverTimestamp() });
  return { success: true };
});
