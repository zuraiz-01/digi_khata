import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplier_model.dart';
import '../providers/business_provider.dart';
import '../providers/supplier_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/search_widget.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final _searchCtl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  void _load() {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) {
      context.read<SupplierProvider>().loadSuppliers(bp.currentBusiness!.id);
    }
  }

  List<Supplier> _filtered(List<Supplier> suppliers) {
    if (_searchQuery.isEmpty) return suppliers;
    return suppliers
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || s.phone.contains(_searchQuery))
        .toList();
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
              try {
                final bp = context.read<BusinessProvider>();
                if (bp.currentBusiness == null) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('No business found. Create a business first.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }
                await context.read<SupplierProvider>().addSupplier(
                      businessId: bp.currentBusiness!.id,
                      name: nameCtl.text.trim(),
                      phone: phoneCtl.text.trim(),
                      address: addressCtl.text.trim(),
                      openingBalance: double.tryParse(balanceCtl.text.trim()) ?? 0,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
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
    final filtered = _filtered(sp.suppliers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: IconButton.filled(
              icon: const Icon(Icons.business_rounded),
              onPressed: _showAddDialog,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchWidget(
            controller: _searchCtl,
            hint: 'Search suppliers...',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          Expanded(
            child: sp.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('No suppliers found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.purple.withValues(alpha: 0.1),
                                    child: Text(s.name[0].toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 18)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        const SizedBox(height: 2),
                                        Text(s.phone.isNotEmpty ? s.phone : 'No phone',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  if (s.totalPayable > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('Rs. ${s.totalPayable.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
