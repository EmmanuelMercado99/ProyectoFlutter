/// Modelo que representa el detalle de una venta en el sistema.
/// Gestiona la información específica de cada producto vendido en una transacción,
/// incluyendo cantidad, precio unitario y cálculo de subtotal.
class SaleDetail {
  /// Identificador único del detalle de venta en la base de datos
  final int id;

  /// Identificador de la venta a la que pertenece este detalle
  /// Referencia a la tabla de ventas (Sale)
  final int saleId;

  /// Identificador del producto vendido
  /// Referencia a la tabla de productos (Product)
  final int productId;

  /// Cantidad de unidades vendidas del producto
  final int quantity;

  /// Precio unitario del producto al momento de la venta
  /// Almacenado como valor decimal para precisión en cálculos
  final double unitPrice;

  /// Constructor que inicializa una nueva instancia de detalle de venta
  /// Todos los campos son requeridos para garantizar la integridad de los datos
  SaleDetail({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  /// Calcula el subtotal del detalle multiplicando la cantidad por el precio unitario
  /// @return double Valor del subtotal calculado
  double get subtotal => quantity * unitPrice;

  /// Convierte la instancia de SaleDetail a un Map para su almacenamiento
  /// Los nombres de las claves corresponden a los campos en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_detalle': id,
      'id_venta': saleId,
      'id_producto': productId,
      'cantidad': quantity,
      'precio_unitario': unitPrice,
    };
  }

  /// Crea una instancia de SaleDetail a partir de un Map de la base de datos
  /// [map] debe contener todas las claves necesarias para la creación del detalle
  factory SaleDetail.fromMap(Map<String, dynamic> map) {
    return SaleDetail(
      id: map['id_detalle'],
      saleId: map['id_venta'],
      productId: map['id_producto'],
      quantity: map['cantidad'],
      unitPrice: map['precio_unitario'],
    );
  }
}
