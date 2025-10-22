import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/app_theme.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../components/components.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final UserService _userService = UserService();
  List<Role> _roles = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      print('🔄 Cargando roles...');
      final roles = await _userService.getAllRoles();
      print('✅ ${roles.length} roles cargados');

      if (mounted) {
        setState(() {
          _roles = roles;
          _isLoading = false;
        });
        print('✅ Estado actualizado correctamente');
      }
    } catch (e) {
      print('❌ Error al cargar roles: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        String errorMessage = 'Error al cargar roles: ${e.toString()}';

        if (e.toString().contains('401') ||
            e.toString().contains('Unauthorized')) {
          errorMessage = 'No autorizado. Por favor, inicia sesión nuevamente';
          print('❌ Error 401: Token inválido o expirado');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
          });
        } else if (e.toString().contains('403') ||
            e.toString().contains('Forbidden')) {
          errorMessage = 'No tienes permisos para acceder a los roles';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  List<Role> get _filteredRoles {
    if (_searchQuery.isEmpty) return _roles;
    return _roles.where((role) {
      return role.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          role.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showRoleDialog([Role? role]) {
    final nameController = TextEditingController(text: role?.name ?? '');
    final descriptionController = TextEditingController(
      text: role?.description ?? '',
    );
    final permissionsController = TextEditingController(
      text: role?.permissions?.join(', ') ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          role == null ? 'Crear Rol' : 'Editar Rol',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre del rol',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(
                    FontAwesomeIcons.tag,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(
                    FontAwesomeIcons.alignLeft,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: permissionsController,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Permisos (separados por coma)',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(
                    FontAwesomeIcons.shield,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'users.read, users.write, etc.',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre es requerido')),
                );
                return;
              }

              try {
                final permissions = permissionsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                if (role == null) {
                  await _userService.createRole(
                    name: nameController.text,
                    description: descriptionController.text,
                    permissions: permissions.isEmpty ? null : permissions,
                  );
                } else {
                  await _userService.updateRole(
                    id: role.id,
                    name: nameController.text,
                    description: descriptionController.text,
                    permissions: permissions.isEmpty ? null : permissions,
                  );
                }

                if (mounted) {
                  Navigator.pop(context);
                  _loadRoles();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        role == null
                            ? 'Rol creado correctamente'
                            : 'Rol actualizado correctamente',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: Text(role == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRole(Role role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          '¿Está seguro de eliminar el rol "${role.name}"?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _userService.deleteRole(role.id);
        _loadRoles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rol eliminado correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Gestión de Roles'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: () => _showRoleDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar roles...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                ),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRoles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.userShield,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay roles registrados'
                              : 'No se encontraron resultados',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadRoles,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredRoles.length,
                      itemBuilder: (context, index) {
                        final role = _filteredRoles[index];
                        return Card(
                          color: AppTheme.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppTheme.border),
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.userShield,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              role.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              role.description,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppTheme.textSecondary,
                              ),
                              color: AppTheme.surface,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: () => Future.delayed(
                                    Duration.zero,
                                    () => _showRoleDialog(role),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: AppTheme.textSecondary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Editar',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: () => Future.delayed(
                                    Duration.zero,
                                    () => _deleteRole(role),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              if (role.permissions != null &&
                                  role.permissions!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Permisos:',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: role.permissions!
                                            .map(
                                              (permission) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.secondary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: AppTheme.secondary
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      FontAwesomeIcons.shield,
                                                      size: 12,
                                                      color: AppTheme.secondary,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      permission,
                                                      style: const TextStyle(
                                                        color:
                                                            AppTheme.secondary,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Sin permisos asignados',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 0),
    );
  }
}
