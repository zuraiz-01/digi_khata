import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/report_provider.dart';
import '../widgets/summary_card.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) {
      context.read<ReportProvider>().loadReports(bp.currentBusiness!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: rp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Receivable',
                          amount: 'Rs. ${rp.totalReceivable.toStringAsFixed(0)}',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Payable',
                          amount: 'Rs. ${rp.totalPayable.toStringAsFixed(0)}',
                          icon: Icons.trending_down,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('This Month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Cash In',
                          amount: 'Rs. ${rp.monthlyCashIn.toStringAsFixed(0)}',
                          icon: Icons.arrow_downward,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'Cash Out',
                          amount: 'Rs. ${rp.monthlyCashOut.toStringAsFixed(0)}',
                          icon: Icons.arrow_upward,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        _statRow('Total Customers', '${rp.totalCustomers}', Icons.people, Colors.blue),
                        const Divider(height: 1),
                        _statRow('Total Suppliers', '${rp.totalSuppliers}', Icons.business, Colors.purple),
                        const Divider(height: 1),
                        _statRow('Total Invoices', '${rp.totalInvoices}', Icons.receipt, Colors.teal),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statRow(String label, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
