import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/branch.dart';
import 'sales_report_screen.dart';

/// Pantalla que gestiona la generación y visualización de reportes del sistema.
/// Permite filtrar reportes por sucursal y rango de fechas, y navegar a
/// diferentes tipos de reportes disponibles.
class ReportScreen extends StatefulWidget {
  /// Constructor por defecto que inicializa la pantalla de reportes
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  /// Servicio de base de datos para consultas
  final DatabaseService _databaseService = DatabaseService();
  
  /// Indicador de estado de carga
  bool _isLoading = false;
  
  /// Sucursal seleccionada para filtrar reportes
  Branch? _selectedBranch;
  
  /// Lista de sucursales disponibles
  List<Branch> _branches = [];
  
  /// Rango de fechas seleccionado para los reportes
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  /// Carga las sucursales disponibles desde la base de datos
  /// Maneja errores mostrando mensajes al usuario
  Future<void> _loadBranches() async {
    setState(() => _isLoading = true);
    try {
      final branches = await _databaseService.getBranches();
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar sucursales: $e')),
        );
      }
    }
  }

  /// Muestra un selector de rango de fechas y actualiza el estado
  /// El rango por defecto es la última semana
  Future<void> _selectDateRange() async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );

    if (dateRange != null) {
      setState(() => _selectedDateRange = dateRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filtros
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filtros',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Branch>(
                            decoration: const InputDecoration(
                              labelText: 'Sucursal',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedBranch,
                            items: [
                              const DropdownMenuItem<Branch>(
                                value: null,
                                child: Text('Todas las sucursales'),
                              ),
                              ..._branches.map((branch) {
                                return DropdownMenuItem(
                                  value: branch,
                                  child: Text(branch.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (Branch? value) {
                              setState(() => _selectedBranch = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _selectDateRange,
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              _selectedDateRange != null
                                  ? '${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}'
                                  : 'Seleccionar rango de fechas',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tipos de Reportes
                  Text(
                    'Tipos de Reportes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _ReportCard(
                    title: 'Ventas por Período',
                    icon: Icons.bar_chart,
                    onTap: () {
                      if (_selectedDateRange == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Por favor selecciona un rango de fechas'),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SalesReportScreen(
                            selectedBranch: _selectedBranch,
                            selectedDateRange: _selectedDateRange!,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

/// Widget privado que representa una tarjeta de tipo de reporte
/// Utilizado para mostrar las diferentes opciones de reportes disponibles
class _ReportCard extends StatelessWidget {
  /// Título del reporte
  final String title;
  
  /// Ícono que representa visualmente el tipo de reporte
  final IconData icon;
  
  /// Función que se ejecuta al seleccionar el reporte
  final VoidCallback onTap;

  /// Constructor que inicializa una nueva tarjeta de reporte
  const _ReportCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
