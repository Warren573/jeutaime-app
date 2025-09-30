import { logUserAction, getUserStats } from '../functions/src/services/analytics';

describe('Analytics', () => {
  const context = { auth: { uid: 'userUid' } };

  it('should fail if action is missing', async () => {
    await expect(logUserAction({}, context as any)).rejects.toThrow();
  });

  // Ajoute d'autres cas de test selon la logique métier
});
