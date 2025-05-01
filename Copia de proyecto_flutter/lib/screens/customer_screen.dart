/// Pantalla que gestiona la visualización y administración de clientes.
/// Proporciona funcionalidades CRUD completas para la gestión de clientes,
/// incluyendo búsqueda en tiempo real y operaciones de base de datos.
import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/database_service.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/customer_dialog.dart';

class CustomerScreen extends StatefulWidget {
  /// Constructor por defecto que inicializa la pantalla de clientes
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  /// Servicio de base de datos para operaciones CRUD
  final DatabaseService _databaseService = DatabaseService();
  
  /// Lista de clientes que se muestra en la interfaz
  List<Customer> _customers = [];
  
  /// Controlador para el campo de búsqueda de clientes
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga todos los clientes desde la base de datos
  /// Maneja errores mostrando un SnackBar con el mensaje de error
  Future<void> _loadData() async {
    try {
      final customers = await _databaseService.getCustomers();
      if (mounted) {
        setState(() {
          _customers = customers;
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

  /// Filtra la lista de clientes basado en el texto de búsqueda
  /// Actualiza la lista en tiempo real mientras el usuario escribe
  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _customers = _customers.where((customer) {
        return customer.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  /// Maneja la creación de un nuevo cliente
  /// Muestra un diálogo para ingresar los datos y persiste en la base de datos
  Future<void> _addCustomer() async {
    final result = await showDialog<Customer>(
      context: context,
      builder: (context) => CustomerDialog(),
    );

    if (result != null) {
      await _databaseService.insertCustomer(result);
      _loadData();
    }
  }

  /// Maneja la edición de un cliente existente
  /// [customer] El cliente a editar
  Future<void> _editCustomer(Customer customer) async {
    final result = await showDialog<Customer>(
      context: context,
      builder: (context) => CustomerDialog(customer: customer),
    );

    if (result != null) {
      await _databaseService.updateCustomer(result);
      _loadData();
    }
  }

  /// Maneja la eliminación de un cliente
  /// [customer] El cliente a eliminar
  /// Muestra un diálogo de confirmación antes de proceder
  Future<void> _deleteCustomer(Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        itemName: customer.name,
        itemType: 'cliente',
      ),
    );

    if (confirm == true) {
      await _databaseService.deleteCustomer(customer.id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar cliente',
                hintText: 'Ingrese el nombre del cliente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(customer.name),
                  subtitle: Text(customer.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editCustomer(customer),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => _deleteCustomer(customer),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
