// Fonction callable pour gestion des paiements (exemple)
import * as functions from 'firebase-functions';

import { CallableContext } from 'firebase-functions/v1/https';
import * as admin from 'firebase-admin';

// Acheter des coins
export const purchaseCoins = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { amount } = data;
  if (!amount || typeof amount !== 'number' || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Montant invalide');
  }
  // Simulation création session Stripe (à remplacer par l’intégration réelle)
  const stripeSessionId = 'simu_' + Math.random().toString(36).substring(2, 15);
  const purchaseRef = admin.firestore().collection('purchases').doc();
  const purchaseData = {
    purchaseId: purchaseRef.id,
    uid: context.auth.uid,
    type: 'coins',
    amount,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    stripeSessionId,
  };
  try {
    await purchaseRef.set(purchaseData);
    // TODO: lancer la vraie session Stripe et retourner l’URL
    return { success: true, purchaseId: purchaseRef.id, stripeSessionId };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de la création de l’achat', error);
  }
});

// Acheter premium
export const purchasePremium = functions.https.onCall(async (data: any, context: CallableContext) => {
  // TODO: validation, création session Stripe, mise à jour Firestore
  return { success: true };
});

// Créer une session de paiement (existant)
export const createPaymentSession = functions.https.onCall(async (data: any, context: CallableContext) => {
  // Logique pour créer une session Stripe
  return { success: true };
});
