import 'package:flutter/material.dart';
import '../services/letters_service_simple.dart';
import '../services/weekly_bar_service.dart';
import '../services/hidden_bar_service.dart';
import '../services/anti_ghosting_service.dart';
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
            _buildGamificationCard(),
            const SizedBox(height: 16),
            _buildAntiGhostingCard(),
            const SizedBox(height: 16),
            _buildLettersCard(),
            const SizedBox(height: 16),
            _buildWeeklyBarsCard(),
            const SizedBox(height: 16),
            _buildHiddenBarCard(),
            const SizedBox(height: 16),
            _buildPremiumCard(),
            const SizedBox(height: 16),
            _buildReferralCard(),
            const SizedBox(height: 16),
            _buildPhotoVerificationCard(),
            const SizedBox(height: 16),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationCard() {
    final level = _gamificationStats['level'] ?? {};
    final badges = _gamificationStats['badges'] ?? {};
    final challenges = _gamificationStats['challenges'] ?? {};
    
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
                Text(
                  'Gamification',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Niveau utilisateur
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B73FF), Color(0xFF9B59B6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Niveau ${level['level'] ?? 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          level['title'] ?? 'Nouveau Romantique',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (level['progressPercent'] ?? 0) / 100,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${level['currentLevelXP'] ?? 0} / ${level['xpForNextLevel'] ?? 100} XP',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${level['totalXP'] ?? 0} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Badges et défis
            Row(
              children: [
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
                    'Défis Complétés',
                    '${challenges['totalCompleted'] ?? 0}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            // Défi du jour
            if (challenges['today'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.today, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Défi du Jour: ${challenges['today']['title']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(challenges['today']['description'] ?? ''),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (challenges['today']['progress'] ?? 0) / (challenges['today']['target'] ?? 1),
                      backgroundColor: Colors.blue.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${challenges['today']['progress'] ?? 0} / ${challenges['today']['target'] ?? 1} - Récompense: ${challenges['today']['reward'] ?? 0} pièces',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAntiGhostingCard() {
    final strikes = _userStats['strikes'] ?? 0;
    final reputation = _userStats['reputation'] ?? 100;
    final status = _userStats['status'] ?? 'active';
    
    Color statusColor = Colors.green;
    String statusText = 'Actif';
    
    if (status == 'warning') {
      statusColor = Colors.orange;
      statusText = 'Avertissement';
    } else if (status == 'restricted') {
      statusColor = Colors.red;
      statusText = 'Restreint';
    }
    
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
                Text(
                  'Système Anti-Ghosting',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Statut',
                    statusText,
                    Icons.account_circle,
                    statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Réputation',
                    '$reputation/100',
                    Icons.thumb_up,
                    reputation >= 80 ? Colors.green : reputation >= 60 ? Colors.orange : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Strikes',
                    '$strikes/3',
                    Icons.warning,
                    strikes == 0 ? Colors.green : strikes < 3 ? Colors.orange : Colors.red,
                  ),
                ),
              ],
            ),
            
            if (strikes > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Attention: Vous avez $strikes strike${strikes > 1 ? 's' : ''}. Soyez respectueux pour éviter les sanctions.',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLettersCard() {
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
                Text(
                  'Système de Lettres',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Échanges authentiques avec limite de 500 mots',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Lettres Actives',
                    '${_activeLetters.length}',
                    Icons.drafts,
                    Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showLetterDialog(),
                    icon: const Icon(Icons.edit),
                    label: const Text('Écrire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            if (_activeLetters.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Lettres en cours:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(_activeLetters.take(3)).map((letter) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      letter['status'] == 'waiting_reply' ? Icons.schedule : Icons.mail_outline,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Échange avec ${letter['participantId']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            letter['status'] == 'waiting_reply' ? 'En attente de réponse' : 'À votre tour',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarsCard() {
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
                Text(
                  'Bars Hebdomadaires',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Système 2M/2F avec appariement automatique',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                    onPressed: () => _createWeeklyBar(),
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
            
            if (_weeklyBars.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Bars disponibles:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(_weeklyBars.take(2)).map((bar) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_bar, color: Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bar['name'] ?? 'Bar Hebdomadaire',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${bar['participants']?.length ?? 0}/4 participants',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _joinWeeklyBar(bar['id']),
                      child: const Text('Rejoindre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenBarCard() {
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
                Text(
                  'Bar Caché',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Accès exclusif via 5 énigmes progressives',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quête des Énigmes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Résolvez 5 énigmes thématiques pour déverrouiller l\'accès exclusif',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _startRiddleQuest(),
                    child: const Text('Commencer'),
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

  Widget _buildPremiumCard() {
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
                Text(
                  'JeTaime Premium',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Messages illimités\n• Accès prioritaire aux bars\n• Badges exclusifs\n• Support prioritaire',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _subscribeToPremium('monthly'),
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
                          onPressed: () => _subscribeToPremium('yearly'),
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

  Widget _buildReferralCard() {
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
                Text(
                  'Parrainage',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_referralCode != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Votre code de parrainage:',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            _referralCode!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _shareReferralCode(),
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
              const SizedBox(height: 12),
            ],
            
            const Text(
              '🎁 Gagnez 100 pièces par parrainage réussi\n💰 Votre filleul reçoit 50 pièces de bienvenue\n🏆 Bonus aux paliers: 5, 10, 25 parrainages',
              style: TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _generateReferralCode(),
              icon: const Icon(Icons.code),
              label: const Text('Générer mon Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoVerificationCard() {
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
                Text(
                  'Vérification Photo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Certifiez votre authenticité',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Augmentez votre crédibilité avec une photo certifiée par nos modérateurs',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _startPhotoVerification(),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Soumettre Photo'),
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

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions Rapides',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _buyCoins(),
                  icon: const Icon(Icons.monetization_on),
                  label: const Text('Acheter Pièces'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _viewLeaderboard(),
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('Classement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _viewBadges(),
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Mes Badges'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _viewStats(),
                  icon: const Icon(Icons.analytics),
                  label: const Text('Statistiques'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Actions des boutons
  void _showLetterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Lettre'),
        content: const Text('Fonctionnalité d\'écriture de lettre à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _createWeeklyBar() async {
    final result = {'success': true}; // Demo
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bar créé avec succès!')),
      );
      _loadUserData();
    }
  }

  Future<void> _joinWeeklyBar(String barId) async {
    final result = await _weeklyBarService.joinWeeklyBar(userId, barId, 'male');
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous avez rejoint le bar!')),
      );
      _loadUserData();
    }
  }

  Future<void> _startRiddleQuest() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Première Énigme'),
        content: const Text('Qui suis-je ? Je grandis quand on me nourrit, mais je meurs quand on me donne à boire.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Commencer'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _subscribeToPremium(String plan) async {
    final result = await _stripeService.createPaymentSession(
      userId: userId,
      productId: plan == 'monthly' ? 'premium_monthly' : 'premium_yearly',
      successUrl: 'https://jeutaime.app/success',
      cancelUrl: 'https://jeutaime.app/cancel',
    );
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Redirection vers le paiement...')),
      );
    }
  }

  Future<void> _generateReferralCode() async {
    final code = await _referralService.generateReferralCode(userId);
    
    if (code != null) {
      setState(() {
        _referralCode = code;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code généré: $code')),
      );
    }
  }

  void _shareReferralCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code $_referralCode copié!')),
    );
  }

  Future<void> _startPhotoVerification() async {
    final result = {'success': true}; // Demo
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo soumise pour vérification!')),
      );
    }
  }

  void _buyCoins() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acheter des Pièces'),
        content: const Text('Système d\'achat de pièces à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _viewLeaderboard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Classement'),
        content: const Text('Système de classement à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _viewBadges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mes Badges'),
        content: const Text('Collection de badges à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _viewStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques'),
        content: const Text('Statistiques détaillées à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}