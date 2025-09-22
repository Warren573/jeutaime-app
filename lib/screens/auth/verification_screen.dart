import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_colors.dart';

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  File? _selfieImage;
  File? _idImage;
  final ImagePicker _picker = ImagePicker();
  bool _isVerifying = false;
  int _currentStep = 0;

  final List<String> _steps = [
    'Photo de profil',
    'Selfie de vérification',
    'Pièce d\'identité',
    'Validation'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Text('Certification JeuTaime'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de progression
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (index) {
                    bool isActive = index <= _currentStep;
                    bool isCompleted = index < _currentStep;
                    
                    return Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted 
                                ? Colors.green 
                                : isActive 
                                    ? AppColors.romanticBar 
                                    : Colors.grey.shade300,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : Icons.circle,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        if (index < _steps.length - 1)
                          Container(
                            width: 40,
                            height: 2,
                            color: index < _currentStep 
                                ? Colors.green 
                                : Colors.grey.shade300,
                          ),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 12),
                Text(
                  _steps[_currentStep],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.seriousAccent,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: _buildCurrentStep(),
            ),
          ),
          
          // Boutons de navigation
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: Text('Précédent'),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    child: Text(
                      _currentStep == _steps.length - 1 
                          ? 'Terminer' 
                          : 'Suivant',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.romanticBar,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildProfilePhotoStep();
      case 1:
        return _buildSelfieStep();
      case 2:
        return _buildIdStep();
      case 3:
        return _buildValidationStep();
      default:
        return Container();
    }
  }

  Widget _buildProfilePhotoStep() {
    return Column(
      children: [
        Icon(
          Icons.account_circle,
          size: 100,
          color: AppColors.romanticBar,
        ),
        SizedBox(height: 20),
        Text(
          'Photo de Profil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Choisissez une photo claire de votre visage. Cette photo sera votre image principale sur JeuTaime.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        SizedBox(height: 30),
        _buildPhotoUploadCard(
          'Photo de profil',
          _selfieImage,
          () => _pickImage(ImageSource.gallery, true),
        ),
      ],
    );
  }

  Widget _buildSelfieStep() {
    return Column(
      children: [
        Icon(
          Icons.camera_alt,
          size: 100,
          color: Colors.blue,
        ),
        SizedBox(height: 20),
        Text(
          'Selfie de Vérification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(height: 8),
              Text(
                'Instructions importantes :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Regardez directement la caméra\n'
                '• Assurez-vous que votre visage soit bien éclairé\n'
                '• Ne portez pas de lunettes de soleil\n'
                '• Tenez une feuille avec "JeuTaime" écrit dessus',
                style: TextStyle(color: Colors.blue.shade700),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        _buildPhotoUploadCard(
          'Selfie de vérification',
          _selfieImage,
          () => _pickImage(ImageSource.camera, true),
        ),
      ],
    );
  }

  Widget _buildIdStep() {
    return Column(
      children: [
        Icon(
          Icons.badge,
          size: 100,
          color: Colors.orange,
        ),
        SizedBox(height: 20),
        Text(
          'Pièce d\'Identité',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.security, color: Colors.green),
              SizedBox(height: 8),
              Text(
                '🔒 Vos données sont sécurisées',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Nous utilisons votre pièce d\'identité uniquement pour vérifier votre âge et votre authenticité. Elle sera supprimée après validation.',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        _buildPhotoUploadCard(
          'Carte d\'identité ou passeport',
          _idImage,
          () => _pickImage(ImageSource.camera, false),
        ),
      ],
    );
  }

  Widget _buildValidationStep() {
    return Column(
      children: [
        if (_isVerifying) ...[
          CircularProgressIndicator(color: AppColors.romanticBar),
          SizedBox(height: 20),
          Text('Vérification en cours...'),
        ] else ...[
          Icon(
            Icons.verified_user,
            size: 100,
            color: Colors.green,
          ),
          SizedBox(height: 20),
          Text(
            'Vérification Terminée !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                SizedBox(height: 16),
                Text(
                  'Félicitations !',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Votre profil est maintenant certifié JeuTaime. Vous bénéficiez d\'une meilleure visibilité et de la confiance des autres membres.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoUploadCard(String title, File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null ? Colors.green : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: image != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Ajouter $title',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Touchez pour prendre une photo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, bool isSelfie) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        if (isSelfie) {
          _selfieImage = File(image.path);
        } else {
          _idImage = File(image.path);
        }
      });
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
      case 1:
        return _selfieImage != null;
      case 2:
        return _idImage != null;
      case 3:
        return !_isVerifying;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      if (_currentStep == 3) {
        _startVerification();
      }
    } else {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  void _startVerification() {
    setState(() => _isVerifying = true);
    
    // Simulation de la vérification
    Future.delayed(Duration(seconds: 3), () {
      setState(() => _isVerifying = false);
    });
  }
}
