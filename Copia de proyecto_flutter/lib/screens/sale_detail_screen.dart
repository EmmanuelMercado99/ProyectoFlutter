import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/branch.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../services/database_service.dart';

/// Pantalla que muestra los detalles completos de una venta específica.
/// Incluye información general de la venta y una lista detallada de los productos vendidos.
class SaleDetailScreen extends StatefulWidget {
  /// Venta de la cual se mostrarán los detalles
  final Sale sale;
  
  /// Sucursal donde se realizó la venta
  final Branch branch;
  
  /// Cliente asociado a la venta (opcional)
  final Customer? customer;

  /// Constructor que inicializa la pantalla de detalles de venta
  /// Requiere una venta y sucursal, el cliente es opcional
  const SaleDetailScreen({
    super.key,
    required this.sale,
    required this.branch,
    this.customer,
  });

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  /// Servicio de base de datos para consultas
  final DatabaseService _databaseService = DatabaseService();
  
  /// Lista de detalles de la venta con información de productos
  List<Map<String, dynamic>> _saleDetails = [];
  
  /// Indicador de estado de carga
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaleDetails();
  }

  /// Carga los detalles de la venta y los productos asociados
  /// Combina la información para mostrar detalles completos
  Future<void> _loadSaleDetails() async {
    try {
      final details = await _databaseService.getSaleDetails(widget.sale.id);
      final products = await _databaseService.getProducts();
      
      final detailsWithProducts = details.map((detail) {
        final product = products.firstWhere(
          (p) => p.id == detail.productId,
          orElse: () => Product(
            id: -1,
            name: 'Producto no encontrado',
            price: 0,
            stock: 0,
            branchId: widget.branch.id,
          ),
        );
        return {
          'detail': detail,
          'product': product,
        };
      }).toList();

      setState(() {
        _saleDetails = detailsWithProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar detalles: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Venta #${widget.sale.id}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información General',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text('Sucursal: ${widget.branch.name}'),
                          Text(
                            'Cliente: ${widget.customer?.name ?? 'Venta al público'}',
                          ),
                          Text(
                            'Fecha: ${widget.sale.date.toString().split('.')[0]}',
                          ),
                          Text('Método de pago: ${widget.sale.paymentMethod}'),
                          Text(
                            'Total: \$${widget.sale.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Productos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _saleDetails.length,
                    itemBuilder: (context, index) {
                      final detail = _saleDetails[index]['detail'];
                      final product = _saleDetails[index]['product'];
                      return Card(
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cantidad: ${detail.quantity}'),
                              Text(
                                'Precio unitario: \$${detail.unitPrice.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Subtotal: \$${(detail.quantity * detail.unitPrice).toStringAsFixed(2)}',
                              ),
                            ],
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