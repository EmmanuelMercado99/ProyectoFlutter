/// Pantalla principal del sistema que muestra el menú de navegación.
/// Proporciona acceso a diferentes módulos según el rol del usuario
/// (administrador o usuario regular) utilizando un diseño de cuadrícula.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  /// Constructor por defecto que inicializa la pantalla principal
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Inventario'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          /// Módulos disponibles para administradores
          if (authProvider.isAdmin) ...[
            _MenuCard(
              title: 'Inventario',
              icon: Icons.inventory,
              onTap: () => Navigator.pushNamed(context, '/products'),
            ),
            _MenuCard(
              title: 'Nueva Venta',
              icon: Icons.point_of_sale,
              onTap: () => Navigator.pushNamed(context, '/new-sale'),
            ),
            _MenuCard(
              title: 'Ventas',
              icon: Icons.shopping_cart,
              onTap: () => Navigator.pushNamed(context, '/sales'),
            ),
            _MenuCard(
              title: 'Sucursales',
              icon: Icons.store,
              onTap: () => Navigator.pushNamed(context, '/branches'),
            ),
            _MenuCard(
              title: 'Usuarios',
              icon: Icons.people,
              onTap: () => Navigator.pushNamed(context, '/users'),
            ),
            _MenuCard(
              title: 'Clientes',
              icon: Icons.person,
              onTap: () => Navigator.pushNamed(context, '/customers'),
            ),
            _MenuCard(
              title: 'Reportes',
              icon: Icons.bar_chart,
              onTap: () => Navigator.pushNamed(context, '/reports'),
            ),
          ],
          /// Módulos disponibles para usuarios regulares
          if (!authProvider.isAdmin) ...[
            _MenuCard(
              title: 'Productos',
              icon: Icons.inventory,
              onTap: () => Navigator.pushNamed(context, '/products'),
            ),
            _MenuCard(
              title: 'Nueva Venta',
              icon: Icons.point_of_sale,
              onTap: () => Navigator.pushNamed(context, '/new-sale'),
            ),
            _MenuCard(
              title: 'Ventas',
              icon: Icons.shopping_cart,
              onTap: () => Navigator.pushNamed(context, '/sales'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget privado que representa una tarjeta del menú principal
/// Muestra un ícono y título, y maneja la navegación al ser presionado
class _MenuCard extends StatelessWidget {
  /// Título que se muestra en la tarjeta
  final String title;

  /// Ícono que representa visualmente la funcionalidad
  final IconData icon;

  /// Función que se ejecuta al presionar la tarjeta
  final VoidCallback onTap;

  /// Constructor que inicializa una nueva tarjeta del menú
  /// Requiere título, ícono y función de callback
  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
