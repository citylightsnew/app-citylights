import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/models/user_model.dart';
import 'admin/admin_dashboard.dart';
import 'user/user_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Determinar el dashboard según el rol
        if (_isAdmin(user)) {
          return AdminDashboard(user: user);
        } else {
          return UserDashboard(user: user);
        }
      },
    );
  }

  bool _isAdmin(UserModel user) {
    return user.roles.any(
      (role) =>
          role.toLowerCase() == 'admin' || role.toLowerCase() == 'super-user',
    );
  }
}
