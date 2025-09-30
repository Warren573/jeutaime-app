import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Trigger : quand un achat est complété
export const onPurchaseCompleted = functions.firestore.document('purchases/{purchaseId}').onUpdate((change, context) => {
  // TODO: créditer coins/premium
  return null;
});
