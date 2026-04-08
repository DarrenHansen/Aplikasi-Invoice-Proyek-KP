import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/business.dart';
import '../models/client.dart';
import '../models/item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static Future<void> init() async {
    await instance.database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('invoice_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE businesses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        logoPath TEXT,
        name TEXT NOT NULL,
        owner TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        website TEXT,
        paymentMethods TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceNumber TEXT NOT NULL,
        date TEXT NOT NULL,
        businessId INTEGER NOT NULL,
        clientId INTEGER NOT NULL,
        items TEXT NOT NULL,
        tax REAL NOT NULL,
        discount REAL,
        total REAL NOT NULL,
        paymentStatus INTEGER NOT NULL,
        signaturePath TEXT,
        FOREIGN KEY (businessId) REFERENCES businesses (id),
        FOREIGN KEY (clientId) REFERENCES clients (id)
      )
    ''');
  }

  // Business CRUD
  Future<int> insertBusiness(Business business) async {
    final db = await database;
    return await db.insert('businesses', business.toMap());
  }

  Future<List<Business>> getBusinesses() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('businesses');
    return result.map((map) => Business.fromMap(map)).toList();
  }

  Future<int> updateBusiness(Business business) async {
    final db = await database;
    return await db.update(
      'businesses',
      business.toMap(),
      where: 'id = ?',
      whereArgs: [business.id],
    );
  }

  Future<int> deleteBusiness(int id) async {
    final db = await database;
    return await db.delete('businesses', where: 'id = ?', whereArgs: [id]);
  }

  // Client CRUD
  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('clients');
    return result.map((map) => Client.fromMap(map)).toList();
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  // Item CRUD
  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('items');
    return result.map((map) => Item.fromMap(map)).toList();
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // Invoice CRUD
  Future<int> insertInvoice(Map<String, dynamic> invoice) async {
    final db = await database;
    final Map<String, dynamic> invoiceData = Map<String, dynamic>.from(invoice);

    // Convert items list to JSON string
    if (invoiceData['items'] is List) {
      invoiceData['items'] = jsonEncode(invoiceData['items']);
    }

    return await db.insert('invoices', invoiceData);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'invoices',
      orderBy: 'date DESC',
    );

    final List<Map<String, dynamic>> invoices = [];

    for (var map in result) {
      final Map<String, dynamic> invoice = Map<String, dynamic>.from(map);

      // Decode items from JSON string to List
      final String itemsJson = invoice['items'] as String;
      invoice['items'] = jsonDecode(itemsJson) as List<dynamic>;

      invoices.add(invoice);
    }

    return invoices;
  }

  Future<Map<String, dynamic>?> getInvoiceById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    final Map<String, dynamic> invoice = Map<String, dynamic>.from(
      result.first,
    );
    final String itemsJson = invoice['items'] as String;
    invoice['items'] = jsonDecode(itemsJson) as List<dynamic>;

    return invoice;
  }

  Future<int> updateInvoice(Map<String, dynamic> invoice) async {
    final db = await database;
    final Map<String, dynamic> invoiceData = Map<String, dynamic>.from(invoice);

    // Convert items list to JSON string
    if (invoiceData['items'] is List) {
      invoiceData['items'] = jsonEncode(invoiceData['items']);
    }

    return await db.update(
      'invoices',
      invoiceData,
      where: 'id = ?',
      whereArgs: [invoice['id']],
    );
  }

  Future<int> deleteInvoice(int id) async {
    final db = await database;
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  // Additional helper methods
  Future<List<Map<String, dynamic>>> getInvoicesByStatus(
    int paymentStatus,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'invoices',
      where: 'paymentStatus = ?',
      whereArgs: [paymentStatus],
      orderBy: 'date DESC',
    );

    final List<Map<String, dynamic>> invoices = [];

    for (var map in result) {
      final Map<String, dynamic> invoice = Map<String, dynamic>.from(map);
      final String itemsJson = invoice['items'] as String;
      invoice['items'] = jsonDecode(itemsJson) as List<dynamic>;
      invoices.add(invoice);
    }

    return invoices;
  }

  Future<List<Map<String, dynamic>>> searchInvoicesByClientName(
    String clientName,
  ) async {
    final db = await database;
    // This is a simplified search - you might want to join with clients table
    final List<Map<String, dynamic>> result = await db.query(
      'invoices',
      orderBy: 'date DESC',
    );

    final List<Map<String, dynamic>> invoices = [];

    for (var map in result) {
      final Map<String, dynamic> invoice = Map<String, dynamic>.from(map);
      final String itemsJson = invoice['items'] as String;
      invoice['items'] = jsonDecode(itemsJson) as List<dynamic>;
      invoices.add(invoice);
    }

    return invoices;
  }
}
