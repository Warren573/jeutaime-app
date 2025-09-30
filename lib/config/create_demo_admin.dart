import '../services/firebase_service.dart';

Future<void> main() async {
  await FirebaseService.initialize();
  const userId = 'admin_demo_001';
  const email = 'admin@demo.com';
  const displayName = 'Admin Démo';
  final result = await FirebaseService.instance.createAdminAccount(
    userId: userId,
    email: email,
    displayName: displayName,
    coins: 10000,
  );
  if (result) {
    print('Compte admin de démo créé avec succès !');
  } else {
    print('Échec de la création du compte admin.');
  }
}
