// Fonction callable d’authentification (exemple)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableContext } from 'firebase-functions/v1/https';

// Créer le profil utilisateur
export const createUserProfile = functions.https.onCall(async (data: any, context: CallableContext) => {
  // Validation basique
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const { pseudo, email, birthdate, gender } = data;
  if (!pseudo || !email || !birthdate || !gender) {
    throw new functions.https.HttpsError('invalid-argument', 'Champs obligatoires manquants');
  }
  const userRef = admin.firestore().collection('users').doc(context.auth.uid);
  const userData = {
    uid: context.auth.uid,
    pseudo,
    email,
    birthdate,
    gender,
    certified: false,
    coins: 0,
    premium: false,
    badges: [],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastActive: admin.firestore.FieldValue.serverTimestamp(),
    settings: {},
  };
  try {
    await userRef.set(userData, { merge: false });
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de la création du profil', error);
  }
});

// Mettre à jour le profil utilisateur
export const updateUserProfile = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const allowedFields = ['pseudo', 'photoUrl', 'bio', 'gender', 'birthdate', 'settings'];
  const updates: any = {};
  for (const key of allowedFields) {
    if (data[key] !== undefined) {
      updates[key] = data[key];
    }
  }
  if (Object.keys(updates).length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Aucune donnée à mettre à jour');
  }
  updates.lastActive = admin.firestore.FieldValue.serverTimestamp();
  try {
    await admin.firestore().collection('users').doc(context.auth.uid).update(updates);
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de la mise à jour du profil', error);
  }
});

// Certifier un utilisateur
export const certifyUser = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  // Vérification basique des documents (à adapter selon le flux réel)
  const { documents } = data;
  if (!documents || !Array.isArray(documents) || documents.length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Documents de certification requis');
  }
  // Ici, on pourrait vérifier l’URL, le format, etc.
  try {
    await admin.firestore().collection('users').doc(context.auth.uid).update({
      certified: true,
      certificationDocs: documents,
      badges: admin.firestore.FieldValue.arrayUnion('certified'),
      lastActive: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Erreur lors de la certification', error);
  }
});
