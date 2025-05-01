import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';

/// Pantalla que gestiona la creación y edición de usuarios del sistema.
/// Proporciona un formulario para ingresar o modificar la información del usuario,
/// incluyendo nombre, correo, contraseña y rol.
class UserFormScreen extends StatefulWidget {
  /// Usuario a editar. Si es null, se creará un nuevo usuario
  final User? user;

  /// Constructor que inicializa la pantalla de formulario de usuario
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  /// Clave global para el manejo del estado del formulario
  final _formKey = GlobalKey<FormState>();
  
  /// Controlador para el campo de nombre de usuario
  final _nombreController = TextEditingController();
  
  /// Controlador para el campo de correo electrónico
  final _correoController = TextEditingController();
  
  /// Controlador para el campo de contraseña
  final _contrasenaController = TextEditingController();
  
  /// Rol seleccionado para el usuario (1: Administrador, 2: Usuario)
  int? _selectedRol;
  
  /// Servicio de base de datos para operaciones CRUD
  final DatabaseService _databaseService = DatabaseService();
  
  /// Indicador de estado de carga
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Inicializa el formulario con los datos del usuario si está en modo edición
  void _initializeForm() {
    if (widget.user != null) {
      _nombreController.text = widget.user!.nombre;
      _correoController.text = widget.user!.correo ?? '';
      _contrasenaController.text = widget.user!.contrasena;
      _selectedRol = widget.user!.rol;
    }
  }

  /// Guarda o actualiza la información del usuario en la base de datos
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = User(
        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreController.text,
        correo: _correoController.text.isEmpty ? null : _correoController.text,
        contrasena: _contrasenaController.text,
        rol: _selectedRol,
      );

      if (widget.user == null) {
        await _databaseService.insertUser(user);
      } else {
        await _databaseService.updateUser(user);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar usuario: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Nuevo Usuario' : 'Editar Usuario'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Usuario',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo (opcional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contrasenaController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRol,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Administrador')),
                  DropdownMenuItem(value: 2, child: Text('Usuario')),
                ],
                onChanged: (value) {
                  setState(() => _selectedRol = value);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Limpia los recursos al destruir el widget
  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}