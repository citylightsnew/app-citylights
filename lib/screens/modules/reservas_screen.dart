import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/booking_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking_model.dart';
import '../../components/components.dart';
import 'package:intl/intl.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  final BookingService _service = BookingService();
  List<Reserva> _reservas = [];
  List<AreaComun> _areas = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedEstado;

  final List<String> _estados = [
    'pendiente',
    'confirmada',
    'cancelada',
    'completada',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reservas = await _service.getAllReservas();
      final areas = await _service.getAllAreas();
      setState(() {
        _reservas = reservas;
        _areas = areas;
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

  List<Reserva> get _filteredReservas {
    var filtered = _reservas;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final area = r.area?.nombre ?? '';
        return area.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedEstado != null) {
      filtered = filtered.where((r) => r.estado == _selectedEstado).toList();
    }

    return filtered;
  }

  Future<void> _showReservaDialog([Reserva? reserva]) async {
    final authService = Provider.of<AuthProvider>(context, listen: false);
    final usuarioId = authService.user?.id ?? '';

    int? selectedAreaId =
        reserva?.areaId ?? (_areas.isNotEmpty ? _areas.first.id : null);
    DateTime selectedFechaInicio = reserva?.fechaInicio ?? DateTime.now();
    DateTime selectedFechaFin =
        reserva?.fechaFin ?? DateTime.now().add(const Duration(hours: 2));
    final notasController = TextEditingController(text: reserva?.notas ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            reserva == null ? 'Nueva Reserva' : 'Editar Reserva',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedAreaId,
                  dropdownColor: AppTheme.surface,
                  decoration: InputDecoration(
                    labelText: 'Área Común',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                  items: _areas
                      .where((a) => a.activa)
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(
                            a.nombre,
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: reserva == null
                      ? (value) => setDialogState(() => selectedAreaId = value)
                      : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text(
                    'Fecha Inicio',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(selectedFechaInicio),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF8B5CF6),
                  ),
                  onTap: reserva == null
                      ? () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedFechaInicio,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                selectedFechaInicio,
                              ),
                            );
                            if (time != null) {
                              setDialogState(() {
                                selectedFechaInicio = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text(
                    'Fecha Fin',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(selectedFechaFin),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF8B5CF6),
                  ),
                  onTap: reserva == null
                      ? () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedFechaFin,
                            firstDate: selectedFechaInicio,
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                selectedFechaFin,
                              ),
                            );
                            if (time != null) {
                              setDialogState(() {
                                selectedFechaFin = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        }
                      : null,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notasController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notas (opcional)',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF8B5CF6)),
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
                try {
                  if (selectedAreaId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Seleccione un área común')),
                    );
                    return;
                  }

                  if (reserva == null) {
                    await _service.createReserva(
                      usuarioId: usuarioId,
                      areaId: selectedAreaId!,
                      fechaInicio: selectedFechaInicio,
                      fechaFin: selectedFechaFin,
                      notas: notasController.text.isEmpty
                          ? null
                          : notasController.text,
                    );
                  } else {
                    await _service.updateReserva(
                      id: reserva.id,
                      fechaInicio: selectedFechaInicio,
                      fechaFin: selectedFechaFin,
                      notas: notasController.text.isEmpty
                          ? null
                          : notasController.text,
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
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: Text(reserva == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == true) _loadData();
  }

  Future<void> _confirmarReserva(Reserva reserva) async {
    try {
      await _service.confirmReserva(reserva.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reserva confirmada')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    final motivoController = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Cancelar Reserva',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Está seguro que desea cancelar esta reserva?',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              style: const TextStyle(color: AppTheme.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Motivo de cancelación',
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, motivoController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (motivo != null) {
      try {
        await _service.cancelReserva(
          reserva.id,
          motivo: motivo.isEmpty ? null : motivo,
        );
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Reserva cancelada')));
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

  Future<void> _completarReserva(Reserva reserva) async {
    try {
      await _service.completeReserva(reserva.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reserva completada')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      case 'completada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Reservas'),
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus),
            onPressed: _areas.isEmpty ? null : () => _showReservaDialog(),
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
                    hintText: 'Buscar por área...',
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
                : _filteredReservas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.calendarCheck,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No hay reservas'
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
                      itemCount: _filteredReservas.length,
                      itemBuilder: (context, index) {
                        final reserva = _filteredReservas[index];
                        final area = reserva.area;

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
                                color: Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.calendarCheck,
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    area?.nombre ?? 'Área desconocida',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getEstadoColor(reserva.estado),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    reserva.estado.toUpperCase(),
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(reserva.fechaInicio),
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_forward,
                                      size: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(reserva.fechaFin),
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                if (reserva.notas != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    reserva.notas!,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppTheme.textSecondary,
                              ),
                              color: AppTheme.surface,
                              itemBuilder: (context) => [
                                if (reserva.estado == 'pendiente')
                                  PopupMenuItem(
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                      () => _confirmarReserva(reserva),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Confirmar',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (reserva.estado == 'pendiente' ||
                                    reserva.estado == 'confirmada')
                                  PopupMenuItem(
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                      () => _showReservaDialog(reserva),
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
                                if (reserva.estado == 'confirmada')
                                  PopupMenuItem(
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                      () => _completarReserva(reserva),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.done_all,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Completar',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (reserva.estado != 'cancelada' &&
                                    reserva.estado != 'completada')
                                  PopupMenuItem(
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                      () => _cancelarReserva(reserva),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Cancelar',
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
        selectedColor: const Color(0xFF8B5CF6).withOpacity(0.3),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF8B5CF6) : AppTheme.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? const Color(0xFF8B5CF6) : AppTheme.border,
        ),
      ),
    );
  }
}
