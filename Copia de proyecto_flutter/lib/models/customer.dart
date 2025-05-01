/// Modelo que representa un cliente en el sistema.
/// Gestiona la información básica de los clientes incluyendo
/// su identificador único, nombre y correo electrónico.
class Customer {
  /// Identificador único del cliente en la base de datos
  final int id;

  /// Nombre completo del cliente
  final String name;

  /// Dirección de correo electrónico del cliente
  /// Utilizada para comunicaciones y como identificador alternativo
  final String email;

  /// Constructor que inicializa una nueva instancia de cliente
  /// [id] es requerido y debe ser único
  /// [name] es requerido y representa el nombre completo del cliente
  /// [email] es requerido y debe ser una dirección de correo válida
  Customer({required this.id, required this.name, required this.email});

  /// Convierte la instancia de Customer a un Map para su almacenamiento en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  /// Crea una instancia de Customer a partir de un Map obtenido de la base de datos
  /// [map] debe contener las claves 'id', 'name' y 'email'
  static Customer fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }
}