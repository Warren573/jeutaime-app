import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CallableContext } from 'firebase-functions/v1/https';

// Vérifier si l'utilisateur est admin
export const isAdmin = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const adminDoc = await admin.firestore().collection('admins').doc(context.auth.uid).get();
  return { isAdmin: adminDoc.exists };
});

// Lister tous les rapports non traités
export const listOpenReports = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const adminDoc = await admin.firestore().collection('admins').doc(context.auth.uid).get();
  if (!adminDoc.exists) {
    throw new functions.https.HttpsError('permission-denied', 'Accès réservé aux admins');
  }
  const reportsSnap = await admin.firestore().collection('reports').where('status', '==', 'open').get();
  const reports = reportsSnap.docs.map(doc => doc.data());
  return { reports };
});

// Fermer un rapport
export const closeReport = functions.https.onCall(async (data: any, context: CallableContext) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'Utilisateur non authentifié');
  }
  const adminDoc = await admin.firestore().collection('admins').doc(context.auth.uid).get();
  if (!adminDoc.exists) {
    throw new functions.https.HttpsError('permission-denied', 'Accès réservé aux admins');
  }
  const { reportId, adminComment } = data;
  if (!reportId) {
    throw new functions.https.HttpsError('invalid-argument', 'reportId requis');
  }
  await admin.firestore().collection('reports').doc(reportId).update({
    status: 'closed',
    adminComment: adminComment || '',
  });
  return { success: true };
});
