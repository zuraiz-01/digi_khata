import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer_model.dart';
import '../providers/business_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/search_widget.dart';
import '../widgets/confirm_dialog.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
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
      context.read<CustomerProvider>().loadCustomers(bp.currentBusiness!.id);
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
      context.read<CustomerProvider>().loadCustomers(bp.currentBusiness!.id);
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

  List<Customer> _filtered(List<Customer> customers) {
    if (_searchQuery.isEmpty) return customers;
    return customers
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()) || c.phone.contains(_searchQuery))
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
        title: const Text('Add Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameCtl, label: 'Customer Name'),
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
                await context.read<CustomerProvider>().addCustomer(
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
    final cp = context.watch<CustomerProvider>();
    final filtered = _filtered(cp.customers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: IconButton.filled(
              icon: const Icon(Icons.person_add_alt_1),
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
            hint: 'Search customers...',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          Expanded(
            child: cp.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('No customers found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onLongPress: () async {
                                final bp = context.read<BusinessProvider>();
                                if (bp.currentBusiness == null) return;
                                final confirmed = await showConfirmDialog(
                                  context,
                                  title: 'Delete Customer',
                                  message: 'Are you sure you want to delete ${c.name}?',
                                );
                                if (confirmed && context.mounted) {
                                  context
                                      .read<CustomerProvider>()
                                      .deleteCustomer(bp.currentBusiness!.id, c.id);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
                                      child: Text(c.name[0].toUpperCase(),
                                          style: const TextStyle(
                                              color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 18)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c.name,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                          const SizedBox(height: 2),
                                          Text(c.phone.isNotEmpty ? c.phone : 'No phone',
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    if (c.totalUdhaar > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('Rs. ${c.totalUdhaar.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)),
                                      ),
                                  ],
                                ),
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
