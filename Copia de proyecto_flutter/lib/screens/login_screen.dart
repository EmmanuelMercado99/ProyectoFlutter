import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Pantalla de inicio de sesión que maneja la autenticación de usuarios.
/// Proporciona un formulario para ingresar credenciales y gestiona
/// el proceso de autenticación contra la base de datos.
class LoginScreen extends StatefulWidget {
  /// Constructor por defecto que inicializa la pantalla de login
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Clave global para el manejo del estado del formulario
  final _formKey = GlobalKey<FormState>();
  
  /// Controlador para el campo de nombre de usuario
  final _nombreController = TextEditingController();
  
  /// Controlador para el campo de contraseña
  final _contrasenaController = TextEditingController();
  
  /// Servicio de base de datos para operaciones de autenticación
  final DatabaseService _databaseService = DatabaseService();
  
  /// Indicador de estado de carga durante el proceso de login
  bool _isLoading = false;

  /// Maneja el proceso de inicio de sesión
  /// Valida las credenciales contra la base de datos y
  /// actualiza el estado de autenticación en el AuthProvider
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user =
          await _databaseService.getUserByNombre(_nombreController.text);

      if (user != null && user.contrasena == _contrasenaController.text) {
        if (mounted) {
          // Actualizar el provider con el usuario actual
          Provider.of<AuthProvider>(context, listen: false).setUser(user);
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario o contraseña incorrectos'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: $e')),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.inventory,
                    size: 100, color: Color(0xFF50C878)),
                const SizedBox(height: 32),
                const Text(
                  'Sistema de Inventario',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Usuario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su nombre de usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Iniciar Sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Limpia los recursos al destruir el widget
  @override
  void dispose() {
    _nombreController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}
