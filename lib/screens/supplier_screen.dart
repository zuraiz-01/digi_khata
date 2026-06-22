import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplier_model.dart';
import '../providers/business_provider.dart';
import '../providers/supplier_provider.dart';
import '../providers/auth_provider.dart';
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

  Future<void> _load() async {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) {
      context.read<SupplierProvider>().loadSuppliers(bp.currentBusiness!.id);
      return;
    }
    if (bp.businesses.isEmpty) {
      final auth = context.read<AppAuthProvider>();
      if (auth.isLoggedIn) {
        try {
          await bp.loadBusinesses(auth.firebaseUser!.uid);
        } catch (_) {}
      }
    }
    if (bp.currentBusiness != null && mounted) {
      context.read<SupplierProvider>().loadSuppliers(bp.currentBusiness!.id);
    }
  }

  Future<String?> _ensureBusiness() async {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) return bp.currentBusiness!.id;
    if (bp.businesses.isEmpty) {
      final auth = context.read<AppAuthProvider>();
      if (auth.isLoggedIn) {
        try {
          await bp.loadBusinesses(auth.firebaseUser!.uid);
        } catch (_) {}
      }
    }
    return bp.currentBusiness?.id;
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
                final businessId = await _ensureBusiness();
                if (businessId == null) {
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
                      businessId: businessId,
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
          IconButton(icon: const Icon(Icons.business), onPressed: _showAddDialog),
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
                    ? const Center(child: Text('No suppliers found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple.withValues(alpha: 0.1),
                                child: Text(s.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.purple)),
                              ),
                              title: Text(s.name),
                              subtitle: Text(s.phone.isNotEmpty ? s.phone : 'No phone'),
                              trailing: s.totalPayable > 0
                                  ? Text('Rs. ${s.totalPayable.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.red))
                                  : null,
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
