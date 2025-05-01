/// Modelo que representa una sucursal en el sistema.
/// Gestiona la información básica de las sucursales incluyendo
/// su identificador único, nombre y ubicación física.
class Branch {
  /// Identificador único de la sucursal en la base de datos
  final int id;

  /// Nombre comercial de la sucursal
  final String name;

  /// Dirección física de la sucursal
  /// Puede ser nulo si la sucursal no tiene una ubicación física definida
  final String? location;

  /// Constructor que inicializa una nueva instancia de sucursal
  /// [id] es requerido y debe ser único
  /// [name] es requerido y representa el nombre de la sucursal
  /// [location] es opcional y representa la dirección física
  Branch({
    required this.id,
    required this.name,
    this.location,
  });

  /// Convierte la instancia de Branch a un Map para su almacenamiento en la base de datos
  /// Los nombres de las claves corresponden a los campos en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_sucursal': id,
      'nombre': name,
      'ubicacion': location,
    };
  }

  /// Crea una instancia de Branch a partir de un Map obtenido de la base de datos
  /// [map] debe contener las claves 'id_sucursal', 'nombre' y opcionalmente 'ubicacion'
  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      id: map['id_sucursal'],
      name: map['nombre'],
      location: map['ubicacion'],
    );
  }
}