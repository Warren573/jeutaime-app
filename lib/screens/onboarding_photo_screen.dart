import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class OnboardingPhotoScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const OnboardingPhotoScreen({
    Key? key,
    required this.profileData,
  }) : super(key: key);

  @override
  State<OnboardingPhotoScreen> createState() => _OnboardingPhotoScreenState();
}

class _OnboardingPhotoScreenState extends State<OnboardingPhotoScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Photo de profil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Étapes
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildProgressIndicator(),
          ),

          // Contenu principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Titre et description
                  const Text(
                    'Ajoutez votre plus beau sourire !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Une photo authentique vous aidera à faire de meilleures rencontres. Elle sera vérifiée par notre équipe pour garantir la sécurité de tous.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Zone de photo
                  Center(
                    child: GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                          border: Border.all(
                            color: _selectedImage != null ? AppColors.primary : Colors.grey[300]!,
                            width: 3,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ajouter une photo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Conseils pour la photo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[600], size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Conseils pour une belle photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPhotoTip('Souriez naturellement', Icons.sentiment_satisfied),
                        _buildPhotoTip('Éclairage naturel (près d\'une fenêtre)', Icons.wb_sunny),
                        _buildPhotoTip('Seul(e) sur la photo', Icons.person),
                        _buildPhotoTip('Visage bien visible', Icons.face),
                        _buildPhotoTip('Photo récente (moins de 6 mois)', Icons.schedule),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Information sur la vérification
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.orange[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vérification des photos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Votre photo sera vérifiée sous 24h pour authentifier votre profil et sécuriser la communauté.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Boutons d'action
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Bouton terminer l'inscription
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedImage != null && !_isLoading ? _completeSignup : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Terminer mon inscription',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _selectedImage != null ? Colors.white : Colors.grey[600],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Bouton passer pour l'instant
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: !_isLoading ? _skipPhotoForNow : null,
                    child: const Text(
                      'Passer pour l\'instant',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepIndicator(1, false, 'Profil'),
        _buildStepConnector(),
        _buildStepIndicator(2, false, 'Intérêts'),
        _buildStepConnector(),
        _buildStepIndicator(3, true, 'Photo'),
      ],
    );
  }

  Widget _buildStepIndicator(int step, bool isActive, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: step <= 2 ? AppColors.primary : (isActive ? AppColors.primary : Colors.grey[300]),
          ),
          child: Center(
            child: step <= 2
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: (step <= 2 || isActive) ? AppColors.primary : Colors.grey[600],
            fontWeight: (step <= 2 || isActive) ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildPhotoTip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir une photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Appareil photo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Galerie',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sélection de l\'image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeSignup() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Créer le compte avec les données collectées
      final result = await AuthService.signUpWithEmail(
        email: widget.profileData['email'],
        password: widget.profileData['password'],
        displayName: widget.profileData['displayName'],
        gender: widget.profileData['gender'],
        dateOfBirth: widget.profileData['dateOfBirth'],
        interests: List<String>.from(widget.profileData['interests']),
        city: widget.profileData['city'],
        bio: widget.profileData['bio'],
        referralCode: widget.profileData['referralCode'],
      );

      if (result != null && result.user != null) {
        // Uploader la photo de certification si sélectionnée
        if (_selectedImage != null) {
          // TODO: Implémenter l'upload d'image vers Firebase Storage
          // await AuthService.uploadCertificationPhoto(result.user!.uid, photoUrl);
        }

        // Naviguer vers l'écran principal
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'inscription : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _skipPhotoForNow() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Créer le compte sans photo
      final result = await AuthService.signUpWithEmail(
        email: widget.profileData['email'],
        password: widget.profileData['password'],
        displayName: widget.profileData['displayName'],
        gender: widget.profileData['gender'],
        dateOfBirth: widget.profileData['dateOfBirth'],
        interests: List<String>.from(widget.profileData['interests']),
        city: widget.profileData['city'],
        bio: widget.profileData['bio'],
        referralCode: widget.profileData['referralCode'],
      );

      if (result != null && result.user != null) {
        // Naviguer vers l'écran principal
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'inscription : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}