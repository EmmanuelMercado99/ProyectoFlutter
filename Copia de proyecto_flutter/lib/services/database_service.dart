import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/branch.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/sale_detail.dart';
import '../models/user.dart';

/// Servicio para el manejo de la base de datos local SQLite
class DatabaseService {
  static Database? _database;

  /// Getter para obtener una instancia de la base de datos.
  /// Si no existe, la inicializa.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos, crea las tablas necesarias
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');

    // Crear base de datos y definir tablas en la creación
    return await openDatabase(
      path,
      version: 4,
      onCreate: (Database db, int version) async {
        // Tabla de sucursales
        await db.execute('''
          CREATE TABLE sucursal(
            id_sucursal INTEGER PRIMARY KEY,
            nombre TEXT NOT NULL,
            ubicacion TEXT
          )
        ''');

        // Tabla de productos
        await db.execute('''
          CREATE TABLE producto(
            id_producto INTEGER PRIMARY KEY,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL,
            existencias INTEGER NOT NULL,
            id_sucursal INTEGER NOT NULL,
            FOREIGN KEY (id_sucursal) REFERENCES sucursal (id_sucursal)
          )
        ''');

        // Tabla de clientes
        await db.execute('''
          CREATE TABLE customers(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');

        // Tabla de ventas
        await db.execute('''
          CREATE TABLE venta(
            id_venta INTEGER PRIMARY KEY,
            id_sucursal INTEGER NOT NULL,
            id_cliente INTEGER,
            fecha TEXT NOT NULL,
            metodo_pago TEXT NOT NULL,
            total REAL NOT NULL,
            FOREIGN KEY (id_sucursal) REFERENCES sucursal (id_sucursal),
            FOREIGN KEY (id_cliente) REFERENCES customers (id)
          )
        ''');

        // Tabla de detalle de ventas
        await db.execute('''
          CREATE TABLE detalle_venta(
            id_detalle INTEGER PRIMARY KEY,
            id_venta INTEGER NOT NULL,
            id_producto INTEGER NOT NULL,
            cantidad INTEGER NOT NULL,
            precio_unitario REAL NOT NULL,
            FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
            FOREIGN KEY (id_producto) REFERENCES producto (id_producto)
          )
        ''');

        // Tabla de usuarios
        await db.execute('''
          CREATE TABLE users(
            id_usuario TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            correo TEXT,
            contrasena TEXT NOT NULL,
            rol INTEGER
          )
        ''');
      },
      // Manejo de actualizaciones de versión de la base de datos
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS producto(
              id_producto INTEGER PRIMARY KEY,
              nombre TEXT NOT NULL,
              precio REAL NOT NULL,
              existencias INTEGER NOT NULL,
              id_sucursal INTEGER NOT NULL,
              FOREIGN KEY (id_sucursal) REFERENCES sucursal (id_sucursal)
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS customers(
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL,
              email TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  // ----------------------------- CRUD Sucursales -----------------------------

  /// Inserta una nueva sucursal
  Future<void> insertBranch(Branch branch) async {
    final db = await database;
    await db.insert(
      'sucursal',
      branch.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todas las sucursales
  Future<List<Branch>> getBranches() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sucursal');
    return List.generate(maps.length, (i) => Branch.fromMap(maps[i]));
  }

  /// Actualiza una sucursal existente
  Future<void> updateBranch(Branch branch) async {
    final db = await database;
    await db.update(
      'sucursal',
      branch.toMap(),
      where: 'id_sucursal = ?',
      whereArgs: [branch.id],
    );
  }

  /// Elimina una sucursal por ID
  Future<void> deleteBranch(int id) async {
    final db = await database;
    await db.delete(
      'sucursal',
      where: 'id_sucursal = ?',
      whereArgs: [id],
    );
  }

  // ----------------------------- CRUD Productos -----------------------------

  /// Inserta un nuevo producto
  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'producto',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todos los productos
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('producto');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  /// Obtiene productos filtrados por sucursal
  Future<List<Product>> getProductsByBranch(int branchId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'producto',
      where: 'id_sucursal = ?',
      whereArgs: [branchId],
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  /// Actualiza un producto existente
  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'producto',
      product.toMap(),
      where: 'id_producto = ?',
      whereArgs: [product.id],
    );
  }

  /// Elimina un producto por ID
  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'producto',
      where: 'id_producto = ?',
      whereArgs: [id],
    );
  }

  // ----------------------------- CRUD Clientes -----------------------------

  /// Obtiene todos los clientes
  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  /// Inserta un nuevo cliente
  Future<void> insertCustomer(Customer customer) async {
    final db = await database;
    await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualiza un cliente existente
  Future<void> updateCustomer(Customer customer) async {
    final db = await database;
    await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  /// Elimina un cliente por ID
  Future<void> deleteCustomer(int id) async {
    final db = await database;
    await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------------------- CRUD Ventas -----------------------------

  /// Inserta una venta
  Future<void> insertSale(Sale sale) async {
    final db = await database;
    await db.insert(
      'venta',
      sale.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserta un detalle de venta
  Future<void> insertSaleDetail(SaleDetail detail) async {
    final db = await database;
    await db.insert(
      'detalle_venta',
      detail.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todas las ventas
  Future<List<Sale>> getSales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('venta');
    return List.generate(maps.length, (i) => Sale.fromMap(maps[i]));
  }

  /// Obtiene los detalles de una venta
  Future<List<SaleDetail>> getSaleDetails(int saleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'detalle_venta',
      where: 'id_venta = ?',
      whereArgs: [saleId],
    );
    return List.generate(maps.length, (i) => SaleDetail.fromMap(maps[i]));
  }

  /// Elimina una venta y sus detalles asociados
  Future<void> deleteSale(int id) async {
    final db = await database;
    await db.delete(
      'detalle_venta',
      where: 'id_venta = ?',
      whereArgs: [id],
    );
    await db.delete(
      'venta',
      where: 'id_venta = ?',
      whereArgs: [id],
    );
  }

  // ----------------------------- CRUD Usuarios -----------------------------

  /// Obtiene todos los usuarios
  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  /// Obtiene un usuario por su ID
  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id_usuario = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  /// Obtiene un usuario por su nombre
  Future<User?> getUserByNombre(String nombre) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'nombre = ?',
      whereArgs: [nombre],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  /// Inserta un nuevo usuario
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualiza un usuario existente
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id_usuario = ?',
      whereArgs: [user.id],
    );
  }

  /// Elimina un usuario por ID
  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id_usuario = ?',
      whereArgs: [id],
    );
  }
}
