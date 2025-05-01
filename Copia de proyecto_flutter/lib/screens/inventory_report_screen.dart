import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../models/product.dart';
import '../services/database_service.dart';

/// Pantalla que muestra el reporte de inventario del sistema.
/// Permite visualizar los productos y su información detallada,
/// con la opción de filtrar por sucursal específica.
class InventoryReportScreen extends StatefulWidget {
  /// Sucursal seleccionada para filtrar el reporte
  /// Si es null, muestra productos de todas las sucursales
  final Branch? selectedBranch;

  /// Constructor que inicializa la pantalla de reporte
  /// [selectedBranch] es opcional y determina el filtro de sucursal
  const InventoryReportScreen({
    super.key,
    this.selectedBranch,
  });

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  /// Servicio de base de datos para operaciones de consulta
  final DatabaseService _databaseService = DatabaseService();
  
  /// Indicador de estado de carga de datos
  bool _isLoading = true;
  
  /// Lista de productos a mostrar en el reporte
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Carga los productos desde la base de datos
  /// Si hay una sucursal seleccionada, filtra los productos por esa sucursal
  /// Maneja errores mostrando un SnackBar con el mensaje correspondiente
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = widget.selectedBranch != null
          ? await _databaseService
              .getProductsByBranch(widget.selectedBranch!.id)
          : await _databaseService.getProducts();

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Inventario'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Muestra el nombre de la sucursal si está filtrado
                  if (widget.selectedBranch != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Sucursal: ${widget.selectedBranch!.name}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inventario',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return ListTile(
                                title: Text(product.name),
                                subtitle: Text('Precio: \$${product.price.toStringAsFixed(2)}'),
                              );
                            },
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
