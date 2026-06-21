import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer_model.dart';
import '../providers/business_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/search_widget.dart';

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
    _load();
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  void _load() {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) {
      context.read<CustomerProvider>().loadCustomers(bp.currentBusiness!.id);
    }
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
              final bp = context.read<BusinessProvider>();
              await context.read<CustomerProvider>().addCustomer(
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
    final cp = context.watch<CustomerProvider>();
    final filtered = _filtered(cp.customers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: _showAddDialog),
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
                    ? const Center(child: Text('No customers found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                child: Text(c.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.blue)),
                              ),
                              title: Text(c.name),
                              subtitle: Text(c.phone.isNotEmpty ? c.phone : 'No phone'),
                              trailing: c.totalUdhaar > 0
                                  ? Text('Rs. ${c.totalUdhaar.toStringAsFixed(0)}',
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
