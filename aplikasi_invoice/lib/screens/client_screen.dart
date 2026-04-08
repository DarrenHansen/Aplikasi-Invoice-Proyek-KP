import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/client.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).loadClients();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Klien'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ClientProvider>(
        builder: (context, provider, child) {
          if (provider.clients.isEmpty) {
            return _buildEmptyState();
          }
          return _buildClientList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientDialog(),
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
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum ada klien',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Tambah Klien',
            onPressed: () => _showClientDialog(),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildClientList(ClientProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.clients.length,
      itemBuilder: (context, index) {
        final client = provider.clients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, color: Colors.blue.shade700),
            ),
            title: Text(
              client.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.phone),
                if (client.email != null) Text(client.email!),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showClientDialog(client: client),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteClient(provider, client.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClientDialog({Client? client}) {
    if (client != null) {
      _nameController.text = client.name;
      _phoneController.text = client.phone;
      _emailController.text = client.email ?? '';
    } else {
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(client == null ? 'Tambah Klien' : 'Edit Klien'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Nama',
                  controller: _nameController,
                  prefixIcon: Icons.person,
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
                  label: 'Email',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
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
                  final newClient = Client(
                    id: client?.id,
                    name: _nameController.text,
                    phone: _phoneController.text,
                    email: _emailController.text.isEmpty
                        ? null
                        : _emailController.text,
                  );

                  if (client == null) {
                    await Provider.of<ClientProvider>(
                      context,
                      listen: false,
                    ).addClient(newClient);
                  } else {
                    await Provider.of<ClientProvider>(
                      context,
                      listen: false,
                    ).updateClient(newClient);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          client == null
                              ? 'Klien ditambahkan'
                              : 'Klien diupdate',
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

  void _deleteClient(ClientProvider provider, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Klien'),
        content: const Text('Yakin ingin menghapus klien ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteClient(id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Klien dihapus')));
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
