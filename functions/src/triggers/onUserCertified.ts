// Trigger Firestore sur certification utilisateur (exemple)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onUserCertified = functions.firestore.document('users/{uid}')
  .onUpdate(async (change: functions.Change<FirebaseFirestore.DocumentSnapshot>, context: functions.EventContext) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return null;
    // Si l'utilisateur vient d'être certifié
    if (!before.certified && after.certified) {
      // Attribuer le badge (déjà fait côté update, mais on peut logguer)
      await admin.firestore().collection('users').doc(context.params.uid).update({
        badges: admin.firestore.FieldValue.arrayUnion('certified'),
      });
      // Créer une notification Firestore
      await admin.firestore().collection('notifications').add({
        uid: context.params.uid,
        type: 'certification',
        data: { message: 'Félicitations, vous êtes certifié !' },
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    return null;
  });
