// Trigger Firestore sur création de report (exemple)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onReportCreated = functions.firestore.document('reports/{reportId}')
  .onCreate(async (snap: FirebaseFirestore.DocumentSnapshot, context: functions.EventContext) => {
    const report = snap.data();
    if (!report) return null;
    // Notifier l’admin (notification Firestore)
    const adminQuery = await admin.firestore().collection('admins').get();
    for (const adminDoc of adminQuery.docs) {
      await admin.firestore().collection('notifications').add({
        uid: adminDoc.id,
        type: 'report',
        data: { message: 'Nouveau signalement', reportId: report.reportId },
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    // Marquer le contenu (exemple : flag sur user/bar/letter)
    if (report.type === 'user') {
      await admin.firestore().collection('users').doc(report.targetId).update({ flagged: true });
    } else if (report.type === 'bar') {
      await admin.firestore().collection('bars').doc(report.targetId).update({ flagged: true });
    } else if (report.type === 'letter') {
      await admin.firestore().collection('letterMessages').doc(report.targetId).update({ flagged: true });
    }
    return null;
  });
