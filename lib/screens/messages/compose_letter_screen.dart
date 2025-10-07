import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ComposeLetterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Composer une lettre'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text('Éditeur de lettre à implémenter'),
      ),
    );
  }
}
