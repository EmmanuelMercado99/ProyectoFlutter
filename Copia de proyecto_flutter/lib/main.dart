import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_management_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/branch_screen.dart';
import 'screens/product_screen.dart';
import 'screens/customer_screen.dart';
import 'screens/sale_screen.dart';
import 'screens/new_sale_screen.dart';
import 'screens/report_screen.dart';
import 'screens/user_form_screen.dart';
import 'services/database_service.dart';
import 'models/user.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  // Asegura que las inicializaciones necesarias estén completadas antes de ejecutar la app
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la base de datos para la web usando sqflite
  if (kIsWeb) {
    // Si la app está corriendo en la web, se usa una implementación diferente de sqflite
    databaseFactory = databaseFactoryFfi;
  }

  // Crear instancia de DatabaseService para manejar la base de datos
  final databaseService = DatabaseService();

  // Intenta obtener el usuario admin de la base de datos
  final adminUser = await databaseService.getUserByNombre('admin');

  // Si no se encuentra el usuario 'admin', se crea uno por defecto
  if (adminUser == null) {
    final defaultAdmin = User(
      id: 'admin_default',
      nombre: 'admin',
      contrasena: 'admin',
      rol: 1, // Rol de administrador
      correo: 'admin@sistema.com',
    );

    // Inserta el usuario administrador en la base de datos
    await databaseService.insertUser(defaultAdmin);
  }

  // Ejecuta la aplicación envolviendo el widget principal con un proveedor de estado para autenticación
  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          AuthProvider(), // Proveedor para manejar el estado de autenticación
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuración de la aplicación Material
    return MaterialApp(
      title: 'Sistema de Inventario',
      debugShowCheckedModeBanner: false, // Desactiva el banner de depuración
      theme: ThemeData(
        useMaterial3: true, // Usa la versión 3 de Material Design
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF50C878), // Color principal (Emerald Green)
          brightness: Brightness.light, // Tema claro
          surface: Colors.white, // Color de fondo de las superficies
        ),
        scaffoldBackgroundColor:
            Colors.white, // Color de fondo de las pantallas
      ),
      initialRoute: '/login', // Ruta inicial es la de login
      onGenerateRoute: (settings) {
        // Si se accede directamente a la ruta de login, permite el acceso
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
        }

        // Verifica si el usuario está autenticado antes de permitir el acceso
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Si el usuario no está autenticado, redirige al login
        if (!authProvider.isAuthenticated) {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        }

        // Verifica si el usuario tiene permisos para acceder a la ruta solicitada
        if (!authProvider.canAccessRoute(settings.name ?? '')) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text('No tienes permiso para acceder a esta página'),
              ),
            ),
          );
        }

        // Si el usuario tiene permisos, se redirige a la ruta correspondiente
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/users':
            return MaterialPageRoute(
                builder: (context) => const UserManagementScreen());
          case '/user-form':
            return MaterialPageRoute(
                builder: (context) => const UserFormScreen());
          case '/branches':
            return MaterialPageRoute(
                builder: (context) => const BranchScreen());
          case '/products':
            return MaterialPageRoute(
                builder: (context) => const ProductScreen());
          case '/customers':
            return MaterialPageRoute(
                builder: (context) => const CustomerScreen());
          case '/sales':
            return MaterialPageRoute(builder: (context) => const SaleScreen());
          case '/new-sale':
            return MaterialPageRoute(
                builder: (context) => const NewSaleScreen());
          case '/reports':
            return MaterialPageRoute(
                builder: (context) => const ReportScreen());
          default:
            // Ruta por defecto es la de home
            return MaterialPageRoute(builder: (context) => const HomeScreen());
        }
      },
    );
  }
}
