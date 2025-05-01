import 'package:flutter/material.dart';
import '../models/user.dart';
import '../constants/roles.dart';

/// Proveedor de autenticación que gestiona el estado de la sesión del usuario
/// y los permisos de acceso en la aplicación.
/// Utiliza ChangeNotifier para notificar a los widgets cuando el estado cambia.
class AuthProvider extends ChangeNotifier {
  /// Usuario actualmente autenticado en el sistema
  /// Null cuando no hay sesión activa
  User? _currentUser;

  /// Getter para acceder al usuario actual
  /// Retorna null si no hay usuario autenticado
  User? get currentUser => _currentUser;

  /// Verifica si hay un usuario autenticado en el sistema
  bool get isAuthenticated => _currentUser != null;

  /// Verifica si el usuario actual tiene rol de administrador
  /// Utiliza la constante definida en Roles.administrador para la comparación
  bool get isAdmin => _currentUser?.rol == Roles.administrador;

  /// Verifica si el usuario tiene permiso para acceder a una ruta específica
  /// [route] La ruta que se intenta acceder
  /// Retorna true si el usuario tiene permiso, false en caso contrario
  bool canAccessRoute(String route) {
    if (_currentUser?.rol == Roles.administrador) return true;

    if (_currentUser?.rol == Roles.usuario) {
      return [
        '/home',
        '/products',
        '/new-sale',
        '/sales',
      ].contains(route);
    }

    return false;
  }

  /// Establece el usuario actual y notifica a los listeners del cambio
  /// [user] Nueva instancia de usuario para establecer la sesión
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Cierra la sesión del usuario actual
  /// Limpia la información del usuario y notifica a los listeners
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
