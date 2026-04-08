import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/item.dart';
import '../models/invoice.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'preview_invoice_screen.dart'; // <-- TAMBAHKAN IMPORT INI

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  int? selectedBusinessId;
  int? selectedClientId;
  List<InvoiceItem> selectedItems = [];
  double tax = 0;
  double? discount;

  final _taxController = TextEditingController();
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false).loadBusinesses();
      Provider.of<ClientProvider>(context, listen: false).loadClients();
      Provider.of<ItemProvider>(context, listen: false).loadItems();
    });
  }

  @override
  void dispose() {
    _taxController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Invoice'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBusinessSection(),
            const SizedBox(height: 20),
            _buildClientSection(),
            const SizedBox(height: 20),
            _buildItemsSection(),
            const SizedBox(height: 20),
            _buildSummarySection(),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Preview Invoice',
              onPressed: _previewInvoice,
              icon: Icons.preview,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Bisnis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<BusinessProvider>(
              builder: (context, provider, child) {
                if (provider.businesses.isEmpty) {
                  return const Center(child: Text('Belum ada data bisnis'));
                }
                return DropdownButtonFormField<int>(
                  value: selectedBusinessId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: provider.businesses.map((business) {
                    return DropdownMenuItem(
                      value: business.id,
                      child: Text(business.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBusinessId = value;
                    });
                  },
                  hint: const Text('Pilih Bisnis'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Klien',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<ClientProvider>(
              builder: (context, provider, child) {
                if (provider.clients.isEmpty) {
                  return const Center(child: Text('Belum ada data klien'));
                }
                return DropdownButtonFormField<int>(
                  value: selectedClientId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: provider.clients.map((client) {
                    return DropdownMenuItem(
                      value: client.id,
                      child: Text(client.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClientId = value;
                    });
                  },
                  hint: const Text('Pilih Klien'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: _showAddItemDialog,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (selectedItems.isEmpty)
              const Center(
                child: Text(
                  'Belum ada item',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ...selectedItems.map((invoiceItem) => _buildItemCard(invoiceItem)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(InvoiceItem invoiceItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoiceItem.item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${invoiceItem.quantity} x ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(invoiceItem.item.price)}',
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(invoiceItem.subtotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    selectedItems.remove(invoiceItem);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    double subtotal = selectedItems.fold(0, (sum, item) => sum + item.subtotal);
    double taxAmount = subtotal * (tax / 100);
    double discountAmount = discount ?? 0;
    double total = subtotal + taxAmount - discountAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Subtotal',
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(subtotal),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Pajak (%)',
              controller: _taxController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
              onChanged: (value) {
                setState(() {
                  tax = double.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Diskon',
              controller: _discountController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.discount,
              onChanged: (value) {
                setState(() {
                  discount = double.tryParse(value) ?? 0;
                });
              },
            ),
            const Divider(),
            _buildSummaryRow(
              'Total',
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    Item? selectedItem;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<ItemProvider>(
                    builder: (context, provider, child) {
                      if (provider.items.isEmpty) {
                        return const Center(child: Text('Belum ada item'));
                      }
                      return DropdownButtonFormField<Item>(
                        value: selectedItem,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: provider.items.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              '${item.name} - ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.price)}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedItem = value;
                          });
                        },
                        hint: const Text('Pilih Item'),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Jumlah',
                    controller: TextEditingController(
                      text: quantity.toString(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      quantity = int.tryParse(value) ?? 1;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedItem != null && quantity > 0) {
                      setState(() {
                        selectedItems.add(
                          InvoiceItem(item: selectedItem!, quantity: quantity),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _previewInvoice() {
    if (selectedBusinessId == null ||
        selectedClientId == null ||
        selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data terlebih dahulu')),
      );
      return;
    }

    double subtotal = selectedItems.fold(0, (sum, item) => sum + item.subtotal);
    double total = subtotal + (subtotal * (tax / 100)) - (discount ?? 0);

    final invoiceData = {
      'invoiceNumber':
          'INV-${DateFormat('yyyy').format(DateTime.now())}-${DateTime.now().millisecondsSinceEpoch % 1000}',
      'date': DateTime.now().toIso8601String(),
      'businessId': selectedBusinessId,
      'clientId': selectedClientId,
      'items': selectedItems.map((e) => e.toMap()).toList(),
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentStatus': 1, // Unpaid
      'signaturePath': null,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PreviewInvoiceScreen(invoice: invoiceData), // SEKARANG SUDAH BISA
      ),
    );
  }
}
