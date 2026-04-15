import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/business.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _newMethodController = TextEditingController();
  List<String> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false).loadBusinesses();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _newMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Bisnis'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, provider, child) {
          if (provider.businesses.isEmpty) {
            return _buildEmptyState();
          }
          return _buildBusinessList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBusinessDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }
///
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum ada data bisnis',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Tambah Bisnis',
              onPressed: () => _showBusinessDialog(),
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessList(BusinessProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.businesses.length,
      itemBuilder: (context, index) {
        final business = provider.businesses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
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
              child: const Icon(Icons.business, color: Colors.white),
            ),
            title: Text(
              business.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(business.owner), Text(business.phone)],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showBusinessDialog(business: business),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBusiness(provider, business.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBusinessDialog({Business? business}) {
    if (business != null) {
      _nameController.text = business.name;
      _ownerController.text = business.owner;
      _addressController.text = business.address;
      _phoneController.text = business.phone;
      _websiteController.text = business.website ?? '';
      _paymentMethods = List.from(business.paymentMethods);
    } else {
      _nameController.clear();
      _ownerController.clear();
      _addressController.clear();
      _phoneController.clear();
      _websiteController.clear();
      _paymentMethods.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(business == null ? 'Tambah Bisnis' : 'Edit Bisnis'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextField(
                          label: 'Nama Bisnis',
                          controller: _nameController,
                          prefixIcon: Icons.business,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Pemilik',
                          controller: _ownerController,
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Alamat',
                          controller: _addressController,
                          prefixIcon: Icons.location_on,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Telepon',
                          controller: _phoneController,
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Website',
                          controller: _websiteController,
                          prefixIcon: Icons.language,
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Metode Pembayaran',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _paymentMethods
                                  .map(
                                    (method) => Chip(
                                      label: Text(method),
                                      onDeleted: () {
                                        setState(() {
                                          _paymentMethods.remove(method);
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _newMethodController,
                                    decoration: InputDecoration(
                                      hintText: 'Tambahkan metode',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    if (_newMethodController.text.isNotEmpty) {
                                      setState(() {
                                        _paymentMethods.add(
                                          _newMethodController.text,
                                        );
                                        _newMethodController.clear();
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                      final newBusiness = Business(
                        id: business?.id,
                        logoPath: '',
                        name: _nameController.text,
                        owner: _ownerController.text,
                        address: _addressController.text,
                        phone: _phoneController.text,
                        website: _websiteController.text.isEmpty
                            ? null
                            : _websiteController.text,
                        paymentMethods: _paymentMethods,
                      );

                      if (business == null) {
                        await Provider.of<BusinessProvider>(
                          context,
                          listen: false,
                        ).addBusiness(newBusiness);
                      } else {
                        await Provider.of<BusinessProvider>(
                          context,
                          listen: false,
                        ).updateBusiness(newBusiness);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              business == null
                                  ? 'Bisnis ditambahkan'
                                  : 'Bisnis diupdate',
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
      },
    );
  }

  void _deleteBusiness(BusinessProvider provider, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bisnis'),
        content: const Text('Yakin ingin menghapus bisnis ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteBusiness(id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Bisnis dihapus')));
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
