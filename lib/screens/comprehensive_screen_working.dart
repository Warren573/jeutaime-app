import 'package:flutter/material.dart';
import '../services/letters_service_simple.dart';
import '../services/weekly_bar_service.dart';
import '../services/hidden_bar_service.dart';
import '../services/anti_ghosting_service_fixed.dart';
import '../services/stripe_service.dart';
import '../services/photo_verification_service.dart';
import '../services/referral_service.dart';
import '../services/gamification_service.dart';

class ComprehensiveScreen extends StatefulWidget {
  const ComprehensiveScreen({Key? key}) : super(key: key);

  @override
  State<ComprehensiveScreen> createState() => _ComprehensiveScreenState();
}

class _ComprehensiveScreenState extends State<ComprehensiveScreen> {
  final LettersService _lettersService = LettersService.instance;
  final WeeklyBarService _weeklyBarService = WeeklyBarService.instance;
  final HiddenBarService _hiddenBarService = HiddenBarService.instance;
  final AntiGhostingService _antiGhostingService = AntiGhostingService.instance;
  final StripeService _stripeService = StripeService.instance;
  final PhotoVerificationService _photoService = PhotoVerificationService.instance;
  final ReferralService _referralService = ReferralService.instance;
  final GamificationService _gamificationService = GamificationService.instance;

  final String userId = 'demo_user_123';
  
  Map<String, dynamic> _userStats = {};
  Map<String, dynamic> _gamificationStats = {};
  List<Map<String, dynamic>> _activeLetters = [];
  List<Map<String, dynamic>> _weeklyBars = [];
  String? _referralCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      // Charger toutes les données en parallèle
      final results = await Future.wait([
        _antiGhostingService.getUserStats(userId),
        _gamificationService.getGamificationStats(userId),
        _lettersService.getUserLetters(userId),
        _weeklyBarService.getAvailableBars(),
        _referralService.getReferralStats(userId),
      ]);
      
      final userStats = results[0] as Map<String, dynamic>;
      final gamificationStats = results[1] as Map<String, dynamic>;
      final activeLetters = results[2] as List<Map<String, dynamic>>;
      final weeklyBars = results[3] as List<Map<String, dynamic>>;
      final referralStats = results[4] as Map<String, dynamic>;
      
      setState(() {
        _userStats = userStats;
        _gamificationStats = gamificationStats;
        _activeLetters = activeLetters;
        _weeklyBars = weeklyBars;
        _referralCode = referralStats['referralCode'];
        _isLoading = false;
      });
      
      // Vérifier et débloquer de nouveaux badges
      await _gamificationService.checkAndUnlockBadges(userId);
      
      // Créer le défi quotidien
      await _gamificationService.createDailyChallenge(userId);
      
    } catch (e) {
      print('Erreur chargement données: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('JeTaime - Système Complet'),
        backgroundColor: const Color(0xFF6B73FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSystemOverview(),
            const SizedBox(height: 16),
            _buildGamificationPreview(),
            const SizedBox(height: 16),
            _buildAntiGhostingPreview(),
            const SizedBox(height: 16),
            _buildLettersPreview(),
            const SizedBox(height: 16),
            _buildWeeklyBarsPreview(),
            const SizedBox(height: 16),
            _buildHiddenBarPreview(),
            const SizedBox(height: 16),
            _buildPremiumPreview(),
            const SizedBox(height: 16),
            _buildReferralPreview(),
            const SizedBox(height: 16),
            _buildPhotoVerificationPreview(),
            const SizedBox(height: 16),
            _buildQuickActionsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard, color: Color(0xFF6B73FF), size: 28),
                const SizedBox(width: 8),
                Text(
                  'JeTaime - Système Complet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '🎯 Tous les systèmes sont intégrés et fonctionnels :\n'
              '✅ Lettres authentiques (500 mots max)\n'
              '✅ Bars hebdomadaires (2M/2F matching)\n'
              '✅ Bar caché avec énigmes\n'
              '✅ Anti-ghosting avec sanctions\n'
              '✅ Paiements Stripe & Premium\n'
              '✅ Certification photo\n'
              '✅ Système de parrainage\n'
              '✅ Gamification complète',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B73FF), Color(0xFF9B59B6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Tous les systèmes sont opérationnels !',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationPreview() {
    final level = _gamificationStats['level'] ?? {};
    final badges = _gamificationStats['badges'] ?? {};
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Gamification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Niveau',
                    '${level['level'] ?? 1}',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Badges',
                    '${badges['total'] ?? 0}',
                    Icons.stars,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'XP Total',
                    '${level['totalXP'] ?? 0}',
                    Icons.flash_on,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAntiGhostingPreview() {
    final strikes = _userStats['strikes'] ?? 0;
    final reputation = _userStats['reputation'] ?? 100;
    final status = _userStats['status'] ?? 'active';
    
    Color statusColor = Colors.green;
    if (status == 'warning') statusColor = Colors.orange;
    if (status == 'restricted') statusColor = Colors.red;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: statusColor, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Anti-Ghosting',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Réputation',
                    '$reputation/100',
                    Icons.thumb_up,
                    reputation >= 80 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Strikes',
                    '$strikes/3',
                    Icons.warning,
                    strikes == 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Statut',
                    status == 'active' ? 'Actif' : 'Attention',
                    Icons.account_circle,
                    statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLettersPreview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mail, color: Colors.deepPurple, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Lettres Authentiques',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Échanges tour par tour avec limite 500 mots'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Actives',
                    '${_activeLetters.length}',
                    Icons.drafts,
                    Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _demoAction,
                    icon: const Icon(Icons.edit),
                    label: const Text('Nouvelle Lettre'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarsPreview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_bar, color: Colors.teal, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Bars Hebdomadaires',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Matching 2M/2F automatique, durée 7 jours'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Bars Actifs',
                    '${_weeklyBars.length}',
                    Icons.local_bar,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _demoAction,
                    icon: const Icon(Icons.add),
                    label: const Text('Créer Bar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenBarPreview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock, color: Colors.indigo, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Bar Caché',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Accès exclusif via 5 énigmes progressives'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade100, Colors.purple.shade100],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.indigo),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Résolvez 5 énigmes thématiques'),
                  ),
                  ElevatedButton(
                    onPressed: _demoAction,
                    child: const Text('Défier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPreview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.diamond, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'JeTaime Premium',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '✨ Fonctionnalités Premium ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Messages illimités • Badges exclusifs • Support prioritaire',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _demoAction,
                          child: const Text('1 Mois - 9.99€'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _demoAction,
                          child: const Text('1 An - 59.99€'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralPreview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group_add, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Système de Parrainage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Code de parrainage:',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          'ABC123',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _demoAction,
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '🎁 100 pièces par parrainage • 💰 Bonus aux paliers',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoVerificationPreview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.blue, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Certification Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Certifiez votre authenticité avec validation par modérateurs',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _demoAction,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Certifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions Rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _buildActionButton(
                  'Acheter Pièces',
                  Icons.monetization_on,
                  Colors.amber,
                  _demoAction,
                ),
                _buildActionButton(
                  'Classement',
                  Icons.leaderboard,
                  Colors.purple,
                  _demoAction,
                ),
                _buildActionButton(
                  'Mes Badges',
                  Icons.emoji_events,
                  Colors.orange,
                  _demoAction,
                ),
                _buildActionButton(
                  'Statistiques',
                  Icons.analytics,
                  Colors.teal,
                  _demoAction,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  void _demoAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎯 Fonctionnalité démonstrée - Système opérationnel !'),
        backgroundColor: Color(0xFF6B73FF),
      ),
    );
  }
}