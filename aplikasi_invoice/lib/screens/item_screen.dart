import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/item.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemProvider>(context, listen: false).loadItems();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Item'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ItemProvider>(
        builder: (context, provider, child) {
          if (provider.items.isEmpty) {
            return _buildEmptyState();
          }
          return _buildItemList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Belum ada item', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Tambah Item',
            onPressed: () => _showItemDialog(),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(ItemProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.white),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kategori: ${item.category}'),
                Text(
                  'Harga: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.price)}',
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showItemDialog(item: item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(provider, item.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showItemDialog({Item? item}) {
    if (item != null) {
      _nameController.text = item.name;
      _priceController.text = item.price.toString();
      _categoryController.text = item.category;
      _descriptionController.text = item.description ?? '';
    } else {
      _nameController.clear();
      _priceController.clear();
      _categoryController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Tambah Item' : 'Edit Item'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Nama Produk',
                  controller: _nameController,
                  prefixIcon: Icons.inventory,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Harga',
                  controller: _priceController,
                  prefixIcon: Icons.money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Kategori',
                  controller: _categoryController,
                  prefixIcon: Icons.category,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Deskripsi',
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newItem = Item(
                    id: item?.id,
                    name: _nameController.text,
                    price: double.parse(_priceController.text),
                    category: _categoryController.text,
                    description: _descriptionController.text.isEmpty
                        ? null
                        : _descriptionController.text,
                  );

                  if (item == null) {
                    await Provider.of<ItemProvider>(
                      context,
                      listen: false,
                    ).addItem(newItem);
                  } else {
                    await Provider.of<ItemProvider>(
                      context,
                      listen: false,
                    ).updateItem(newItem);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          item == null ? 'Item ditambahkan' : 'Item diupdate',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(ItemProvider provider, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: const Text('Yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteItem(id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Item dihapus')));
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
