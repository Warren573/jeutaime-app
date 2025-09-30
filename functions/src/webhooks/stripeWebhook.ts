// Webhook Stripe (exemple)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import { Request, Response } from 'express';

export const stripeWebhook = functions.https.onRequest(async (req: Request, res: Response) => {
  // Vérification de la signature Stripe (à compléter avec la clé secrète Stripe)
  // const sig = req.headers['stripe-signature'];
  // const event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);

  const event = req.body; // Pour test local, sans vérification
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    // Récupérer l’achat lié à la session
    const purchaseSnap = await admin.firestore().collection('purchases').where('stripeSessionId', '==', session.id).get();
    if (!purchaseSnap.empty) {
      const purchaseDoc = purchaseSnap.docs[0];
      await purchaseDoc.ref.update({ status: 'completed' });
    }
  } else if (event.type === 'checkout.session.expired') {
    const session = event.data.object;
    const purchaseSnap = await admin.firestore().collection('purchases').where('stripeSessionId', '==', session.id).get();
    if (!purchaseSnap.empty) {
      const purchaseDoc = purchaseSnap.docs[0];
      await purchaseDoc.ref.update({ status: 'failed' });
    }
  }
  res.json({ received: true });
});
