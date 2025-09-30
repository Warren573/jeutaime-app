import * as admin from 'firebase-admin';
import { isAdmin, listOpenReports, closeReport } from '../functions/src/callables/admin';

describe('Admin Callables', () => {
  const contextAdmin = { auth: { uid: 'adminUid' } };
  const contextUser = { auth: { uid: 'userUid' } };

  it('should return isAdmin true for admin', async () => {
    // Simule un admin existant
    admin.firestore().collection('admins').doc('adminUid').set({ role: 'superadmin' });
    const result = await isAdmin({}, contextAdmin as any);
    expect(result.isAdmin).toBe(true);
  });

  it('should return isAdmin false for non-admin', async () => {
    const result = await isAdmin({}, contextUser as any);
    expect(result.isAdmin).toBe(false);
  });

  it('should list open reports for admin', async () => {
    admin.firestore().collection('admins').doc('adminUid').set({ role: 'superadmin' });
    admin.firestore().collection('reports').doc('r1').set({ status: 'open' });
    const result = await listOpenReports({}, contextAdmin as any);
    expect(Array.isArray(result.reports)).toBe(true);
    expect(result.reports.length).toBeGreaterThanOrEqual(1);
  });

  it('should not list reports for non-admin', async () => {
    await expect(listOpenReports({}, contextUser as any)).rejects.toThrow();
  });

  it('should close a report for admin', async () => {
    admin.firestore().collection('admins').doc('adminUid').set({ role: 'superadmin' });
    admin.firestore().collection('reports').doc('r2').set({ status: 'open' });
    const result = await closeReport({ reportId: 'r2', adminComment: 'Fermé' }, contextAdmin as any);
    expect(result.success).toBe(true);
    const report = await admin.firestore().collection('reports').doc('r2').get();
    expect(report.data()?.status).toBe('closed');
    expect(report.data()?.adminComment).toBe('Fermé');
  });
});
