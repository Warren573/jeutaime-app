import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/user_card.dart';
import '../../services/bar_service.dart';
import '../../models/user.dart' as app_user;

class WeeklyBarScreen extends StatefulWidget {
  @override
  State<WeeklyBarScreen> createState() => _WeeklyBarScreenState();
}

class _WeeklyBarScreenState extends State<WeeklyBarScreen> {
  List<app_user.User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final users = await BarService.getUsersInBar('weekly');
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
        title: Text('Bar Hebdomadaire', style: TextStyle(color: AppColors.weeklyBar)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.weeklyBar))
        : _users.isEmpty
          ? Center(child: Text("Aucun profil à l’honneur cette semaine."))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: UserCard(
                  user: _users[i],
                  barTheme: 'weekly',
                  onLike: _fetchUsers,
                  onMessage: () {},
                  onViewProfile: () {},
                ),
              ),
            ),
    );
  }
}
