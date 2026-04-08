import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:intl/intl.dart';
import 'models/business.dart';
import 'models/client.dart';
import 'models/item.dart';
//import 'models/invoice.dart';
import 'database/db_helper.dart';
import 'screens/home_screen.dart';
import 'screens/business_screen.dart';
import 'screens/client_screen.dart';
import 'screens/item_screen.dart';
import 'screens/create_invoice_screen.dart';
//import 'screens/preview_invoice_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
      ],
      child: MaterialApp(
        title: 'Invoice Generator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          cardTheme: CardThemeData(
            // <-- PERUBAHAN: CardTheme menjadi CardThemeData
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/business': (context) => const BusinessScreen(),
          '/clients': (context) => const ClientScreen(),
          '/items': (context) => const ItemScreen(),
          '/create_invoice': (context) => const CreateInvoiceScreen(),
        },
      ),
    );
  }
}

// Providers
class BusinessProvider extends ChangeNotifier {
  List<Business> _businesses = [];

  List<Business> get businesses => _businesses;

  Future<void> loadBusinesses() async {
    _businesses = await DatabaseHelper.instance.getBusinesses();
    notifyListeners();
  }

  Future<void> addBusiness(Business business) async {
    await DatabaseHelper.instance.insertBusiness(business);
    await loadBusinesses();
  }

  Future<void> updateBusiness(Business business) async {
    await DatabaseHelper.instance.updateBusiness(business);
    await loadBusinesses();
  }

  Future<void> deleteBusiness(int id) async {
    await DatabaseHelper.instance.deleteBusiness(id);
    await loadBusinesses();
  }
}

class ClientProvider extends ChangeNotifier {
  List<Client> _clients = [];

  List<Client> get clients => _clients;

  Future<void> loadClients() async {
    _clients = await DatabaseHelper.instance.getClients();
    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    await DatabaseHelper.instance.insertClient(client);
    await loadClients();
  }

  Future<void> updateClient(Client client) async {
    await DatabaseHelper.instance.updateClient(client);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await DatabaseHelper.instance.deleteClient(id);
    await loadClients();
  }
}

class ItemProvider extends ChangeNotifier {
  List<Item> _items = [];

  List<Item> get items => _items;

  Future<void> loadItems() async {
    _items = await DatabaseHelper.instance.getItems();
    notifyListeners();
  }

  Future<void> addItem(Item item) async {
    await DatabaseHelper.instance.insertItem(item);
    await loadItems();
  }

  Future<void> updateItem(Item item) async {
    await DatabaseHelper.instance.updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    await loadItems();
  }
}

class InvoiceProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _invoices = [];

  List<Map<String, dynamic>> get invoices => _invoices;

  Future<void> loadInvoices() async {
    _invoices = await DatabaseHelper.instance.getInvoices();
    notifyListeners();
  }

  Future<void> addInvoice(Map<String, dynamic> invoice) async {
    await DatabaseHelper.instance.insertInvoice(invoice);
    await loadInvoices();
  }

  Future<void> updateInvoice(Map<String, dynamic> invoice) async {
    await DatabaseHelper.instance.updateInvoice(invoice);
    await loadInvoices();
  }

  Future<void> deleteInvoice(int id) async {
    await DatabaseHelper.instance.deleteInvoice(id);
    await loadInvoices();
  }

  double getTotalRevenue() {
    return _invoices
        .where((inv) => inv['paymentStatus'] == 0)
        .fold(0, (sum, inv) => sum + (inv['total'] as double));
  }

  int getUnpaidInvoicesCount() {
    return _invoices.where((inv) => inv['paymentStatus'] == 1).length;
  }
}
