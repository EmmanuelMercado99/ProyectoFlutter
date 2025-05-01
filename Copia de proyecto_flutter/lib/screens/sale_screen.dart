import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/branch.dart';
import '../models/customer.dart';
import '../services/database_service.dart';
// import 'new_sale_screen.dart';
import 'sale_detail_screen.dart';

/// Pantalla que muestra el listado de ventas realizadas en el sistema.
/// Permite visualizar todas las ventas con sus detalles básicos y
/// acceder a la información detallada de cada venta.
class SaleScreen extends StatefulWidget {
  /// Constructor por defecto que inicializa la pantalla de ventas
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  /// Servicio de base de datos para consultas
  final DatabaseService _databaseService = DatabaseService();
  
  /// Lista de todas las ventas registradas
  List<Sale> _sales = [];
  
  /// Lista de sucursales para relacionar con las ventas
  List<Branch> _branches = [];
  
  /// Lista de clientes para relacionar con las ventas
  List<Customer> _customers = [];
  
  /// Indicador de estado de carga
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carga todos los datos necesarios para mostrar las ventas
  /// Incluye ventas, sucursales y clientes relacionados
  Future<void> _loadData() async {
    try {
      final sales = await _databaseService.getSales();
      final branches = await _databaseService.getBranches();
      final customers = await _databaseService.getCustomers();

      if (mounted) {
        setState(() {
          _sales = sales;
          _branches = branches;
          _customers = customers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text('Ventas'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sales.isEmpty
              ? const Center(child: Text('No hay ventas registradas'))
              : ListView.builder(
                  itemCount: _sales.length,
                  itemBuilder: (context, index) {
                    final sale = _sales[index];
                    final branch = _branches.firstWhere(
                      (b) => b.id == sale.branchId,
                      orElse: () =>
                          Branch(id: -1, name: 'Desconocida', location: ''),
                    );
                    final customer = sale.customerId != null
                        ? _customers.firstWhere(
                            (c) => c.id == sale.customerId,
                            orElse: () => Customer(
                                id: -1,
                                name: 'Cliente no registrado',
                                email: ''),
                          )
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text('Venta #${sale.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sucursal: ${branch.name}'),
                            Text(
                                'Cliente: ${customer?.name ?? 'Venta al público'}'),
                            Text(
                                'Fecha: ${sale.date.toString().split('.')[0]}'),
                            Text('Total: \$${sale.total.toStringAsFixed(2)}'),
                            Text('Método de pago: ${sale.paymentMethod}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SaleDetailScreen(
                                      sale: sale,
                                      branch: branch,
                                      customer: customer,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
