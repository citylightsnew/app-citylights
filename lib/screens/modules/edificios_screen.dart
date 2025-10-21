import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/app_theme.dart';
import '../../services/edificio_service.dart';
import '../../models/edificio_model.dart';

class EdificiosScreen extends StatefulWidget {
  const EdificiosScreen({super.key});

  @override
  State<EdificiosScreen> createState() => _EdificiosScreenState();
}

class _EdificiosScreenState extends State<EdificiosScreen> {
  final EdificioService _edificioService = EdificioService();
  List<Edificio> _edificios = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEdificios();
  }

  Future<void> _loadEdificios() async {
    setState(() => _isLoading = true);
    try {
      final edificios = await _edificioService.getAllEdificios();
      setState(() {
        _edificios = edificios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar edificios: ${e.toString()}')),
        );
      }
    }
  }

  List<Edificio> get _filteredEdificios {
    if (_searchQuery.isEmpty) return _edificios;
    return _edificios
        .where(
          (e) =>
              e.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.direccion.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Future<void> _showEdificioDialog([Edificio? edificio]) async {
    final nombreController = TextEditingController(
      text: edificio?.nombre ?? '',
    );
    final direccionController = TextEditingController(
      text: edificio?.direccion ?? '',
    );
    final habitacionesController = TextEditingController(
      text: edificio?.numeroHabitaciones.toString() ?? '0',
    );
    final garajesController = TextEditingController(
      text: edificio?.numeroGarajes.toString() ?? '0',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          edificio == null ? 'Nuevo Edificio' : 'Editar Edificio',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: direccionController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: habitacionesController,
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número de Habitaciones',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: garajesController,
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número de Garajes',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isEmpty ||
                  direccionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complete todos los campos obligatorios'),
                  ),
                );
                return;
              }

              try {
                if (edificio == null) {
                  await _edificioService.createEdificio(
                    nombre: nombreController.text,
                    direccion: direccionController.text,
                    numeroHabitaciones:
                        int.tryParse(habitacionesController.text) ?? 0,
                    numeroGarajes: int.tryParse(garajesController.text) ?? 0,
                  );
                } else {
                  await _edificioService.updateEdificio(
                    id: edificio.id,
                    nombre: nombreController.text,
                    direccion: direccionController.text,
                    numeroHabitaciones: int.tryParse(
                      habitacionesController.text,
                    ),
                    numeroGarajes: int.tryParse(garajesController.text),
                  );
                }
                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: Text(edificio == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadEdificios();
    }
  }

  Future<void> _deleteEdificio(Edificio edificio) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          '¿Está seguro de eliminar el edificio "${edificio.nombre}"?',
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
        await _edificioService.deleteEdificio(edificio.id);
        _loadEdificios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edificio eliminado correctamente')),
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
        title: const Text('Edificios'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: () => _showEdificioDialog(),
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
                hintText: 'Buscar edificios...',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
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
                : _filteredEdificios.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.building,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay edificios registrados'
                              : 'No se encontraron resultados',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadEdificios,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredEdificios.length,
                      itemBuilder: (context, index) {
                        final edificio = _filteredEdificios[index];
                        return Card(
                          color: AppTheme.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppTheme.border),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.building,
                                color: AppTheme.primary,
                              ),
                            ),
                            title: Text(
                              edificio.nombre,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  edificio.direccion,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildStatChip(
                                      Icons.door_front_door,
                                      '${edificio.numeroHabitaciones} hab.',
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatChip(
                                      Icons.garage,
                                      '${edificio.numeroGarajes} gar.',
                                    ),
                                  ],
                                ),
                              ],
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
                                    () => _showEdificioDialog(edificio),
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
                                    () => _deleteEdificio(edificio),
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
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.primary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
