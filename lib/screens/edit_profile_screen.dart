import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController(text: '75001');
  final TextEditingController _cityController = TextEditingController(text: 'Paris');
  
  String _selectedGender = '';
  String _selectedInterestedIn = '';
  String _selectedLookingFor = '';
  String _selectedChildren = '';
  String _selectedMorphology = '';
  
  int _bioLength = 0;
  
  // Questions brise-glace
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Quelle est ma passion principale ?',
      'answers': ['Voyage', 'Musique', 'Lecture'],
      'correctIndex': 0,
    },
    {
      'question': 'Quel est mon type de cuisine préféré ?',
      'answers': ['Italienne', 'Japonaise', 'Française'],
      'correctIndex': 1,
    },
    {
      'question': 'Quelle activité me détend le plus ?',
      'answers': ['Yoga', 'Peinture', 'Jardinage'],
      'correctIndex': 0,
    },
  ];

  final List<String> _morphologyOptions = [
    'Filiforme (comme un spaghetti)',
    'Ras motte (petite taille)',
    'Grande gigue (très grand·e)',
    'Grande beauté intérieure (ce qui compte vraiment)',
    'Athlétique (toujours en mouvement)',
    'En formes généreuses (que de courbes !)',
    'Moyenne (le juste milieu parfait)',
    'Musclé·e (ça se voit sous le t-shirt)',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    _bioController.addListener(() {
      setState(() {
        _bioLength = _bioController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bioController.dispose();
    _zipcodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_bioLength < 50) {
      _showError('Votre bio doit contenir au moins 50 caractères.');
      return;
    }
    
    if (_selectedGender.isEmpty || _selectedInterestedIn.isEmpty) {
      _showError('Veuillez remplir tous les champs obligatoires.');
      return;
    }

    _showSuccess('💾 Profil sauvegardé avec succès !');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('⚙️ Modifier mon profil', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Système anti-superficiel : votre personnalité avant votre apparence',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),
              
              _buildOfferingsSection(),
              const SizedBox(height: 25),
              _buildPhotosSection(),
              const SizedBox(height: 25),
              _buildBioSection(),
              const SizedBox(height: 25),
              _buildPersonalInfoSection(),
              const SizedBox(height: 25),
              _buildPreferencesSection(),
              const SizedBox(height: 25),
              _buildMorphologySection(),
              const SizedBox(height: 25),
              _buildQuestionsSection(),
              const SizedBox(height: 30),
              
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferingsSection() {
    return _buildCard(
      title: '🎁 Bureau d\'offrandes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Les cadeaux et offrandes que vous avez reçus. Les offrandes éphémères disparaissent après 7 jours.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(40),
            child: const Column(
              children: [
                Text('🎁', style: TextStyle(fontSize: 64, color: Colors.grey)),
                SizedBox(height: 15),
                Text(
                  'Vous n\'avez pas encore reçu d\'offrandes',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return _buildCard(
      title: '📸 Photos de profil (jusqu\'à 6 photos)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos photos ne seront visibles qu\'après 10 lettres échangées ou avec un abonnement Premium',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: () {
              _showSuccess('📸 Fonctionnalité d\'upload photo en développement...');
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 48, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Ajouter une photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Aucune photo ajoutée. Ajoutez au moins une photo pour compléter votre profil.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return _buildCard(
      title: '✏️ Bio (Obligatoire - Min 50 caractères)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _bioController,
            maxLines: 5,
            maxLength: 500,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Décrivez-vous de manière authentique. C\'est la première chose que les autres verront...',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE91E63)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$_bioLength / 500 caractères (minimum 50)',
            style: TextStyle(
              color: _bioLength < 50 ? Colors.red : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildCard(
      title: 'ℹ️ Informations Personnelles',
      child: Column(
        children: [
          _buildTextField('Code Postal', _zipcodeController),
          _buildTextField('Ville', _cityController),
          _buildDateField(),
          _buildDropdown('Genre *', _selectedGender, [
            'Homme',
            'Femme',
            'Autre',
          ], (value) => setState(() => _selectedGender = value)),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return _buildCard(
      title: '❤️ Préférences de Rencontre',
      child: Column(
        children: [
          _buildDropdown('Intéressé·e par *', _selectedInterestedIn, [
            'Hommes',
            'Femmes',
            'Tout le monde',
          ], (value) => setState(() => _selectedInterestedIn = value)),
          _buildDropdown('Recherche', _selectedLookingFor, [
            'Relation sérieuse',
            'Amitié',
            'Découverte',
            'Autre',
          ], (value) => setState(() => _selectedLookingFor = value)),
          _buildDropdown('😊 Enfants', _selectedChildren, [
            'Aucun',
            'J\'en ai qui vivent avec moi',
            'J\'en ai qui ne vivent pas avec moi',
            'J\'en veux dans le futur',
            'Je n\'en veux pas',
          ], (value) => setState(() => _selectedChildren = value)),
        ],
      ),
    );
  }

  Widget _buildMorphologySection() {
    return _buildCard(
      title: '😄 Morphologie (Version Humour)',
      child: Column(
        children: _morphologyOptions.map((option) {
          final isSelected = _selectedMorphology == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedMorphology = option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFFE91E63).withOpacity(0.1)
                      : const Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFFE91E63)
                        : const Color(0xFF333333),
                    width: 2,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE91E63) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return _buildCard(
      title: '🎯 Jeu des 3 Questions (Brise-glace)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Créez 3 questions avec 3 réponses chacune. En cas de match, l\'autre personne devra répondre à vos questions pour débloquer les lettres.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ..._questions.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> question = entry.value;
            return _buildQuestionCard(index + 1, question);
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int questionNumber, Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF444444)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $questionNumber',
            style: const TextStyle(
              color: Color(0xFFE91E63),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: question['question'],
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            '3 Réponses possibles',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ...List.generate(3, (answerIndex) {
            final isCorrect = question['correctIndex'] == answerIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: question['answers'][answerIndex],
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE91E63), width: 2),
                      color: isCorrect ? const Color(0xFFE91E63) : Colors.transparent,
                    ),
                    child: isCorrect 
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ],
              ),
            );
          }),
          const Text(
            'Marquez la bonne réponse avec ✓',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE91E63)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date de naissance (pour afficher l\'âge)', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(1995),
                firstDate: DateTime(1950),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              );
              if (date != null) {
                _showSuccess('Date sélectionnée : ${date.day}/${date.month}/${date.year}');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sélectionner votre date de naissance', style: TextStyle(color: Colors.grey)),
                  Icon(Icons.calendar_today, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE91E63)),
              ),
            ),
            dropdownColor: const Color(0xFF2a2a2a),
            style: const TextStyle(color: Colors.white),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            hint: Text(
              'Sélectionnez une option',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          '💾 Sauvegarder le profil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}