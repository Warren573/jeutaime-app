import 'package:flutter/material.dart';
import '../../models/letter.dart';
import '../../config/ui_reference.dart';
import '../../services/progression_service.dart';
import '../../widgets/letter_composer.dart';

class ComposeLetterScreen extends StatefulWidget {
  final LetterThread? existingThread;

  const ComposeLetterScreen({
    super.key,
    this.existingThread,
  });

  @override
  State<ComposeLetterScreen> createState() => _ComposeLetterScreenState();
}

class _ComposeLetterScreenState extends State<ComposeLetterScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _currentStep = 0;
  LetterTemplate? _selectedTemplate;
  String _recipientId = '';
  String _recipientName = '';
  bool _isAnonymous = false;
  LetterType _selectedType = LetterType.romantic;
  
  final List<LetterTemplate> _templates = [];
  final ProgressionService _progressionService = ProgressionService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _loadTemplates();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadTemplates() {
    final userProgress = _progressionService.getUserProgress();
    final availableTemplates = LetterService.getAvailableTemplates(
      userLevel: userProgress.level,
    );
    
    setState(() {
      _templates.clear();
      _templates.addAll(availableTemplates);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.backgroundGradientStart,
      body: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildRecipientStep(),
                  _buildTypeSelectionStep(),
                  _buildTemplateSelectionStep(),
                  _buildComposeStep(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UIReference.backgroundGradientStart,
            UIReference.backgroundGradientEnd,
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: UIReference.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: UIReference.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: UIReference.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingThread != null ? 'Répondre' : 'Nouvelle lettre',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: UIReference.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getStepTitle(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: UIReference.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UIReference.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: UIReference.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: UIReference.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive 
                  ? UIReference.primaryColor 
                  : UIReference.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecipientStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: UIReference.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: UIReference.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: UIReference.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: UIReference.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'À qui écrivez-vous ?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: UIReference.textPrimary,
                            ),
                          ),
                          Text(
                            'Sélectionnez un destinataire',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: UIReference.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Champ de recherche
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un contact...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: UIReference.textSecondary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: UIReference.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    // Recherche de contacts
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Option anonyme
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: UIReference.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: UIReference.accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value ?? false;
                          });
                        },
                        activeColor: UIReference.accentColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lettre anonyme 🎭',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: UIReference.textPrimary,
                              ),
                            ),
                            Text(
                              'Le destinataire ne connaîtra pas votre identité',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: UIReference.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Contacts suggérés
          _buildSuggestedContacts(),
          
          const SizedBox(height: 20),
          
          // Bouton continuer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _recipientId.isNotEmpty || _isAnonymous ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: UIReference.primaryColor,
                foregroundColor: UIReference.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continuer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedContacts() {
    // Contacts de démonstration
    final contacts = [
      {'id': 'alice_123', 'name': 'Alice Martin', 'avatar': 'A', 'status': 'En ligne'},
      {'id': 'bob_456', 'name': 'Bob Dupont', 'avatar': 'B', 'status': 'Hors ligne'},
      {'id': 'charlie_789', 'name': 'Charlie Rousseau', 'avatar': 'C', 'status': 'En ligne'},
    ];
    
    return Container(
      decoration: BoxDecoration(
        color: UIReference.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UIReference.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Contacts suggérés',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: UIReference.textPrimary,
              ),
            ),
          ),
          ...contacts.map((contact) => ListTile(
            leading: CircleAvatar(
              backgroundColor: UIReference.primaryColor,
              child: Text(
                contact['avatar']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              contact['name']!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(contact['status']!),
            trailing: _recipientId == contact['id']
              ? Icon(
                  Icons.check_circle,
                  color: UIReference.primaryColor,
                )
              : null,
            onTap: () {
              setState(() {
                _recipientId = contact['id']!;
                _recipientName = contact['name']!;
              });
            },
            selected: _recipientId == contact['id'],
            selectedTileColor: UIReference.primaryColor.withOpacity(0.1),
          )),
        ],
      ),
    );
  }

  Widget _buildTypeSelectionStep() {
    final types = [
      {'type': LetterType.romantic, 'icon': '💕', 'title': 'Romantique', 'description': 'Déclarez vos sentiments'},
      {'type': LetterType.friendship, 'icon': '🤗', 'title': 'Amitié', 'description': 'Entretenez vos amitiés'},
      {'type': LetterType.gratitude, 'icon': '🙏', 'title': 'Gratitude', 'description': 'Exprimez votre reconnaissance'},
      {'type': LetterType.apology, 'icon': '😔', 'title': 'Excuses', 'description': 'Présentez vos excuses'},
      {'type': LetterType.confession, 'icon': '💭', 'title': 'Confession', 'description': 'Partagez vos secrets'},
      {'type': LetterType.poetry, 'icon': '📝', 'title': 'Poésie', 'description': 'Écrivez des vers'},
    ];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: UIReference.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: UIReference.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type de lettre',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: UIReference.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quel est l\'esprit de votre message ?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: UIReference.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: types.length,
              itemBuilder: (context, index) {
                final typeData = types[index];
                final type = typeData['type'] as LetterType;
                final isSelected = type == _selectedType;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? UIReference.primaryColor.withOpacity(0.1) : UIReference.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? UIReference.primaryColor : UIReference.textSecondary.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: UIReference.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          typeData['icon']! as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          typeData['title']! as String,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? UIReference.primaryColor : UIReference.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          typeData['description']! as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: UIReference.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UIReference.textSecondary,
                    side: BorderSide(color: UIReference.textSecondary.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIReference.primaryColor,
                    foregroundColor: UIReference.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSelectionStep() {
    final filteredTemplates = _templates
        .where((template) => template.type == _selectedType)
        .toList();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: UIReference.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: UIReference.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choisir un modèle',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: UIReference.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sélectionnez un template ou commencez de zéro',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: UIReference.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: Column(
              children: [
                // Option "Lettre libre"
                Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: const Text('Lettre libre'),
                    subtitle: const Text('Écrivez votre propre message'),
                    selected: _selectedTemplate == null,
                    onTap: () {
                      setState(() {
                        _selectedTemplate = null;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Templates disponibles
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = filteredTemplates[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text('Template ${template.id}'),
                            subtitle: Text(template.name),
                            selected: _selectedTemplate == template,
                            onTap: () {
                              setState(() {
                                _selectedTemplate = template;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UIReference.textSecondary,
                    side: BorderSide(color: UIReference.textSecondary.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIReference.primaryColor,
                    foregroundColor: UIReference.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Écrire la lettre',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComposeStep() {
    return LetterComposer(
      template: _selectedTemplate,
      recipientName: _recipientName,
      onSend: _sendLetter,
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Sélectionner le destinataire';
      case 1: return 'Choisir le type de message';
      case 2: return 'Sélectionner un modèle';
      case 3: return 'Rédiger votre lettre';
      default: return '';
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _sendLetter(String content) {
    // Logique d'envoi de lettre
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lettre envoyée avec succès !'),
        backgroundColor: UIReference.primaryColor,
      ),
    );
    
    Navigator.pop(context);
  }
}