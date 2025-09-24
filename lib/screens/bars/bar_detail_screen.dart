import 'package:flutter/material.dart';
import '../../models/bar_content.dart';
import '../../config/ui_reference.dart';

class BarDetailScreen extends StatefulWidget {
  final BarContent barContent;

  const BarDetailScreen({
    Key? key,
    required this.barContent,
  }) : super(key: key);

  @override
  _BarDetailScreenState createState() => _BarDetailScreenState();
}

class _BarDetailScreenState extends State<BarDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.colors['background'],
      body: CustomScrollView(
        slivers: [
          // App Bar avec effet parallax
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: widget.barContent.themeColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.barContent.name,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.barContent.themeColor,
                      widget.barContent.themeColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 2.0,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Emoji central
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.barContent.emoji,
                            style: TextStyle(fontSize: 60),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: UIReference.subtitleStyle.copyWith(
                            color: widget.barContent.themeColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.barContent.description,
                          style: UIReference.bodyStyle.copyWith(height: 1.5),
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow(),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Tabs pour Activités et Défis
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Tab bar
                        Container(
                          decoration: BoxDecoration(
                            color: widget.barContent.themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: widget.barContent.themeColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: widget.barContent.themeColor,
                            tabs: [
                              Tab(
                                icon: Icon(Icons.sports_esports),
                                text: 'Activités',
                              ),
                              Tab(
                                icon: Icon(Icons.emoji_events),
                                text: 'Défis',
                              ),
                              Tab(
                                icon: Icon(Icons.people),
                                text: 'Communauté',
                              ),
                            ],
                          ),
                        ),
                        // Tab content
                        Container(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildActivitiesTab(),
                              _buildChallengesTab(),
                              _buildCommunityTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _joinBar,
        backgroundColor: widget.barContent.themeColor,
        icon: Icon(Icons.add),
        label: Text(
          'Rejoindre',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoChip(
            icon: Icons.group,
            label: 'Activités',
            value: '${widget.barContent.activities.length}',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildInfoChip(
            icon: Icons.emoji_events,
            label: 'Défis',
            value: '${widget.barContent.challenges.length}',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildInfoChip(
            icon: Icons.accessibility_new,
            label: 'Accès',
            value: _getAccessLevelText(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: widget.barContent.themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.barContent.themeColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: widget.barContent.themeColor,
            size: 20,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.barContent.themeColor,
              fontFamily: 'Georgia',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: widget.barContent.themeColor.withOpacity(0.7),
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: widget.barContent.activities.length,
      itemBuilder: (context, index) {
        final activity = widget.barContent.activities[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    activity.emoji,
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UIReference.colors['textPrimary'],
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.barContent.themeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${activity.participantsMin}-${activity.participantsMax} joueurs',
                      style: TextStyle(
                        fontSize: 10,
                        color: widget.barContent.themeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                activity.description,
                style: UIReference.bodyStyle.copyWith(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _formatDuration(activity.estimatedDuration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => _joinActivity(activity),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.barContent.themeColor,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Participer',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: widget.barContent.challenges.length,
      itemBuilder: (context, index) {
        final challenge = widget.barContent.challenges[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    challenge.emoji,
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      challenge.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UIReference.colors['textPrimary'],
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber.shade700,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${challenge.pointsReward} pts',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                challenge.description,
                style: UIReference.bodyStyle.copyWith(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  if (challenge.isDaily)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'QUOTIDIEN',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (challenge.isWeekly)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'HEBDOMADAIRE',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => _acceptChallenge(challenge),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.barContent.themeColor,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Relever',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommunityTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats de la communauté
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.barContent.themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Membres Actifs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.barContent.themeColor,
                    fontFamily: 'Georgia',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '127 membres',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: widget.barContent.themeColor,
                    fontFamily: 'Georgia',
                  ),
                ),
                Text(
                  'dont 23 en ligne',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Membres récents ou en ligne
          Text(
            'Membres Récents',
            style: UIReference.subtitleStyle,
          ),
          SizedBox(height: 12),
          
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Mock data
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: widget.barContent.themeColor,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Membre ${index + 1}',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('En ligne'),
                  trailing: Icon(
                    Icons.circle,
                    color: Colors.green,
                    size: 12,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getAccessLevelText() {
    switch (widget.barContent.accessLevel) {
      case BarAccessLevel.public:
        return 'Public';
      case BarAccessLevel.restricted:
        return 'Restreint';
      case BarAccessLevel.premium:
        return 'Premium';
      case BarAccessLevel.hidden:
        return 'Caché';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    }
    return '${duration.inMinutes}min';
  }

  void _joinBar() {
    // Logique pour rejoindre le bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous avez rejoint ${widget.barContent.name}!'),
        backgroundColor: widget.barContent.themeColor,
      ),
    );
  }

  void _joinActivity(BarActivity activity) {
    // Logique pour participer à une activité
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Participation à "${activity.title}" enregistrée!'),
        backgroundColor: widget.barContent.themeColor,
      ),
    );
  }

  void _acceptChallenge(BarChallenge challenge) {
    // Logique pour accepter un défi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Défi "${challenge.title}" accepté!'),
        backgroundColor: widget.barContent.themeColor,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}