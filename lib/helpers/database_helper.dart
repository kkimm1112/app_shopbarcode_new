import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/sales_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'products.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        barcode TEXT,
        quantity INTEGER,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT,
        items TEXT,
        total REAL
      )
    ''');
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateProductQuantity(int id, int newQty) async {
    final db = await database;
    await db.update('products', {'quantity': newQty}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertSalesHistory(SalesHistory sale) async {
  final db = await database;
  await db.insert('sales_history', sale.toMap());
}

Future<List<SalesHistory>> getAllSalesHistory() async {
  final db = await database;
  final result = await db.query('sales_history', orderBy: 'dateTime DESC');
  return result.map((e) => SalesHistory.fromMap(e)).toList();
}


}
