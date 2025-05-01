/// Modelo que representa un producto en el sistema de inventario.
/// Gestiona la información de productos incluyendo su identificador,
/// precio, existencias y la sucursal a la que pertenece.
class Product {
  /// Identificador único del producto en la base de datos
  final int id;

  /// Nombre del producto
  final String name;

  /// Precio unitario del producto
  /// Almacenado como valor decimal para precisión en cálculos
  final double price;

  /// Cantidad disponible en inventario
  /// Se utiliza para control de stock y alertas de bajo inventario
  final int stock;

  /// Identificador de la sucursal a la que pertenece el producto
  /// Referencia a la tabla de sucursales (Branch)
  final int branchId;

  /// Constructor que inicializa una nueva instancia de producto
  /// Todos los campos son requeridos para garantizar la integridad de los datos
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.branchId,
  });

  /// Convierte la instancia de Product a un Map para su almacenamiento
  /// Los nombres de las claves corresponden a los campos en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_producto': id,
      'nombre': name,
      'precio': price,
      'existencias': stock,
      'id_sucursal': branchId,
    };
  }

  /// Crea una instancia de Product a partir de un Map de la base de datos
  /// [map] debe contener todas las claves necesarias para la creación del producto
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id_producto'],
      name: map['nombre'],
      price: map['precio'],
      stock: map['existencias'],
      branchId: map['id_sucursal'],
    );
  }
}