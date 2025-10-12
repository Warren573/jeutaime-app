import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../utils/gamification_mixin.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with GamificationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();

  UserProfile? _currentProfile;
  DateTime? _selectedDate;
  List<String> _selectedInterests = [];
  File? _selectedImage;
  List<File> _additionalPhotos = [];
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _availableInterests = [
    'Sport', 'Musique', 'Cinéma', 'Lecture', 'Voyage', 'Cuisine',
    'Art', 'Photographie', 'Danse', 'Gaming', 'Nature', 'Technologie',
    'Mode', 'Fitness', 'Yoga', 'Méditation', 'Animaux', 'Sciences',
    'Histoire', 'Langues', 'Théâtre', 'Jardinage', 'DIY', 'Moto'
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() => _isLoading = true);

    try {
      _currentProfile = AuthService.instance.currentProfile;
      
      if (_currentProfile != null) {
        _nameController.text = _currentProfile!.displayName ?? '';
        _bioController.text = _currentProfile!.bio ?? '';
        _locationController.text = _currentProfile!.location ?? '';
        _phoneController.text = _currentProfile!.phoneNumber ?? '';
        _selectedDate = _currentProfile!.dateOfBirth;
        _selectedInterests = List.from(_currentProfile!.interests);
      }
    } catch (e) {
      _showError('Erreur de chargement du profil');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showError('Erreur lors du choix de l\'image');
    }
  }

  Future<void> _pickAdditionalPhotos() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _additionalPhotos.addAll(
            pickedFiles.map((file) => File(file.path)).take(5 - _additionalPhotos.length),
          );
        });

        HapticFeedback.lightImpact();
        trackPhotoAdded();
      }
    } catch (e) {
      _showError('Erreur lors du choix des images');
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B9D),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? photoUrl;
      List<String> additionalPhotoUrls = [];

      // Upload photo de profil
      if (_selectedImage != null) {
        photoUrl = await AuthService.instance.uploadProfilePhoto(_selectedImage!);
      }

      // Upload photos supplémentaires
      if (_additionalPhotos.isNotEmpty) {
        additionalPhotoUrls = await AuthService.instance.uploadAdditionalPhotos(_additionalPhotos);
      }

      // Créer le profil mis à jour
      final updatedProfile = _currentProfile?.copyWith(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: _selectedDate,
        interests: _selectedInterests,
        photoURL: photoUrl ?? _currentProfile?.photoURL,
        photoUrls: additionalPhotoUrls.isNotEmpty 
            ? additionalPhotoUrls 
            : _currentProfile?.photoUrls ?? [],
        isProfileComplete: _isProfileComplete(),
      );

      if (updatedProfile != null) {
        final result = await AuthService.instance.updateProfile(updatedProfile);
        
        if (result.success) {
          HapticFeedback.heavyImpact();
          
          // Check si profil maintenant complet pour XP
          if (_isProfileComplete() && !(_currentProfile?.isProfileComplete ?? false)) {
            trackProfileCompleted();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );

          Navigator.pop(context);
        } else {
          _showError(result.error ?? 'Erreur de mise à jour');
        }
      }
    } catch (e) {
      _showError('Erreur lors de la sauvegarde');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  bool _isProfileComplete() {
    return _nameController.text.trim().isNotEmpty &&
           _bioController.text.trim().isNotEmpty &&
           _locationController.text.trim().isNotEmpty &&
           _selectedDate != null &&
           _selectedInterests.length >= 3 &&
           (_selectedImage != null || _currentProfile?.photoURL?.isNotEmpty == true);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F23),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B9D)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B9D),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Enregistrer',
                    style: TextStyle(
                      color: Color(0xFFFF6B9D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo de profil
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF6B9D), width: 3),
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : _currentProfile?.photoURL?.isNotEmpty == true
                                ? Image.network(_currentProfile!.photoURL!, fit: BoxFit.cover)
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white54,
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B9D),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Nom
              _buildTextField(
                controller: _nameController,
                label: 'Nom',
                icon: Icons.person,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez saisir votre nom';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Date de naissance
              _buildDateField(),

              const SizedBox(height: 20),

              // Bio
              _buildTextField(
                controller: _bioController,
                label: 'À propos de moi',
                icon: Icons.info,
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Parlez-nous de vous';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Localisation
              _buildTextField(
                controller: _locationController,
                label: 'Localisation',
                icon: Icons.location_on,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez saisir votre ville';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Téléphone (optionnel)
              _buildTextField(
                controller: _phoneController,
                label: 'Téléphone (optionnel)',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 30),

              // Centres d'intérêt
              _buildInterestsSection(),

              const SizedBox(height: 30),

              // Photos supplémentaires
              _buildAdditionalPhotosSection(),

              const SizedBox(height: 30),

              // Indicateur de complétude
              _buildCompletionIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B9D), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date de naissance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Centres d\'intérêt (min. 3)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(interest);
                  } else {
                    _selectedInterests.add(interest);
                  }
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFFFF6B9D) 
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFFFF6B9D) 
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Photos supplémentaires',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _additionalPhotos.length < 5 ? _pickAdditionalPhotos : null,
              icon: const Icon(Icons.add_photo_alternate, color: Color(0xFFFF6B9D)),
              label: const Text(
                'Ajouter',
                style: TextStyle(color: Color(0xFFFF6B9D)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_additionalPhotos.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _additionalPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _additionalPhotos[index],
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _additionalPhotos.removeAt(index);
                            });
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                'Aucune photo supplémentaire',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompletionIndicator() {
    final completionPercentage = _currentProfile?.profileCompletionPercentage ?? 0.0;
    final isComplete = _isProfileComplete();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete 
              ? const Color(0xFF4CAF50) 
              : const Color(0xFFFF6B9D),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.info,
                color: isComplete 
                    ? const Color(0xFF4CAF50) 
                    : const Color(0xFFFF6B9D),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isComplete 
                      ? 'Profil complet ! +100 XP' 
                      : 'Complétez votre profil',
                  style: TextStyle(
                    color: isComplete 
                        ? const Color(0xFF4CAF50) 
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(completionPercentage * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completionPercentage,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete 
                  ? const Color(0xFF4CAF50) 
                  : const Color(0xFFFF6B9D),
            ),
          ),
        ],
      ),
    );
  }
}