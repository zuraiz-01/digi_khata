import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice_model.dart';
import '../providers/business_provider.dart';
import '../providers/invoice_provider.dart';
import '../widgets/search_widget.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
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
      context.read<InvoiceProvider>().loadInvoices(bp.currentBusiness!.id);
    }
  }

  List<Invoice> _filtered(List<Invoice> invoices) {
    if (_searchQuery.isEmpty) return invoices;
    return invoices.where((inv) {
      final q = _searchQuery.toLowerCase();
      return inv.invoiceNumber.toLowerCase().contains(q) ||
          (inv.customerName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ip = context.watch<InvoiceProvider>();
    final filtered = _filtered(ip.invoices);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/create-invoice').then((_) => _load()),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchWidget(
            controller: _searchCtl,
            hint: 'Search invoices...',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          Expanded(
            child: ip.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No invoices found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final inv = filtered[index];
                          return Card(
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _statusColor(inv.status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.receipt, color: _statusColor(inv.status)),
                              ),
                              title: Text('#${inv.invoiceNumber}'),
                              subtitle: Text(inv.customerName ?? 'Walk-in'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Rs. ${inv.totalAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(inv.status.toUpperCase(),
                                      style:
                                          TextStyle(fontSize: 11, color: _statusColor(inv.status))),
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
