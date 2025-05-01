import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_detail.dart';
import '../services/database_service.dart';
import '../widgets/payment_success_animation.dart';

/// Pantalla que gestiona la creación de nuevas ventas en el sistema.
/// Permite seleccionar productos, cliente, método de pago y procesar la venta
/// actualizando el inventario automáticamente.
class NewSaleScreen extends StatefulWidget {
  /// Constructor por defecto que inicializa la pantalla de nueva venta
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  /// Servicio de base de datos para operaciones CRUD
  final DatabaseService _databaseService = DatabaseService();
  
  /// Lista de sucursales disponibles
  List<Branch> _branches = [];
  
  /// Lista de clientes registrados
  List<Customer> _customers = [];
  
  /// Lista de productos disponibles en la sucursal seleccionada
  List<Product> _availableProducts = [];
  
  /// Lista de detalles de la venta actual
  final List<Map<String, dynamic>> _saleDetails = [];
  
  /// Sucursal seleccionada para la venta
  Branch? _selectedBranch;
  
  /// Cliente seleccionado (opcional)
  Customer? _selectedCustomer;
  
  /// Método de pago seleccionado
  String _selectedPaymentMethod = 'Efectivo';
  
  /// Total acumulado de la venta
  double _total = 0.0;
  
  /// Indicador de estado de carga
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Carga los datos iniciales necesarios para la venta
  /// Incluye sucursales, clientes y productos de la primera sucursal
  Future<void> _loadInitialData() async {
    try {
      final branches = await _databaseService.getBranches();
      final customers = await _databaseService.getCustomers();

      setState(() {
        _branches = branches;
        _customers = customers;
        if (branches.isNotEmpty) {
          _selectedBranch = branches.first;
          _loadProducts();
        }
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

  /// Carga los productos disponibles en la sucursal seleccionada
  Future<void> _loadProducts() async {
    if (_selectedBranch != null) {
      setState(() => _isLoading = true);
      try {
        final products =
            await _databaseService.getProductsByBranch(_selectedBranch!.id);
        setState(() {
          _availableProducts = products;
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
  }

  /// Actualiza el total de la venta basado en los productos seleccionados
  void _updateTotal() {
    setState(() {
      _total = _saleDetails.fold(
        0.0,
        (sum, detail) => sum + (detail['quantity'] * detail['unitPrice']),
      );
    });
  }

  /// Muestra el diálogo para agregar un nuevo producto a la venta
  /// Incluye validaciones de stock y cantidad
  Future<void> _showAddProductDialog() async {
    Product? selectedProduct;
    int quantity = 1;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Producto'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Product>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Producto',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableProducts.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Text(
                          '${product.name} - \$${product.price} (Stock: ${product.stock})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProduct = value;
                        quantity = 1; // Resetear cantidad al cambiar producto
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      border: const OutlineInputBorder(),
                      helperText: selectedProduct != null
                          ? 'Stock disponible: ${selectedProduct!.stock}'
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    onChanged: (value) {
                      final newQuantity = int.tryParse(value) ?? 0;
                      if (selectedProduct != null &&
                          newQuantity > selectedProduct!.stock) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'La cantidad no puede exceder el stock disponible'),
                          ),
                        );
                        setState(() {
                          quantity = selectedProduct!.stock;
                        });
                      } else {
                        setState(() {
                          quantity = newQuantity;
                        });
                      }
                    },
                  ),
                ],
              ),
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
              if (selectedProduct != null &&
                  quantity > 0 &&
                  quantity <= selectedProduct!.stock) {
                setState(() {
                  _saleDetails.add({
                    'productId': selectedProduct!.id,
                    'quantity': quantity,
                    'unitPrice': selectedProduct!.price,
                    'product': selectedProduct,
                  });
                  _updateTotal();
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor verifica la cantidad'),
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /// Procesa y guarda la venta en la base de datos
  /// Actualiza el inventario y muestra animación de éxito
  Future<void> _saveSale() async {
    if (_selectedBranch == null || _saleDetails.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // Generamos un ID más corto usando solo los últimos 8 dígitos
      final saleId = DateTime.now().millisecondsSinceEpoch % 100000000;

      final sale = Sale(
        id: saleId,
        branchId: _selectedBranch!.id,
        customerId: _selectedCustomer?.id,
        date: DateTime.now(),
        paymentMethod: _selectedPaymentMethod,
        total: _total,
      );

      await _databaseService.insertSale(sale);

      for (var detail in _saleDetails) {
        // Generamos un ID único para cada detalle usando una combinación más corta
        final detailId = int.parse('${saleId % 10000}${detail['productId']}');

        final saleDetail = SaleDetail(
          id: detailId,
          saleId: sale.id,
          productId: detail['productId'],
          quantity: detail['quantity'],
          unitPrice: detail['unitPrice'],
        );
        await _databaseService.insertSaleDetail(saleDetail);

        // Actualizar el inventario
        final product = detail['product'] as Product;
        final updatedProduct = Product(
          id: product.id,
          name: product.name,
          price: product.price,
          stock: product.stock - detail['quantity'] as int,
          branchId: product.branchId,
        );
        await _databaseService.updateProduct(updatedProduct);
      }

      if (mounted) {
        // Mostrar animación de pago exitoso
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PaymentSuccessAnimation(
            paymentMethod: _selectedPaymentMethod,
            onAnimationComplete: () {
              Navigator.of(context).pop();
              Navigator.pop(context, true);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la venta: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        actions: [
          if (_saleDetails.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSale,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selección de Sucursal
                  DropdownButtonFormField<Branch>(
                    value: _selectedBranch,
                    decoration: const InputDecoration(
                      labelText: 'Sucursal',
                      border: OutlineInputBorder(),
                    ),
                    items: _branches.map((branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child: Text(branch.name),
                      );
                    }).toList(),
                    onChanged: (Branch? value) {
                      setState(() {
                        _selectedBranch = value;
                        _loadProducts();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Selección de Cliente
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
                      ..._customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer,
                          child: Text(customer.name),
                        );
                      }),
                    ],
                    onChanged: (Customer? value) {
                      setState(() => _selectedCustomer = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Método de Pago
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Método de Pago',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Efectivo', child: Text('Efectivo')),
                      DropdownMenuItem(
                          value: 'Tarjeta', child: Text('Tarjeta')),
                      DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => _selectedPaymentMethod = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Lista de Productos
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Productos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _showAddProductDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar'),
                              ),
                            ],
                          ),
                          if (_saleDetails.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _saleDetails.length,
                              itemBuilder: (context, index) {
                                final detail = _saleDetails[index];
                                final product = detail['product'] as Product;
                                final quantity = detail['quantity'] as int;
                                final unitPrice = detail['unitPrice'] as double;
                                final subtotal = quantity * unitPrice;

                                return Card(
                                  child: ListTile(
                                    title: Text(product.name),
                                    subtitle: Text(
                                      'Cantidad: $quantity - Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          _saleDetails.removeAt(index);
                                          _updateTotal();
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Total: \$${_total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.end,
                            ),
                          ],
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
