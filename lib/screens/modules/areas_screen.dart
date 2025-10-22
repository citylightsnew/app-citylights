import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/app_theme.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../components/components.dart';

class AreasScreen extends StatefulWidget {
  const AreasScreen({super.key});

  @override
  State<AreasScreen> createState() => _AreasScreenState();
}

class _AreasScreenState extends State<AreasScreen> {
  final BookingService _service = BookingService();
  List<AreaComun> _areas = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool? _selectedActiva;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() => _isLoading = true);
    try {
      final areas = await _service.getAllAreas();
      if (mounted) {
        setState(() {
          _areas = areas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar áreas: ${e.toString()}')),
        );
      }
    }
  }

  List<AreaComun> get _filteredAreas {
    var filtered = _areas;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (a) =>
                a.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                a.descripcion.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (_selectedActiva != null) {
      filtered = filtered.where((a) => a.activa == _selectedActiva).toList();
    }

    return filtered;
  }

  Future<void> _showAreaDialog([AreaComun? area]) async {
    final nombreController = TextEditingController(text: area?.nombre ?? '');
    final descripcionController = TextEditingController(
      text: area?.descripcion ?? '',
    );
    final capacidadController = TextEditingController(
      text: area?.capacidad.toString() ?? '0',
    );
    final costoController = TextEditingController(
      text: area?.costoReserva.toString() ?? '0.0',
    );
    bool requiereAprobacion = area?.requiereAprobacion ?? false;
    bool activa = area?.activa ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            area == null ? 'Nueva Área Común' : 'Editar Área Común',
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
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descripcionController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: capacidadController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Capacidad',
                          labelStyle: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF10B981)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: costoController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Costo (\$)',
                          labelStyle: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF10B981)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text(
                    'Requiere Aprobación',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  value: requiereAprobacion,
                  onChanged: (value) =>
                      setDialogState(() => requiereAprobacion = value!),
                  activeColor: const Color(0xFF10B981),
                ),
                CheckboxListTile(
                  title: const Text(
                    'Activa',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  value: activa,
                  onChanged: (value) => setDialogState(() => activa = value!),
                  activeColor: const Color(0xFF10B981),
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
                try {
                  if (area == null) {
                    await _service.createArea(
                      nombre: nombreController.text,
                      descripcion: descripcionController.text,
                      capacidad: int.tryParse(capacidadController.text) ?? 0,
                      costoReserva:
                          double.tryParse(costoController.text) ?? 0.0,
                      requiereAprobacion: requiereAprobacion,
                      activa: activa,
                    );
                  } else {
                    await _service.updateArea(
                      id: area.id,
                      nombre: nombreController.text,
                      descripcion: descripcionController.text,
                      capacidad: int.tryParse(capacidadController.text),
                      costoReserva: double.tryParse(costoController.text),
                      requiereAprobacion: requiereAprobacion,
                      activa: activa,
                    );
                  }
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: Text(area == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == true) _loadAreas();
  }

  Future<void> _deleteArea(AreaComun area) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          '¿Eliminar área ${area.nombre}?',
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
        await _service.deleteArea(area.id);
        _loadAreas();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Área eliminada')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _toggleActive(AreaComun area) async {
    try {
      await _service.toggleActiveArea(area.id);
      _loadAreas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Área ${area.activa ? "desactivada" : "activada"}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Áreas Comunes'),
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: () => _showAreaDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar áreas...',
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
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'Todas',
                        _selectedActiva == null,
                        () => setState(() => _selectedActiva = null),
                      ),
                      _buildFilterChip(
                        'Activas',
                        _selectedActiva == true,
                        () => setState(() => _selectedActiva = true),
                      ),
                      _buildFilterChip(
                        'Inactivas',
                        _selectedActiva == false,
                        () => setState(() => _selectedActiva = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAreas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.treeCity,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay áreas comunes'
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
                    onRefresh: _loadAreas,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredAreas.length,
                      itemBuilder: (context, index) {
                        final area = _filteredAreas[index];

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
                                color: Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                FontAwesomeIcons.treeCity,
                                color: area.activa
                                    ? const Color(0xFF10B981)
                                    : Colors.grey,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    area.nombre,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (!area.activa)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'INACTIVA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  area.descripcion,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildInfoChip(
                                      Icons.people,
                                      '${area.capacidad} pers.',
                                    ),
                                    _buildInfoChip(
                                      Icons.attach_money,
                                      '\$${area.costoReserva.toStringAsFixed(2)}',
                                    ),
                                    if (area.requiereAprobacion)
                                      _buildInfoChip(
                                        Icons.check_circle,
                                        'Requiere aprobación',
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
                                    () => _showAreaDialog(area),
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
                                    () => _toggleActive(area),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        area.activa
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppTheme.textSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        area.activa ? 'Desactivar' : 'Activar',
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: () => Future.delayed(
                                    Duration.zero,
                                    () => _deleteArea(area),
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
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: AppTheme.surface,
        selectedColor: const Color(0xFF10B981).withOpacity(0.3),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF10B981) : AppTheme.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? const Color(0xFF10B981) : AppTheme.border,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF10B981)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF10B981), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
