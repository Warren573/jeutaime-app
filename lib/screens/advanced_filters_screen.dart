import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/matching_algorithm.dart';
import '../utils/performance_optimizer.dart';

class AdvancedFiltersScreen extends StatefulWidget {
  final AdvancedFilters? initialFilters;
  final Function(AdvancedFilters) onFiltersChanged;

  const AdvancedFiltersScreen({
    super.key,
    this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  State<AdvancedFiltersScreen> createState() => _AdvancedFiltersScreenState();
}

class _AdvancedFiltersScreenState extends State<AdvancedFiltersScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Filtres
  RangeValues _ageRange = const RangeValues(22, 35);
  double _maxDistance = 25.0;
  Set<String> _selectedEducationLevels = {};
  Set<String> _selectedProfessions = {};
  Set<String> _selectedInterests = {};
  
  // Style de vie
  bool? _smoking;
  bool? _drinking;
  String? _selectedDietType;
  double? _fitnessLevel;
  double? _socialActivity;

  // Listes de données
  final List<String> _educationLevels = [
    'Lycée',
    'BTS/DUT',
    'Licence',
    'Master',
    'Doctorat',
    'École de commerce',
    'École d\'ingénieur',
  ];

  final List<String> _professionCategories = [
    'Étudiant',
    'Technology',
    'Santé',
    'Éducation',
    'Finance',
    'Art & Design',
    'Marketing',
    'Ingénierie',
    'Droit',
    'Commerce',
    'Autre',
  ];

  final List<String> _availableInterests = [
    'Voyage',
    'Sport',
    'Musique',
    'Cuisine',
    'Cinéma',
    'Lecture',
    'Art',
    'Photographie',
    'Danse',
    'Randonnée',
    'Yoga',
    'Gaming',
    'Mode',
    'Tech',
    'Nature',
  ];

  final List<String> _dietTypes = [
    'Omnivore',
    'Végétarien',
    'Végétalien',
    'Pescétarien',
    'Sans gluten',
    'Keto',
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = PerformanceOptimizer.createOptimizedController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _initializeFilters();
    _animationController.forward();
  }

  void _initializeFilters() {
    if (widget.initialFilters != null) {
      final filters = widget.initialFilters!;
      _ageRange = RangeValues(
        filters.ageRange.min.toDouble(),
        filters.ageRange.max.toDouble(),
      );
      _maxDistance = filters.maxDistance;
      _selectedEducationLevels = filters.educationLevels.toSet();
      _selectedProfessions = filters.professionCategories.toSet();
      _selectedInterests = filters.requiredInterests.toSet();
      
      if (filters.lifestyle != null) {
        _smoking = filters.lifestyle!.smoking;
        _drinking = filters.lifestyle!.drinking;
        _selectedDietType = filters.lifestyle!.dietType;
        _fitnessLevel = filters.lifestyle!.fitnessLevel?.toDouble();
        _socialActivity = filters.lifestyle!.socialActivity?.toDouble();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = AdvancedFilters(
      ageRange: AgeRange(
        min: _ageRange.start.round(),
        max: _ageRange.end.round(),
      ),
      maxDistance: _maxDistance,
      educationLevels: _selectedEducationLevels.toList(),
      professionCategories: _selectedProfessions.toList(),
      requiredInterests: _selectedInterests.toList(),
      lifestyle: Lifestyle(
        smoking: _smoking,
        drinking: _drinking,
        dietType: _selectedDietType,
        fitnessLevel: _fitnessLevel?.round(),
        socialActivity: _socialActivity?.round(),
      ),
    );

    widget.onFiltersChanged(filters);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(22, 35);
      _maxDistance = 25.0;
      _selectedEducationLevels.clear();
      _selectedProfessions.clear();
      _selectedInterests.clear();
      _smoking = null;
      _drinking = null;
      _selectedDietType = null;
      _fitnessLevel = null;
      _socialActivity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          'Filtres avancés',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Réinitialiser',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _slideAnimation.value)),
            child: Opacity(
              opacity: _slideAnimation.value,
              child: _buildContent(),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a1a),
          border: Border(top: BorderSide(color: Color(0xFF333333))),
        ),
        child: ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Appliquer les filtres',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgeSection(),
          const SizedBox(height: 30),
          _buildDistanceSection(),
          const SizedBox(height: 30),
          _buildEducationSection(),
          const SizedBox(height: 30),
          _buildProfessionSection(),
          const SizedBox(height: 30),
          _buildInterestsSection(),
          const SizedBox(height: 30),
          _buildLifestyleSection(),
          const SizedBox(height: 100), // Espace pour le bouton
        ],
      ),
    );
  }

  Widget _buildAgeSection() {
    return _buildSection(
      title: 'Âge',
      icon: Icons.cake,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_ageRange.start.round()} - ${_ageRange.end.round()} ans',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 60,
            divisions: 42,
            activeColor: const Color(0xFFE91E63),
            inactiveColor: const Color(0xFF333333),
            onChanged: (values) {
              setState(() {
                _ageRange = values;
              });
              PerformanceOptimizer.hapticFeedback(HapticFeedbackType.selectionClick);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceSection() {
    return _buildSection(
      title: 'Distance maximale',
      icon: Icons.location_on,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_maxDistance.round()} km',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Slider(
            value: _maxDistance,
            min: 1,
            max: 100,
            divisions: 99,
            activeColor: const Color(0xFFE91E63),
            inactiveColor: const Color(0xFF333333),
            onChanged: (value) {
              setState(() {
                _maxDistance = value;
              });
              PerformanceOptimizer.hapticFeedback(HapticFeedbackType.selectionClick);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    return _buildSection(
      title: 'Niveau d\'éducation',
      icon: Icons.school,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _educationLevels.map((level) {
          final isSelected = _selectedEducationLevels.contains(level);
          return _buildChip(level, isSelected, () {
            setState(() {
              if (isSelected) {
                _selectedEducationLevels.remove(level);
              } else {
                _selectedEducationLevels.add(level);
              }
            });
          });
        }).toList(),
      ),
    );
  }

  Widget _buildProfessionSection() {
    return _buildSection(
      title: 'Secteur professionnel',
      icon: Icons.work,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _professionCategories.map((profession) {
          final isSelected = _selectedProfessions.contains(profession);
          return _buildChip(profession, isSelected, () {
            setState(() {
              if (isSelected) {
                _selectedProfessions.remove(profession);
              } else {
                _selectedProfessions.add(profession);
              }
            });
          });
        }).toList(),
      ),
    );
  }

  Widget _buildInterestsSection() {
    return _buildSection(
      title: 'Intérêts obligatoires',
      icon: Icons.favorite,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableInterests.map((interest) {
          final isSelected = _selectedInterests.contains(interest);
          return _buildChip(interest, isSelected, () {
            setState(() {
              if (isSelected) {
                _selectedInterests.remove(interest);
              } else {
                _selectedInterests.add(interest);
              }
            });
          });
        }).toList(),
      ),
    );
  }

  Widget _buildLifestyleSection() {
    return _buildSection(
      title: 'Style de vie',
      icon: Icons.fitness_center,
      child: Column(
        children: [
          _buildLifestyleRow('Fumeur/se', _smoking, (value) {
            setState(() {
              _smoking = value;
            });
          }),
          const SizedBox(height: 15),
          _buildLifestyleRow('Boit de l\'alcool', _drinking, (value) {
            setState(() {
              _drinking = value;
            });
          }),
          const SizedBox(height: 15),
          _buildDietDropdown(),
          const SizedBox(height: 15),
          _buildSliderRow('Niveau de fitness', _fitnessLevel, (value) {
            setState(() {
              _fitnessLevel = value;
            });
          }),
          const SizedBox(height: 15),
          _buildSliderRow('Activité sociale', _socialActivity, (value) {
            setState(() {
              _socialActivity = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE91E63), size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF444444),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLifestyleRow(String label, bool? value, Function(bool?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        Row(
          children: [
            _buildToggleButton('Oui', value == true, () => onChanged(true)),
            const SizedBox(width: 10),
            _buildToggleButton('Non', value == false, () => onChanged(false)),
            const SizedBox(width: 10),
            _buildToggleButton('Indifférent', value == null, () => onChanged(null)),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDietDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Régime alimentaire',
          style: TextStyle(color: Colors.white),
        ),
        DropdownButton<String?>(
          value: _selectedDietType,
          hint: const Text('Indifférent', style: TextStyle(color: Colors.grey)),
          dropdownColor: const Color(0xFF2a2a2a),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Indifférent', style: TextStyle(color: Colors.grey)),
            ),
            ..._dietTypes.map((diet) => DropdownMenuItem<String>(
              value: diet,
              child: Text(diet, style: const TextStyle(color: Colors.white)),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedDietType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSliderRow(String label, double? value, Function(double?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            if (value != null)
              Text(
                '${value.round()}/5',
                style: const TextStyle(color: Color(0xFFE91E63)),
              ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value ?? 3.0,
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: const Color(0xFFE91E63),
                inactiveColor: const Color(0xFF333333),
                onChanged: (newValue) => onChanged(newValue),
              ),
            ),
            TextButton(
              onPressed: () => onChanged(null),
              child: const Text(
                'Ignorer',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}