import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'compose_letter_screen.dart';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _isFunMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFunMode ? AppColors.funBackground : AppColors.seriousBackground,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
            fontWeight: FontWeight.bold,
            color: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFunMode ? Icons.sentiment_very_satisfied : Icons.business_center),
            onPressed: () => setState(() => _isFunMode = !_isFunMode),
            tooltip: _isFunMode ? 'Mode sérieux' : 'Mode fun',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              'Aucun message pour le moment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _isFunMode ? AppColors.funText : AppColors.seriousText,
                fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Visitez les bars pour rencontrer\ndes personnes intéressantes !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_isFunMode ? 25 : 12),
                ),
              ),
              child: Text(
                'Explorer les bars',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComposeLetterScreen(),
            ),
          );
        },
        backgroundColor: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
        child: Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}