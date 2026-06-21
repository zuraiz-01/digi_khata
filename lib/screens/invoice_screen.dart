import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/invoice_provider.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) {
      context.read<InvoiceProvider>().loadInvoices(bp.currentBusiness!.id);
    }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.pushNamed(context, '/create-invoice').then((_) => _load()),
          ),
        ],
      ),
      body: ip.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ip.invoices.isEmpty
              ? const Center(child: Text('No invoices yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ip.invoices.length,
                  itemBuilder: (context, index) {
                    final inv = ip.invoices[index];
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
                                style: TextStyle(fontSize: 11, color: _statusColor(inv.status))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
