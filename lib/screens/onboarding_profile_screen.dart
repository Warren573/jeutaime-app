import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'onboarding_interests_screen.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _referralController = TextEditingController();

  String _selectedGender = 'woman';
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _acceptTerms = false;

  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'woman', 'label': 'Femme', 'icon': Icons.female},
    {'value': 'man', 'label': 'Homme', 'icon': Icons.male},
    {'value': 'non-binary', 'label': 'Non-binaire', 'icon': Icons.transgender},
    {'value': 'other', 'label': 'Autre', 'icon': Icons.more_horiz},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _referralController.dispose();
    super.dispose();
  }

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
          'Créer mon profil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Étapes
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // Titre
              const Text(
                'Parlez-nous de vous',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ces informations nous aideront à vous proposer des rencontres plus pertinentes.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Prénom
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  label: 'Prénom',
                  icon: Icons.person,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre prénom';
                  }
                  if (value.length < 2) {
                    return 'Le prénom doit faire au moins 2 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration(
                  label: 'Email',
                  icon: Icons.email,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _buildInputDecoration(
                  label: 'Mot de passe',
                  icon: Icons.lock,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit faire au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirmer mot de passe
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _buildInputDecoration(
                  label: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline,
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Genre
              const Text(
                'Je suis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildGenderSelector(),
              const SizedBox(height: 24),

              // Date de naissance
              const Text(
                'Date de naissance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 24),

              // Ville (optionnel)
              TextFormField(
                controller: _cityController,
                decoration: _buildInputDecoration(
                  label: 'Ville (optionnel)',
                  icon: Icons.location_on,
                ),
              ),
              const SizedBox(height: 16),

              // Bio (optionnel)
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 200,
                decoration: _buildInputDecoration(
                  label: 'Petite présentation (optionnel)',
                  icon: Icons.edit,
                ),
              ),
              const SizedBox(height: 24),

              // Code de parrainage (optionnel)
              TextFormField(
                controller: _referralController,
                decoration: _buildInputDecoration(
                  label: 'Code de parrainage (optionnel)',
                  icon: Icons.card_giftcard,
                ),
              ),
              const SizedBox(height: 24),

              // Conditions d'utilisation
              CheckboxListTile(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
                title: const Text(
                  'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                  style: TextStyle(fontSize: 14),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 32),

              // Bouton continuer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _acceptTerms && !_isLoading ? _continueToInterests : null,
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
                      : const Text(
                          'Continuer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepIndicator(1, true, 'Profil'),
        _buildStepConnector(),
        _buildStepIndicator(2, false, 'Intérêts'),
        _buildStepConnector(),
        _buildStepIndicator(3, false, 'Photo'),
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
            color: isActive ? AppColors.primary : Colors.grey[300],
          ),
          child: Center(
            child: Text(
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
            color: isActive ? AppColors.primary : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildGenderSelector() {
    return Row(
      children: _genderOptions.map((option) {
        final isSelected = _selectedGender == option['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedGender = option['value'];
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    option['icon'],
                    color: isSelected ? AppColors.primary : Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option['label'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppColors.primary : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Sélectionnez votre date de naissance',
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _continueToInterests() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier que l'utilisateur a au moins 18 ans
    final age = DateTime.now().difference(_selectedDate!).inDays ~/ 365;
    if (age < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez avoir au moins 18 ans pour utiliser JeuTaime'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Passer à l'étape suivante avec les données du profil
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingInterestsScreen(
          profileData: {
            'displayName': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
            'gender': _selectedGender,
            'dateOfBirth': _selectedDate!,
            'city': _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
            'bio': _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
            'referralCode': _referralController.text.trim().isNotEmpty ? _referralController.text.trim() : null,
          },
        ),
      ),
    );
  }
}