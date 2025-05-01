/// Define las constantes de roles utilizadas en el sistema de autenticación
/// y autorización de la aplicación. Cada rol representa un nivel diferente
/// de acceso y permisos dentro del sistema.
class Roles {
  /// Rol con acceso total al sistema. Permite gestionar usuarios,
  /// configurar parámetros del sistema y acceder a todas las funcionalidades.
  static const int administrador = 1;

  /// Rol con acceso limitado. Permite realizar operaciones básicas
  /// como gestión de inventario y ventas.
  static const int usuario = 2;
}