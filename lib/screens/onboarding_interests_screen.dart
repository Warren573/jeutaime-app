import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'onboarding_photo_screen.dart';

class OnboardingInterestsScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const OnboardingInterestsScreen({
    Key? key,
    required this.profileData,
  }) : super(key: key);

  @override
  State<OnboardingInterestsScreen> createState() => _OnboardingInterestsScreenState();
}

class _OnboardingInterestsScreenState extends State<OnboardingInterestsScreen> {
  final Set<String> _selectedInterests = {};

  final List<Map<String, dynamic>> _availableInterests = [
    {'id': 'musique', 'label': 'Musique', 'icon': Icons.music_note, 'color': Colors.purple},
    {'id': 'cinema', 'label': 'Cinéma', 'icon': Icons.movie, 'color': Colors.red},
    {'id': 'lecture', 'label': 'Lecture', 'icon': Icons.book, 'color': Colors.brown},
    {'id': 'voyage', 'label': 'Voyage', 'icon': Icons.flight, 'color': Colors.blue},
    {'id': 'sport', 'label': 'Sport', 'icon': Icons.fitness_center, 'color': Colors.green},
    {'id': 'cuisine', 'label': 'Cuisine', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'id': 'art', 'label': 'Art', 'icon': Icons.palette, 'color': Colors.pink},
    {'id': 'nature', 'label': 'Nature', 'icon': Icons.nature, 'color': Colors.lightGreen},
    {'id': 'photographie', 'label': 'Photographie', 'icon': Icons.camera_alt, 'color': Colors.indigo},
    {'id': 'danse', 'label': 'Danse', 'icon': Icons.music_video, 'color': Colors.deepPurple},
    {'id': 'jeux', 'label': 'Jeux', 'icon': Icons.games, 'color': Colors.teal},
    {'id': 'technologie', 'label': 'Technologie', 'icon': Icons.computer, 'color': Colors.cyan},
    {'id': 'yoga', 'label': 'Yoga & Méditation', 'icon': Icons.self_improvement, 'color': Colors.deepOrange},
    {'id': 'animaux', 'label': 'Animaux', 'icon': Icons.pets, 'color': Colors.amber},
    {'id': 'mode', 'label': 'Mode', 'icon': Icons.checkroom, 'color': Colors.pinkAccent},
    {'id': 'jardinage', 'label': 'Jardinage', 'icon': Icons.local_florist, 'color': Colors.green[700]!},
    {'id': 'bricolage', 'label': 'Bricolage & DIY', 'icon': Icons.build, 'color': Colors.grey[700]!},
    {'id': 'astronomie', 'label': 'Astronomie', 'icon': Icons.star, 'color': Colors.indigo[900]!},
    {'id': 'bénévolat', 'label': 'Bénévolat', 'icon': Icons.volunteer_activism, 'color': Colors.red[600]!},
    {'id': 'spiritualité', 'label': 'Spiritualité', 'icon': Icons.psychology, 'color': Colors.purple[300]!},
  ];

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
          'Vos intérêts',
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
                    'Qu\'est-ce qui vous passionne ?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez au moins 3 intérêts pour nous aider à vous proposer des profils compatibles et des bars thématiques qui vous plairont.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Compteur de sélection
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedInterests.length >= 3 
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedInterests.length >= 3 
                            ? AppColors.primary
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      '${_selectedInterests.length} intérêt${_selectedInterests.length > 1 ? 's' : ''} sélectionné${_selectedInterests.length > 1 ? 's' : ''} (min. 3)',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedInterests.length >= 3 
                            ? AppColors.primary
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grille d'intérêts
                  _buildInterestsGrid(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bouton continuer
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedInterests.length >= 3 ? _continueToPhoto : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  'Continuer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _selectedInterests.length >= 3 ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
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
        _buildStepIndicator(2, true, 'Intérêts'),
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
            color: step == 1 ? AppColors.primary : (isActive ? AppColors.primary : Colors.grey[300]),
          ),
          child: Center(
            child: step == 1
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
            color: (step == 1 || isActive) ? AppColors.primary : Colors.grey[600],
            fontWeight: (step == 1 || isActive) ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildInterestsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _availableInterests.length,
      itemBuilder: (context, index) {
        final interest = _availableInterests[index];
        final isSelected = _selectedInterests.contains(interest['id']);

        return GestureDetector(
          onTap: () => _toggleInterest(interest['id']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? (interest['color'] as Color).withOpacity(0.1)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? (interest['color'] as Color)
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  interest['icon'],
                  color: isSelected 
                      ? (interest['color'] as Color)
                      : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    interest['label'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.black87 : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: interest['color'] as Color,
                    size: 18,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleInterest(String interestId) {
    setState(() {
      if (_selectedInterests.contains(interestId)) {
        _selectedInterests.remove(interestId);
      } else {
        _selectedInterests.add(interestId);
      }
    });
  }

  void _continueToPhoto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingPhotoScreen(
          profileData: {
            ...widget.profileData,
            'interests': _selectedInterests.toList(),
          },
        ),
      ),
    );
  }
}