/// Pantalla que gestiona la visualización y administración de sucursales.
/// Permite crear, editar, eliminar y buscar sucursales en el sistema.
/// Implementa funcionalidades CRUD completas con interfaz de usuario interactiva.
import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../services/database_service.dart';
import '../widgets/branch_dialog.dart';
import '../widgets/confirm_delete_dialog.dart';

class BranchScreen extends StatefulWidget {
  /// Constructor por defecto que inicializa la pantalla de sucursales
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  /// Servicio de base de datos para operaciones CRUD
  final DatabaseService _databaseService = DatabaseService();
  
  /// Lista completa de sucursales en el sistema
  List<Branch> _branches = [];
  
  /// Lista filtrada de sucursales basada en la búsqueda
  List<Branch> _filteredBranches = [];
  
  /// Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _searchController.addListener(_filterBranches);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra las sucursales basado en el texto de búsqueda
  /// Actualiza _filteredBranches con las coincidencias encontradas
  void _filterBranches() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBranches = _branches.where((branch) =>
        branch.name.toLowerCase().contains(query)
      ).toList();
    });
  }

  /// Carga todas las sucursales desde la base de datos
  /// Actualiza tanto la lista completa como la filtrada
  Future<void> _loadBranches() async {
    final branches = await _databaseService.getBranches();
    setState(() {
      _branches = branches;
      _filteredBranches = branches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sucursales'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar sucursal',
                hintText: 'Ingrese el nombre de la sucursal',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredBranches.length,
              itemBuilder: (context, index) {
                final branch = _filteredBranches[index];
                return ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(branch.name),
                  subtitle: Text(branch.location ?? 'Sin ubicación'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editBranch(branch),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => _deleteBranch(branch),
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
        onPressed: _addBranch,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Maneja la creación de una nueva sucursal
  /// Muestra un diálogo para ingresar los datos y persiste en la base de datos
  Future<void> _addBranch() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => BranchDialog(),
    );

    if (result != null) {
      final branch = Branch(
        id: DateTime.now().millisecondsSinceEpoch,
        name: result['name']!,
        location: result['location'],
      );

      await _databaseService.insertBranch(branch);
      _loadBranches();
    }
  }

  /// Maneja la edición de una sucursal existente
  /// [branch] La sucursal a editar
  Future<void> _editBranch(Branch branch) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => BranchDialog(branch: branch),
    );

    if (result != null) {
      final updatedBranch = Branch(
        id: branch.id,
        name: result['name']!,
        location: result['location'],
      );

      await _databaseService.updateBranch(updatedBranch);
      _loadBranches();
    }
  }

  /// Maneja la eliminación de una sucursal
  /// [branch] La sucursal a eliminar
  /// Muestra un diálogo de confirmación antes de proceder
  Future<void> _deleteBranch(Branch branch) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        itemName: branch.name,
        itemType: 'sucursal',
      ),
    );

    if (confirm == true) {
      await _databaseService.deleteBranch(branch.id);
      _loadBranches();
    }
  }
}