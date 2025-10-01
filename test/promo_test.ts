j'ai relancé j'aatendimport { redeemPromoCode } from '../functions/src/callables/promo';

describe('Promo Code', () => {
  const context = { auth: { uid: 'userUid' } };

  it('should fail if code is missing', async () => {
    await expect(redeemPromoCode({}, context as any)).rejects.toThrow();
  });

  // Ajoute d'autres cas de test selon la logique métier
});
