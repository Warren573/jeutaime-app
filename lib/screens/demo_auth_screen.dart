import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/coin_service.dart';
import '../widgets/modern_ui_components.dart';
import '../theme/app_themes.dart';

// Service démo qui simule Firebase
class DemoAuthService {
  static String? _currentUserId;
  static Map<String, dynamic>? _currentUser;
  
  static bool get isLoggedIn => _currentUserId != null;
  static String? get currentUserId => _currentUserId;
  static Map<String, dynamic>? get currentUser => _currentUser;
  
  static Future<bool> signInDemo(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simule réseau
    
    _currentUserId = 'demo_user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = {
      'uid': _currentUserId,
      'email': email,
      'displayName': email.split('@')[0],
      'coins': 100,
      'premium': false,
      'createdAt': DateTime.now(),
    };
    
    return true;
  }
  
  static Future<bool> signUpDemo(String email, String password, String displayName) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simule réseau
    
    _currentUserId = 'demo_user_${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = {
      'uid': _currentUserId,
      'email': email,
      'displayName': displayName,
      'coins': 100,
      'premium': false,
      'createdAt': DateTime.now(),
    };
    
    return true;
  }
  
  static Future<bool> signInAnonymousDemo() async {
    await Future.delayed(Duration(milliseconds: 300)); // Simule réseau
    
    _currentUserId = 'demo_anon_${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = {
      'uid': _currentUserId,
      'email': 'anonyme@demo.jeutaime',
      'displayName': 'Utilisateur Anonyme',
      'coins': 50,
      'premium': false,
      'createdAt': DateTime.now(),
    };
    
    return true;
  }
  
  static void signOut() {
    _currentUserId = null;
    _currentUser = null;
  }
}

class DemoAuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  
  const DemoAuthScreen({Key? key, required this.onAuthenticated}) : super(key: key);
  
  @override
  State<DemoAuthScreen> createState() => _DemoAuthScreenState();
}

class _DemoAuthScreenState extends State<DemoAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade100,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo et titre
                  Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.pink.shade600,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'JeuTaime',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade700,
                    ),
                  ),
                  Text(
                    _isLogin ? 'Connexion (Mode Démo)' : 'Inscription (Mode Démo)',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info, size: 16, color: Colors.blue.shade600),
                        SizedBox(width: 4),
                        Text(
                          'Version démo - Aucune donnée sauvegardée',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Formulaire
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nom d\'affichage',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email (ex: demo@test.com)',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe (ex: demo123)',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        
                        if (_errorMessage != null) ...[
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red.shade600, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        SizedBox(height: 24),
                        
                        // Bouton principal
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    _isLogin ? 'Se connecter (Démo)' : 'S\'inscrire (Démo)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Connexion anonyme
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleAnonymousAuth,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.visibility_off, size: 20),
                                SizedBox(width: 8),
                                Text('Connexion anonyme (Démo)'),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Toggle login/register
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _errorMessage = null;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Pas encore de compte ? S\'inscrire'
                                : 'Déjà un compte ? Se connecter',
                            style: TextStyle(color: Colors.pink.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _handleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Veuillez remplir tous les champs');
      }
      
      if (!_isLogin && _nameController.text.trim().isEmpty) {
        throw Exception('Veuillez entrer un nom d\'affichage');
      }
      
      bool success = false;
      
      if (_isLogin) {
        success = await DemoAuthService.signInDemo(email, password);
      } else {
        success = await DemoAuthService.signUpDemo(email, password, _nameController.text.trim());
      }
      
      if (!success) {
        throw Exception('Erreur de connexion');
      }
      
      widget.onAuthenticated();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _handleAnonymousAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await DemoAuthService.signInAnonymousDemo();
      
      if (!success) {
        throw Exception('Erreur de connexion anonyme');
      }
      
      widget.onAuthenticated();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}