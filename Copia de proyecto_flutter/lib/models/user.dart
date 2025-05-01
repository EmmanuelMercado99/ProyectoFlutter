/// Modelo que representa un usuario en el sistema.
/// Gestiona la información de autenticación y autorización de usuarios,
/// incluyendo credenciales y rol de acceso.
class User {
  /// Identificador único del usuario en el sistema
  final String id;

  /// Nombre de usuario o nickname para identificación en el sistema
  final String nombre;

  /// Dirección de correo electrónico del usuario
  /// Opcional, utilizado para recuperación de cuenta y notificaciones
  final String? correo;

  /// Contraseña del usuario almacenada de forma segura
  /// Se recomienda almacenar en formato hash por seguridad
  final String contrasena;

  /// Nivel de acceso del usuario en el sistema
  /// Opcional, define los permisos y capacidades del usuario
  /// Referencia a las constantes definidas en la clase Roles
  final int? rol;

  /// Constructor que inicializa una nueva instancia de usuario
  /// [id] y [nombre] son requeridos para la identificación básica
  /// [correo] y [rol] son opcionales para flexibilidad en el registro
  User({
    required this.id,
    required this.nombre,
    this.correo,
    required this.contrasena,
    this.rol,
  });

  /// Convierte la instancia de User a un Map para su almacenamiento
  /// Los nombres de las claves corresponden a los campos en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_usuario': id,
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
      'rol': rol,
    };
  }

  /// Crea una instancia de User a partir de un Map de la base de datos
  /// [map] debe contener las claves necesarias para la creación del usuario
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id_usuario'],
      nombre: map['nombre'],
      correo: map['correo'],
      contrasena: map['contrasena'],
      rol: map['rol'],
    );
  }

  /// Crea una copia del usuario con campos actualizados opcionalmente
  /// Útil para actualizar datos del usuario manteniendo la inmutabilidad
  User copyWith({
    String? id,
    String? nombre,
    String? correo,
    String? contrasena,
    int? rol,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
      rol: rol ?? this.rol,
    );
  }
}