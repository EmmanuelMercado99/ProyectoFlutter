import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/branch.dart';
import '../services/database_service.dart';

/// Pantalla que muestra reportes detallados de ventas con estadísticas.
/// Permite filtrar ventas por sucursal y rango de fechas, y muestra
/// métricas importantes como totales, promedios y métodos de pago.
class SalesReportScreen extends StatefulWidget {
  /// Sucursal seleccionada para filtrar el reporte (opcional)
  final Branch? selectedBranch;
  
  /// Rango de fechas para el período del reporte
  final DateTimeRange selectedDateRange;

  /// Constructor que inicializa la pantalla de reporte de ventas
  /// Requiere un rango de fechas, la sucursal es opcional
  const SalesReportScreen({
    super.key,
    this.selectedBranch,
    required this.selectedDateRange,
  });

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  /// Servicio de base de datos para consultas
  final DatabaseService _databaseService = DatabaseService();
  
  /// Indicador de estado de carga
  bool _isLoading = true;
  
  /// Lista de ventas filtradas por período y sucursal
  List<Sale> _sales = [];
  
  /// Total acumulado de todas las ventas
  double _totalVentas = 0;
  
  /// Ventas agrupadas por método de pago
  Map<String, double> _ventasPorMetodo = {};
  
  /// Promedio de ventas por día en el período
  double _promedioVentaDiaria = 0;
  
  /// Valor de la venta más alta en el período
  double _ventaMasAlta = 0;
  
  /// Método de pago más utilizado en el período
  String _metodoPagoMasUsado = '';

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  /// Carga y procesa los datos de ventas para el reporte
  /// Calcula estadísticas y métricas importantes del período seleccionado
  Future<void> _loadSalesData() async {
    setState(() => _isLoading = true);
    try {
      final sales = await _databaseService.getSales();

      // Filtrar ventas por fecha y sucursal
      final filteredSales = sales.where((sale) {
        final isInDateRange =
            sale.date.isAfter(widget.selectedDateRange.start) &&
            sale.date.isBefore(
                widget.selectedDateRange.end.add(const Duration(days: 1)));

        final isInBranch = widget.selectedBranch == null ||
            sale.branchId == widget.selectedBranch!.id;

        return isInDateRange && isInBranch;
      }).toList();

      // Calcular totales
      double total = 0;
      Map<String, double> porMetodo = {};

      for (var sale in filteredSales) {
        total += sale.total;
        porMetodo[sale.paymentMethod] =
            (porMetodo[sale.paymentMethod] ?? 0) + sale.total;
      }

      // Calcular estadísticas adicionales
      if (filteredSales.isNotEmpty) {
        // Calcular promedio diario
        final days = widget.selectedDateRange.end
                .difference(widget.selectedDateRange.start)
                .inDays +
            1;
        _promedioVentaDiaria = total / days;

        // Encontrar la venta más alta
        _ventaMasAlta =
            filteredSales.map((s) => s.total).reduce((a, b) => a > b ? a : b);

        // Encontrar el método de pago más usado
        final metodosCount = <String, int>{};
        for (var sale in filteredSales) {
          metodosCount[sale.paymentMethod] =
              (metodosCount[sale.paymentMethod] ?? 0) + 1;
        }
        _metodoPagoMasUsado = metodosCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      setState(() {
        _sales = filteredSales;
        _totalVentas = total;
        _ventasPorMetodo = porMetodo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ventas'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Resumen
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen de Ventas',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Período: ${widget.selectedDateRange.start.toString().split(' ')[0]} - ${widget.selectedDateRange.end.toString().split(' ')[0]}',
                          ),
                          if (widget.selectedBranch != null)
                            Text('Sucursal: ${widget.selectedBranch!.name}'),
                          const SizedBox(height: 8),
                          Text(
                            'Total de ventas: \$${_totalVentas.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text('Número de ventas: ${_sales.length}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Ventas por método de pago
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ventas por Método de Pago',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ..._ventasPorMetodo.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(
                                    '\$${entry.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lista de ventas
                  Text(
                    'Detalle de Ventas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sales.length,
                    itemBuilder: (context, index) {
                      final sale = _sales[index];
                      return Card(
                        child: ListTile(
                          title: Text('Venta #${sale.id}'),
                          subtitle: Text(
                            'Fecha: ${sale.date.toString().split('.')[0]}\n'
                            'Método: ${sale.paymentMethod}',
                          ),
                          trailing: Text(
                            '\$${sale.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Agregar nueva tarjeta de estadísticas
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estadísticas Adicionales',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Promedio de ventas diarias: \$${_promedioVentaDiaria.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Venta más alta: \$${_ventaMasAlta.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Método de pago más utilizado: $_metodoPagoMasUsado',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
