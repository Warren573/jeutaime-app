import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const cleanupTempFiles = functions.pubsub.schedule('0 2 * * *').onRun(async (context) => {
  // TODO: Suppression des fichiers temporaires dans Storage
  // À compléter selon l’API Storage utilisée
  return true;
});
