import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/user_card.dart';
import '../../services/bar_service.dart';
import '../../models/user.dart' as app_user;

class HumorBarScreen extends StatefulWidget {
  const HumorBarScreen({Key? key}) : super(key: key);

  @override
  State<HumorBarScreen> createState() => _HumorBarScreenState();
}

class _HumorBarScreenState extends State<HumorBarScreen> {
  List<app_user.User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final users = await BarService.getUsersInBar('humor');
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
        title: Text('Bar Humoristique', style: TextStyle(color: AppColors.humorBar)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.humorBar))
        : _users.isEmpty
          ? Center(child: Text("Personne à faire rire pour l’instant."))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: UserCard(
                  user: _users[i],
                  barTheme: 'humor',
                  onLike: _fetchUsers,
                  onMessage: () {},
                  onViewProfile: () {},
                ),
              ),
            ),
    );
  }
}
