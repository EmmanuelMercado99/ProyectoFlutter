import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/sale_detail.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/branch.dart';
import '../services/database_service.dart';

// Widget para crear una nueva venta.
class SaleDialog extends StatefulWidget {
  final List<Branch> branches;
  final List<Customer> customers;

  const SaleDialog({
    super.key,
    required this.branches,
    required this.customers,
  });

  @override
  State<SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<SaleDialog> {
  final DatabaseService _databaseService = DatabaseService();

  Branch? _selectedBranch; // Sucursal seleccionada
  Customer? _selectedCustomer; // Cliente seleccionado
  String _selectedPaymentMethod = 'Efectivo'; // Método de pago por defecto
  List<Product> _availableProducts =
      []; // Productos disponibles para la sucursal seleccionada
  List<Map<String, dynamic>> _saleDetails =
      []; // Detalles de los productos agregados a la venta
  double _total = 0.0; // Total de la venta

  @override
  void initState() {
    super.initState();
    if (widget.branches.isNotEmpty) {
      _selectedBranch = widget.branches.first; // Selecciona la primera sucursal
      _loadProducts(); // Carga los productos para la sucursal
    }
  }

  // Carga productos disponibles según la sucursal seleccionada
  Future<void> _loadProducts() async {
    if (_selectedBranch != null) {
      final products =
          await _databaseService.getProductsByBranch(_selectedBranch!.id);
      setState(() {
        _availableProducts = products;
      });
    }
  }

  // Calcula el total de la venta basado en los detalles agregados
  void _updateTotal() {
    setState(() {
      _total = _saleDetails.fold(
        0.0,
        (sum, detail) => sum + (detail['quantity'] * detail['unitPrice']),
      );
    });
  }

  // Muestra un diálogo para agregar un producto a la venta
  Future<void> _addProduct() async {
    Product? selectedProduct;
    int quantity = 1;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Producto'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selector de producto
                DropdownButtonFormField<Product>(
                  decoration: const InputDecoration(labelText: 'Producto'),
                  items: _availableProducts.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text('${product.name} - \$${product.price}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedProduct = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Campo para la cantidad
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  onChanged: (value) {
                    quantity = int.tryParse(value) ?? 1;
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (selectedProduct != null && quantity > 0) {
                Navigator.pop(context, {
                  'product': selectedProduct,
                  'quantity': quantity,
                });
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    // Si se retorna un producto válido, agrégalo a los detalles de la venta
    if (result != null) {
      final product = result['product'] as Product;
      final quantity = result['quantity'] as int;

      setState(() {
        _saleDetails.add({
          'productId': product.id,
          'quantity': quantity,
          'unitPrice': product.price,
          'product': product, // Se guarda para mostrar en el resumen
        });
        _updateTotal(); // Actualiza el total
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Venta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selector de sucursal
            DropdownButtonFormField<Branch>(
              value: _selectedBranch,
              decoration: const InputDecoration(
                labelText: 'Sucursal',
                border: OutlineInputBorder(),
              ),
              items: widget.branches.map((branch) {
                return DropdownMenuItem(
                  value: branch,
                  child: Text(branch.name),
                );
              }).toList(),
              onChanged: (Branch? value) {
                setState(() {
                  _selectedBranch = value;
                  _loadProducts(); // Carga productos al cambiar de sucursal
                });
              },
            ),
            const SizedBox(height: 16),
            // Selector de cliente (puede ser null para "Venta al público")
            DropdownButtonFormField<Customer?>(
              value: _selectedCustomer,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Venta al público'),
                ),
                ...widget.customers.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer.name),
                  );
                }),
              ],
              onChanged: (Customer? value) {
                setState(() {
                  _selectedCustomer = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Selector de método de pago
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Método de Pago',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Agregar Producto'),
            ),
            const SizedBox(height: 16),

            // Lista de productos agregados
            if (_saleDetails.isNotEmpty) ...[
              const Text(
                'Productos seleccionados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _saleDetails.length,
                  itemBuilder: (context, index) {
                    final detail = _saleDetails[index];
                    final product = detail['product'] as Product;
                    final quantity = detail['quantity'] as int;
                    final unitPrice = detail['unitPrice'] as double;
                    final subtotal = quantity * unitPrice;

                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        'Cantidad: $quantity - Subtotal: \$${subtotal.toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _saleDetails.removeAt(index);
                            _updateTotal(); // Recalcula el total
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Total: \$${_total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _saleDetails.isEmpty || _selectedBranch == null
              ? null
              : () {
                  // Crea el objeto de venta
                  final sale = Sale(
                    id: DateTime.now().millisecondsSinceEpoch,
                    branchId: _selectedBranch!.id,
                    customerId: _selectedCustomer?.id,
                    date: DateTime.now(),
                    paymentMethod: _selectedPaymentMethod,
                    total: _total,
                  );

                  // Crea los detalles de la venta
                  final saleDetails = _saleDetails.map((detail) {
                    return SaleDetail(
                      id: DateTime.now().millisecondsSinceEpoch +
                          (detail['productId'] as int),
                      saleId: sale.id,
                      productId: detail['productId'],
                      quantity: detail['quantity'],
                      unitPrice: detail['unitPrice'],
                    );
                  }).toList();

                  // Retorna los datos al cerrar el diálogo
                  Navigator.pop(context, {
                    'sale': sale,
                    'details': saleDetails,
                  });
                },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
