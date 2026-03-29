import 'package:flutter/material.dart';
import 'database/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Invoice App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    testDatabase();
  }

  Future<void> testDatabase() async {
    final db = DBHelper.instance;

    // 🔹 Insert invoice
    int invoiceId = await db.insertInvoice({
      'customer_name': 'Mario',
      'date': DateTime.now().toString(),
      'total': 50000
    });

    // 🔹 Insert item
    await db.insertItem({
      'invoice_id': invoiceId,
      'product_name': 'Kerupuk Udang',
      'price': 10000,
      'qty': 5
    });

    // 🔹 Ambil data
    var invoices = await db.getInvoices();
    print(invoices);

    var items = await db.getItems(invoiceId);
    print(items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Cek console untuk hasil database'),
      ),
    );
  }
}