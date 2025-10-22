import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/app_theme.dart';
import '../../services/edificio_service.dart';
import '../../models/edificio_model.dart';
import '../../components/components.dart';

class HabitacionesScreen extends StatefulWidget {
  const HabitacionesScreen({super.key});

  @override
  State<HabitacionesScreen> createState() => _HabitacionesScreenState();
}

class _HabitacionesScreenState extends State<HabitacionesScreen> {
  final EdificioService _service = EdificioService();
  List<Habitacion> _habitaciones = [];
  List<Edificio> _edificios = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedEdificioId;
  String? _selectedEstado;

  final List<String> _estados = [
    'disponible',
    'ocupada',
    'mantenimiento',
    'reservada',
  ];
  final List<String> _tipos = ['estudio', 'apartamento', 'penthouse', 'duplex'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final habitaciones = await _service.getAllHabitaciones();
      final edificios = await _service.getAllEdificios();
      setState(() {
        _habitaciones = habitaciones;
        _edificios = edificios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  List<Habitacion> get _filteredHabitaciones {
    var filtered = _habitaciones;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (h) =>
                h.numero.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                h.tipo.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_selectedEdificioId != null) {
      filtered = filtered
          .where((h) => h.edificioId == _selectedEdificioId)
          .toList();
    }

    if (_selectedEstado != null) {
      filtered = filtered.where((h) => h.estado == _selectedEstado).toList();
    }

    return filtered;
  }

  Future<void> _showHabitacionDialog([Habitacion? habitacion]) async {
    final numeroController = TextEditingController(
      text: habitacion?.numero ?? '',
    );
    final areaController = TextEditingController(
      text: habitacion?.area.toString() ?? '0',
    );
    final habitacionesController = TextEditingController(
      text: habitacion?.habitaciones.toString() ?? '1',
    );
    final banosController = TextEditingController(
      text: habitacion?.banos.toString() ?? '1',
    );
    String selectedEdificio = habitacion?.edificioId ?? _edificios.first.id;
    String selectedEstado = habitacion?.estado ?? 'disponible';
    String selectedTipo = habitacion?.tipo ?? _tipos[0];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            habitacion == null ? 'Nueva Habitación' : 'Editar Habitación',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedEdificio,
                  dropdownColor: AppTheme.surface,
                  decoration: InputDecoration(
                    labelText: 'Edificio',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.secondary),
                    ),
                  ),
                  items: _edificios
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(
                            e.nombre,
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedEdificio = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: numeroController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Número',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTipo,
                  dropdownColor: AppTheme.surface,
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.secondary),
                    ),
                  ),
                  items: _tipos
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t.toUpperCase(),
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedTipo = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: areaController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Área (m²)',
                          labelStyle: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.secondary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: habitacionesController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Habitaciones',
                          labelStyle: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.secondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: banosController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Baños',
                          labelStyle: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.secondary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedEstado,
                        dropdownColor: AppTheme.surface,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          labelStyle: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.secondary),
                          ),
                        ),
                        items: _estados
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => selectedEstado = value!),
                      ),
                    ),
                  ],
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
                  if (habitacion == null) {
                    await _service.createHabitacion(
                      numero: numeroController.text,
                      tipo: selectedTipo,
                      area: double.tryParse(areaController.text) ?? 0,
                      habitaciones:
                          int.tryParse(habitacionesController.text) ?? 1,
                      banos: int.tryParse(banosController.text) ?? 1,
                      estado: selectedEstado,
                      edificioId: selectedEdificio,
                    );
                  } else {
                    await _service.updateHabitacion(
                      id: habitacion.id,
                      numero: numeroController.text,
                      tipo: selectedTipo,
                      area: double.tryParse(areaController.text),
                      habitaciones: int.tryParse(habitacionesController.text),
                      banos: int.tryParse(banosController.text),
                      estado: selectedEstado,
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
                backgroundColor: AppTheme.secondary,
              ),
              child: Text(habitacion == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == true) _loadData();
  }

  Future<void> _deleteHabitacion(Habitacion habitacion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          '¿Eliminar habitación ${habitacion.numero}?',
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
        await _service.deleteHabitacion(habitacion.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Habitación eliminada')));
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

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'disponible':
        return Colors.green;
      case 'ocupada':
        return Colors.orange;
      case 'mantenimiento':
        return Colors.red;
      case 'reservada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Habitaciones'),
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: _edificios.isEmpty
                ? null
                : () => _showHabitacionDialog(),
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
                    hintText: 'Buscar habitaciones...',
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
                        'Todos los edificios',
                        _selectedEdificioId == null,
                        () => setState(() => _selectedEdificioId = null),
                      ),
                      ..._edificios.map(
                        (e) => _buildFilterChip(
                          e.nombre,
                          _selectedEdificioId == e.id,
                          () => setState(() => _selectedEdificioId = e.id),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildFilterChip(
                        'Todos los estados',
                        _selectedEstado == null,
                        () => setState(() => _selectedEstado = null),
                      ),
                      ..._estados.map(
                        (e) => _buildFilterChip(
                          e.toUpperCase(),
                          _selectedEstado == e,
                          () => setState(() => _selectedEstado = e),
                        ),
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
                : _filteredHabitaciones.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.doorOpen,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay habitaciones'
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
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredHabitaciones.length,
                      itemBuilder: (context, index) {
                        final habitacion = _filteredHabitaciones[index];
                        final edificio = _edificios.firstWhere(
                          (e) => e.id == habitacion.edificioId,
                          orElse: () => _edificios.first,
                        );

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
                                color: AppTheme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.doorOpen,
                                color: AppTheme.secondary,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  'Hab. ${habitacion.numero}',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getEstadoColor(habitacion.estado),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    habitacion.estado.toUpperCase(),
                                    style: const TextStyle(
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
                                  edificio.nombre,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildInfoChip(
                                      Icons.straighten,
                                      '${habitacion.area}m²',
                                    ),
                                    _buildInfoChip(
                                      Icons.bed,
                                      '${habitacion.habitaciones} hab',
                                    ),
                                    _buildInfoChip(
                                      Icons.bathtub,
                                      '${habitacion.banos} baños',
                                    ),
                                    _buildInfoChip(
                                      Icons.category,
                                      habitacion.tipo,
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
                                    () => _showHabitacionDialog(habitacion),
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
                                    () => _deleteHabitacion(habitacion),
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
        selectedColor: AppTheme.secondary.withOpacity(0.3),
        labelStyle: TextStyle(
          color: selected ? AppTheme.secondary : AppTheme.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? AppTheme.secondary : AppTheme.border,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.secondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
