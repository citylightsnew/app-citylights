import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'admin_dashboard.dart';
import 'resident_dashboard.dart';
import 'staff_dashboard.dart';

class DashboardRouter extends StatefulWidget {
  final String userName;
  final User? user;

  const DashboardRouter({super.key, required this.userName, this.user});

  @override
  State<DashboardRouter> createState() => _DashboardRouterState();
}

class _DashboardRouterState extends State<DashboardRouter> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (widget.user != null && widget.user!.role != null) {
        // Si ya tenemos el usuario con rol, usarlo
        setState(() {
          _currentUser = widget.user;
          _isLoading = false;
        });
      } else {
        // Cargar datos completos del usuario desde el backend (incluyendo rol)
        final authService = AuthService();
        final user = await authService.getCurrentUser();
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading user data: $e');
    }
  }

  Widget _getDashboardByRole() {
    if (_currentUser == null || _currentUser!.role == null) {
      // Dashboard por defecto si no hay rol
      debugPrint(
        '⚠️ Usuario sin rol asignado, usando ResidentDashboard por defecto',
      );
      debugPrint('Usuario: ${_currentUser?.name ?? "null"}');
      debugPrint('RoleId: ${_currentUser?.roleId ?? "null"}');
      return ResidentDashboard(userName: widget.userName, user: _currentUser);
    }

    final roleName = _currentUser!.role!.name.toLowerCase();
    debugPrint('✅ Rol detectado: $roleName (ID: ${_currentUser!.role!.id})');

    switch (roleName) {
      case 'admin':
      case 'administrador':
      case 'administrator':
        debugPrint('📊 Navegando a AdminDashboard');
        return AdminDashboard(userName: widget.userName, user: _currentUser!);

      case 'staff':
      case 'empleado':
      case 'personal':
      case 'employee':
        debugPrint('🛠️ Navegando a StaffDashboard');
        return StaffDashboard(userName: widget.userName, user: _currentUser!);

      case 'resident':
      case 'residente':
      case 'user':
      case 'usuario':
      default:
        debugPrint('🏠 Navegando a ResidentDashboard');
        return ResidentDashboard(userName: widget.userName, user: _currentUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
              const SizedBox(height: 20),
              Text(
                'Cargando...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _getDashboardByRole();
  }
}
