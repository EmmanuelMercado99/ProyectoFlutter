/// Modelo que representa una venta en el sistema.
/// Gestiona la información de transacciones comerciales incluyendo
/// la sucursal, cliente, fecha, método de pago y total.
class Sale {
  /// Identificador único de la venta en la base de datos
  final int id;

  /// Identificador de la sucursal donde se realizó la venta
  /// Referencia a la tabla de sucursales (Branch)
  final int branchId;

  /// Identificador opcional del cliente que realizó la compra
  /// Puede ser null para ventas sin cliente registrado
  /// Referencia a la tabla de clientes (Customer)
  final int? customerId;

  /// Fecha y hora en que se realizó la venta
  /// Almacenada en formato DateTime para facilitar operaciones con fechas
  final DateTime date;

  /// Método de pago utilizado en la transacción
  /// Por ejemplo: "Efectivo", "Tarjeta", "Transferencia"
  final String paymentMethod;

  /// Monto total de la venta
  /// Suma de todos los productos incluidos en la transacción
  final double total;

  /// Constructor que inicializa una nueva instancia de venta
  /// [customerId] es opcional, todos los demás campos son requeridos
  Sale({
    required this.id,
    required this.branchId,
    this.customerId,
    required this.date,
    required this.paymentMethod,
    required this.total,
  });

  /// Convierte la instancia de Sale a un Map para su almacenamiento
  /// Los nombres de las claves corresponden a los campos en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id_venta': id,
      'id_sucursal': branchId,
      'id_cliente': customerId,
      'fecha': date.toIso8601String(),
      'metodo_pago': paymentMethod,
      'total': total,
    };
  }

  /// Crea una instancia de Sale a partir de un Map de la base de datos
  /// [map] debe contener todas las claves necesarias para la creación de la venta
  /// La fecha se parsea desde una cadena ISO 8601
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id_venta'],
      branchId: map['id_sucursal'],
      customerId: map['id_cliente'],
      date: DateTime.parse(map['fecha']),
      paymentMethod: map['metodo_pago'],
      total: map['total'],
    );
  }
}