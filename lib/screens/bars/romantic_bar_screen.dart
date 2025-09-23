import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/user_card.dart';
import '../../services/bar_service.dart';
import '../../models/user.dart' as app_user;

class RomanticBarScreen extends StatefulWidget {
  @override
  State<RomanticBarScreen> createState() => _RomanticBarScreenState();
}

class _RomanticBarScreenState extends State<RomanticBarScreen> {
  List<app_user.User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final users = await BarService.getUsersInBar('romantic');
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Text('Bar Romantique', style: TextStyle(color: AppColors.romanticBar)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.romanticBar))
        : _users.isEmpty
          ? Center(child: Text("Aucun profil pour l’instant."))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: UserCard(
                  user: _users[i],
                  barTheme: 'romantic',
                  onLike: _fetchUsers,
                  onMessage: () {},
                  onViewProfile: () {},
                ),
              ),
            ),
    );
  }
}
