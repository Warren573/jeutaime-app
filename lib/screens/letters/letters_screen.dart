import 'package:flutter/material.dart';
import '../../models/letter.dart';
import '../../config/ui_reference.dart';
import '../../widgets/letter_thread_card.dart';
import '../../widgets/floating_compose_button.dart';
import 'compose_letter_screen.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<LetterThread> _threads = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLetters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLetters() async {
    setState(() {
      _isLoading = true;
    });

    // Simulation de chargement des lettres
    await Future.delayed(const Duration(milliseconds: 800));

    // Données de démonstration
    _threads = [
      LetterThread(
        threadId: 'thread_1',
        participants: ['current_user', 'alice_123'],
        lastTurnUid: 'alice_123',
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        messageCount: 8,
      ),
      LetterThread(
        threadId: 'thread_2',
        participants: ['current_user', 'bob_456'],
        lastTurnUid: 'current_user',
        lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        messageCount: 3,
        status: ThreadStatus.ghostingDetected,
        ghostingDetectedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      LetterThread(
        threadId: 'thread_3',
        participants: ['current_user', 'charlie_789'],
        lastTurnUid: 'charlie_789',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        messageCount: 15,
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<LetterThread> get _filteredThreads {
    if (_searchQuery.isEmpty) return _threads;
    
    return _threads.where((thread) {
      // Ici, on filtrerait par nom du participant
      // Pour la démo, on simule
      return thread.threadId.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<LetterThread> get _activeThreads {
    return _filteredThreads.where((thread) => 
      thread.status == ThreadStatus.active).toList();
  }

  List<LetterThread> get _myTurnThreads {
    return _activeThreads.where((thread) => 
      thread.isUserTurn('current_user')).toList();
  }

  List<LetterThread> get _waitingThreads {
    return _activeThreads.where((thread) => 
      !thread.isUserTurn('current_user')).toList();
  }

  List<LetterThread> get _archivedThreads {
    return _filteredThreads.where((thread) => 
      thread.status == ThreadStatus.archived || 
      thread.status == ThreadStatus.ghostingDetected).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.backgroundGradientStart,
      body: Column(
        children: [
          // Header avec recherche
          _buildHeader(),
          
          // Tabs
          _buildTabs(),
          
          // Contenu
          Expanded(
            child: _isLoading 
              ? _buildLoadingState()
              : _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingComposeButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ComposeLetterScreen(),
            ),
          );
        },
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Lettres',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: UIReference.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitleText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: UIReference.textSecondary,
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
                  Icons.mail_outline,
                  color: UIReference.white,
                  size: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: UIReference.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: UIReference.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(color: UIReference.white),
              decoration: InputDecoration(
                hintText: 'Rechercher une conversation...',
                hintStyle: TextStyle(
                  color: UIReference.white.withOpacity(0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: UIReference.white.withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: UIReference.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: UIReference.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit, size: 18),
                const SizedBox(width: 8),
                Text('Mon tour'),
                if (_myTurnThreads.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: UIReference.accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_myTurnThreads.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_empty, size: 18),
                const SizedBox(width: 8),
                Text('En attente'),
                if (_waitingThreads.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: UIReference.textSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_waitingThreads.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.archive_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Archives'),
              ],
            ),
          ),
        ],
        labelColor: UIReference.primaryColor,
        unselectedLabelColor: UIReference.textSecondary,
        indicatorColor: UIReference.primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildThreadsList(_myTurnThreads, 'C\'est à vous de répondre !'),
        _buildThreadsList(_waitingThreads, 'En attente de réponse...'),
        _buildThreadsList(_archivedThreads, 'Conversations archivées'),
      ],
    );
  }

  Widget _buildThreadsList(List<LetterThread> threads, String emptyMessage) {
    if (threads.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: _loadLetters,
      color: UIReference.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: threads.length,
        itemBuilder: (context, index) {
          final thread = threads[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == threads.length - 1 ? 100 : 16,
            ),
            child: LetterThreadCard(
              thread: thread,
              onTap: () => _openThread(thread),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: UIReference.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mail_outline,
              size: 48,
              color: UIReference.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: UIReference.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComposeLetterScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Écrire une lettre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIReference.primaryColor,
              foregroundColor: UIReference.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: UIReference.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement de vos lettres...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: UIReference.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitleText() {
    final myTurnCount = _myTurnThreads.length;
    if (myTurnCount > 0) {
      return '$myTurnCount conversation${myTurnCount > 1 ? 's' : ''} en attente';
    }
    return 'Aucune lettre en attente';
  }

  void _openThread(LetterThread thread) {
    // Navigation vers l'écran de conversation
    // Pour l'instant, on affiche juste un snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouvrir la conversation ${thread.threadId}'),
        backgroundColor: UIReference.primaryColor,
      ),
    );
  }
}