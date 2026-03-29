import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('invoice.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE invoices(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_name TEXT,
      date TEXT,
      total REAL
    )
    ''');

    await db.execute('''
    CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER,
      product_name TEXT,
      price REAL,
      qty INTEGER,
      FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
    )
    ''');
  }

  // 🔹 INSERT INVOICE
  Future<int> insertInvoice(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('invoices', data);
  }

  // 🔹 INSERT ITEM
  Future<int> insertItem(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('items', data);
  }

  // 🔹 GET INVOICES
  Future<List<Map<String, dynamic>>> getInvoices() async {
    final db = await instance.database;
    return await db.query('invoices');
  }

  // 🔹 GET ITEMS BY INVOICE
  Future<List<Map<String, dynamic>>> getItems(int invoiceId) async {
    final db = await instance.database;
    return await db.query(
      'items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
  }
}