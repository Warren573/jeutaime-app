import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../utils/gamification_mixin.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with GamificationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFunMode = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFunMode ? AppColors.funBackground : AppColors.seriousBackground,
      appBar: AppBar(
        title: Text('Créer un compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Titre de bienvenue
                Text(
                  'Bienvenue dans JeuTaime !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
                    fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 8),
                
                Text(
                  'Créez votre profil et commencez votre aventure amoureuse',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 30),
                
                // Bouton mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Mode: ', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    GestureDetector(
                      onTap: () => setState(() => _isFunMode = !_isFunMode),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isFunMode ? '😄 Fun' : '💼 Sérieux',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 30),
                
                // Champ nom
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_isFunMode ? 20 : 12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value?.isEmpty == true ? 'Veuillez entrer votre nom' : null,
                ),
                
                SizedBox(height: 20),
                
                // Champ âge
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Âge',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_isFunMode ? 20 : 12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Veuillez entrer votre âge';
                    int? age = int.tryParse(value!);
                    if (age == null || age < 18 || age > 100) return 'Âge invalide (18-100 ans)';
                    return null;
                  },
                ),
                
                SizedBox(height: 20),
                
                // Champ email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_isFunMode ? 20 : 12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Veuillez entrer votre email';
                    if (!value!.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                
                SizedBox(height: 20),
                
                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_isFunMode ? 20 : 12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Veuillez entrer un mot de passe';
                    if (value!.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),
                
                SizedBox(height: 20),
                
                // Confirmation mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_isFunMode ? 20 : 12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),
                
                SizedBox(height: 20),
                
                // Acceptation des conditions
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) => setState(() => _acceptTerms = value!),
                      activeColor: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                        child: Text(
                          'J\'accepte les conditions d\'utilisation et la politique de confidentialité de JeuTaime',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 30),
                
                // Bouton inscription
                ElevatedButton(
                  onPressed: _isLoading || !_acceptTerms ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_isFunMode ? 25 : 12)),
                  ),
                  child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Créer mon compte',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
                
                SizedBox(height: 20),
                
                // Lien retour connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Déjà un compte ? ', style: TextStyle(color: Colors.grey[600])),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Se connecter',
                        style: TextStyle(
                          color: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
      );
      
      // Tracking gamification pour inscription
      trackLogin(); // XP pour première connexion
      
      // Feedback haptique de succès
      HapticFeedback.heavyImpact();
      
      // Afficher message de bienvenue avec gamification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Bienvenue dans JeuTaime ! +100 coins + 10 XP de bienvenue !'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Attendre un peu pour que l'utilisateur voie le message
      await Future.delayed(Duration(seconds: 1));
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      // Feedback haptique d'erreur
      HapticFeedback.lightImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'inscription: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
