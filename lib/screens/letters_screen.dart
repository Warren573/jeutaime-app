import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/letters_service.dart';

class LettersScreen extends StatefulWidget {
  final String userId;
  
  const LettersScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _LettersScreenState createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('💌 Lettres Authentiques'),
        backgroundColor: Colors.amber.shade600,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.mail), text: 'Active'),
            Tab(icon: Icon(Icons.archive), text: 'Archives'),
            Tab(icon: Icon(Icons.edit), text: 'Écrire'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveLetters(),
          _buildArchivedLetters(),
          _buildWriteLetter(),
        ],
      ),
    );
  }

  Widget _buildActiveLetters() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
            colors: [
              UIReference.colors['background']!,
              UIReference.colors['accent']!.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildLettersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIReference.colors['primary']!,
            UIReference.colors['secondary']!,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Text('💌', style: TextStyle(fontSize: 28)),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              'Mes Lettres',
              style: UIReference.titleStyle.copyWith(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
          Icon(Icons.edit, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  Widget _buildLettersList() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correspondances romantiques',
            style: UIReference.subtitleStyle.copyWith(fontSize: 20),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildLetterCard('Sophie', 'Il était une fois...', '2 min', true),
                _buildLetterCard('Marie', 'Votre sourire illumine...', '1h', false),
                _buildLetterCard('Claire', 'Les étoiles cette nuit...', '3h', false),
                _buildLetterCard('Emma', 'J\'aimerais vous dire...', '1j', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(String name, String preview, String time, bool isNew) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UIReference.colors['cardBackground'],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: isNew ? Border.all(color: Color(0xFFE91E63), width: 2) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: UIReference.colors['accent'],
            child: Text(
              name[0],
              style: TextStyle(
                color: UIReference.colors['primary'],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: UIReference.subtitleStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: UIReference.colors['textSecondary'],
                        fontSize: 12,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  preview,
                  style: UIReference.bodyStyle.copyWith(
                    color: UIReference.colors['textSecondary'],
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isNew)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Color(0xFFE91E63),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}