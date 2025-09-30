import { referFriend, validateReferralCode } from '../functions/src/callables/referrals';

describe('Referrals', () => {
  const context = { auth: { uid: 'userUid' } };

  it('should fail if email is missing', async () => {
    await expect(referFriend({}, context as any)).rejects.toThrow();
  });

  it('should fail if code is missing', async () => {
    await expect(validateReferralCode({}, context as any)).rejects.toThrow();
  });

  // Ajoute d'autres cas de test selon la logique métier
});
