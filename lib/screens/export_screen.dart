import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/auth_provider.dart';
import '../services/export_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _exportService = ExportService();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureBusiness());
  }

  Future<void> _ensureBusiness() async {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) return;
    if (bp.businesses.isEmpty) {
      final auth = context.read<AppAuthProvider>();
      if (auth.isLoggedIn) {
        try {
          await bp.loadBusinesses(auth.firebaseUser!.uid);
        } catch (_) {}
      }
    }
  }

  Future<void> _exportInvoices() async {
    setState(() => _isExporting = true);
    final bp = context.read<BusinessProvider>();
    final ip = context.read<InvoiceProvider>();
    if (bp.currentBusiness != null) {
      await ip.loadInvoices(bp.currentBusiness!.id);
      if (ip.invoices.isNotEmpty) {
        await _exportService.exportInvoicePdf(ip.invoices.first);
      }
    }
    if (mounted) setState(() => _isExporting = false);
  }

  Future<void> _exportCustomers() async {
    setState(() => _isExporting = true);
    final bp = context.read<BusinessProvider>();
    final cp = context.read<CustomerProvider>();
    if (bp.currentBusiness != null) {
      await cp.loadCustomers(bp.currentBusiness!.id);
      await _exportService.exportCustomersCsv(cp.customers);
    }
    if (mounted) setState(() => _isExporting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _exportCard(
              icon: Icons.receipt,
              title: 'Export Invoices (PDF)',
              subtitle: 'Download latest invoice as PDF',
              onTap: _exportInvoices,
              color: Colors.teal,
            ),
            const SizedBox(height: 12),
            _exportCard(
              icon: Icons.people,
              title: 'Export Customers (CSV)',
              subtitle: 'Download customer list as CSV',
              onTap: _exportCustomers,
              color: Colors.blue,
            ),
            if (_isExporting) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _exportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.download),
        onTap: onTap,
      ),
    );
  }
}
