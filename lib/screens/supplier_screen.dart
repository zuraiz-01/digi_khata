import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/supplier_provider.dart';
import '../widgets/custom_text_field.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) {
      context.read<SupplierProvider>().loadSuppliers(bp.currentBusiness!.id);
    }
  }

  void _showAddDialog() {
    final nameCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    final addressCtl = TextEditingController();
    final balanceCtl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameCtl, label: 'Supplier Name'),
              const SizedBox(height: 10),
              CustomTextField(controller: phoneCtl, label: 'Phone', keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              CustomTextField(controller: addressCtl, label: 'Address'),
              const SizedBox(height: 10),
              CustomTextField(
                controller: balanceCtl,
                label: 'Opening Balance (Rs.)',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtl.text.trim().isEmpty) return;
              final bp = context.read<BusinessProvider>();
              await context.read<SupplierProvider>().addSupplier(
                    businessId: bp.currentBusiness!.id,
                    name: nameCtl.text.trim(),
                    phone: phoneCtl.text.trim(),
                    address: addressCtl.text.trim(),
                    openingBalance: double.tryParse(balanceCtl.text.trim()) ?? 0,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SupplierProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(icon: const Icon(Icons.business), onPressed: _showAddDialog),
        ],
      ),
      body: sp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sp.suppliers.isEmpty
              ? const Center(child: Text('No suppliers yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sp.suppliers.length,
                  itemBuilder: (context, index) {
                    final s = sp.suppliers[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.withValues(alpha: 0.1),
                          child: Text(s.name[0].toUpperCase(), style: const TextStyle(color: Colors.purple)),
                        ),
                        title: Text(s.name),
                        subtitle: Text(s.phone.isNotEmpty ? s.phone : 'No phone'),
                        trailing: s.totalPayable > 0
                            ? Text(
                                'Rs. ${s.totalPayable.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
