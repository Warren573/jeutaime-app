// Fonction callable pour gestion des bars (exemple)
import * as functions from 'firebase-functions';

import { CallableContext } from 'firebase-functions/v1/https';

export const joinBar = functions.https.onCall(async (data: any, context: CallableContext) => {
  // Logique pour rejoindre un bar
  return { success: true };
});
