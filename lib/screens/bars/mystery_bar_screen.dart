import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/user_card.dart';
import '../../services/bar_service.dart';
import '../../models/user_model.dart';

class MysteryBarScreen extends StatefulWidget {
  @override
  State<MysteryBarScreen> createState() => _MysteryBarScreenState();
}

class _MysteryBarScreenState extends State<MysteryBarScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    // Suppose que tu as une méthode canAccessMysteryBar dans BarService
    _hasAccess = await BarService.canAccessMysteryBar(/*userId*/);
    if (_hasAccess) await _fetchUsers();
    setState(() {});
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final users = await BarService.getUsersInBar('mystery');
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAccess) {
      return Scaffold(
        backgroundColor: AppColors.funBackground,
        appBar: AppBar(
          title: Text('Bar Mystère', style: TextStyle(color: AppColors.mysteryBar)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text("🔒 Résous l’énigme du jour pour accéder à ce bar secret !"),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Text('Bar Mystère', style: TextStyle(color: AppColors.mysteryBar)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.mysteryBar))
        : _users.isEmpty
          ? Center(child: Text("Le bar mystère est vide pour l’instant…"))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: UserCard(
                  user: _users[i],
                  barTheme: 'mystery',
                  onLike: _fetchUsers,
                  onMessage: () {},
                  onViewProfile: () {},
                ),
              ),
            ),
    );
  }
}
