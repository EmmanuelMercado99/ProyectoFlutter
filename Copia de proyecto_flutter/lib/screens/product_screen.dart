import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/branch.dart';
import '../services/database_service.dart';
import '../widgets/product_dialog.dart';
import '../widgets/confirm_delete_dialog.dart';

/// Pantalla que gestiona el catálogo de productos del sistema.
/// Permite crear, editar, eliminar y filtrar productos por nombre y sucursal.
/// Incluye validaciones de stock y muestra alertas visuales para niveles bajos de inventario.
class ProductScreen extends StatefulWidget {
  /// Constructor por defecto que inicializa la pantalla de productos
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  /// Servicio de base de datos para operaciones CRUD
  final DatabaseService _databaseService = DatabaseService();
  
  /// Lista completa de productos en el sistema
  List<Product> _products = [];
  
  /// Lista filtrada de productos basada en búsqueda y filtros
  List<Product> _filteredProducts = [];
  
  /// Lista de sucursales disponibles
  List<Branch> _branches = [];
  
  /// Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();
  
  /// Sucursal seleccionada para filtrar productos
  Branch? _selectedBranch;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga los datos iniciales de productos y sucursales
  /// Maneja errores mostrando mensajes al usuario
  Future<void> _loadData() async {
    try {
      final branches = await _databaseService.getBranches();
      final products = await _databaseService.getProducts();
      
      if (mounted) {
        setState(() {
          _branches = branches;
          _products = products;
          _filteredProducts = products;
          // Si hay un branch seleccionado pero ya no existe, resetearlo
          if (_selectedBranch != null && 
              !branches.any((b) => b.id == _selectedBranch!.id)) {
            _selectedBranch = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  /// Maneja la creación de un nuevo producto
  /// Verifica la existencia de sucursales antes de permitir la creación
  Future<void> _addProduct() async {
    final branches = await _databaseService.getBranches();
    if (branches.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe crear al menos una sucursal')),
        );
      }
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProductDialog(branches: branches),
    );

    if (result != null) {
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch,
        name: result['name'],
        price: result['price'],
        stock: result['stock'],
        branchId: result['branchId'],
      );

      await _databaseService.insertProduct(product);
      _loadData();
    }
  }

  /// Filtra los productos basado en el texto de búsqueda y sucursal seleccionada
  /// Actualiza la lista filtrada en tiempo real
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesQuery = product.name.toLowerCase().contains(query);
        final matchesBranch = _selectedBranch == null || 
                            product.branchId == _selectedBranch!.id;
        return matchesQuery && matchesBranch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto',
                      hintText: 'Ingrese el nombre del producto',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<Branch?>(
                    value: _selectedBranch,
                    underline: Container(), // Remove the default underline
                    hint: const Text('Todas las sucursales'),
                    items: [
                      const DropdownMenuItem<Branch?>(
                        value: null,
                        child: Text('Todas las sucursales'),
                      ),
                      ..._branches.map((Branch branch) {
                        return DropdownMenuItem<Branch?>(
                          value: branch,
                          child: Text(branch.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (Branch? newValue) {
                      setState(() {
                        _selectedBranch = newValue;
                        _filterProducts();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final branch = _branches.firstWhere(
                  (b) => b.id == product.branchId,
                  orElse: () => Branch(id: -1, name: 'Sucursal no encontrada'),
                );
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Precio: \$${product.price.toStringAsFixed(2)}'),
                        Text('Stock: ${product.stock}', 
                          style: TextStyle(
                            color: product.stock < 10 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold
                          )
                        ),
                        Text('Sucursal: ${branch.name}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editProduct(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _deleteProduct(product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _editProduct(Product product) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProductDialog(
        product: product,
        branches: _branches,
      ),
    );

    if (result != null) {
      final updatedProduct = Product(
        id: product.id,
        name: result['name'],
        price: result['price'],
        stock: result['stock'],
        branchId: result['branchId'],
      );

      await _databaseService.updateProduct(updatedProduct);
      _loadData();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        itemName: product.name,
        itemType: 'producto',
      ),
    );

    if (confirm == true) {
      await _databaseService.deleteProduct(product.id);
      _loadData();
    }
  }
}