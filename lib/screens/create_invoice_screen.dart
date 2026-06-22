import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice_model.dart';
import '../providers/business_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/invoice_provider.dart';
import '../widgets/custom_text_field.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _invNumCtl = TextEditingController();
  String _selectedCustomerId = '';
  String _selectedCustomerName = '';
  final List<_ItemRow> _items = [];

  @override
  void initState() {
    super.initState();
    _invNumCtl.text = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    _addItem();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCustomers());
  }

  void _loadCustomers() {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) {
      context.read<CustomerProvider>().loadCustomers(bp.currentBusiness!.id);
    }
  }

  @override
  void dispose() {
    _invNumCtl.dispose();
    for (var item in _items) {
      item.descCtl.dispose();
      item.qtyCtl.dispose();
      item.rateCtl.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() => _items.add(_ItemRow(TextEditingController(), TextEditingController(), TextEditingController())));
  }

  Future<void> _save() async {
    final items = _items
        .where((i) => i.descCtl.text.trim().isNotEmpty && i.rateCtl.text.trim().isNotEmpty)
        .map((i) => InvoiceItem(
              description: i.descCtl.text.trim(),
              quantity: double.tryParse(i.qtyCtl.text.trim()) ?? 1,
              rate: double.parse(i.rateCtl.text.trim()),
            ))
        .toList();

    if (items.isEmpty) return;

    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness == null) return;
    await context.read<InvoiceProvider>().createInvoice(
          businessId: bp.currentBusiness!.id,
          customerId: _selectedCustomerId.isNotEmpty ? _selectedCustomerId : null,
          customerName: _selectedCustomerName.isNotEmpty ? _selectedCustomerName : null,
          invoiceNumber: _invNumCtl.text.trim(),
          items: items,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(controller: _invNumCtl, label: 'Invoice Number'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: null,
              decoration: const InputDecoration(labelText: 'Customer (optional)'),
              items: cp.customers
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (v) {
                _selectedCustomerId = v!;
                _selectedCustomerName = cp.customers.firstWhere((c) => c.id == v).name;
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Item'),
                  onPressed: _addItem,
                ),
              ],
            ),
            ..._items.asMap().entries.map((entry) {
              final i = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      CustomTextField(controller: i.descCtl, label: 'Description'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: i.qtyCtl,
                              label: 'Qty',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: i.rateCtl,
                              label: 'Rate',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save Invoice')),
          ],
        ),
      ),
    );
  }
}

class _ItemRow {
  final TextEditingController descCtl;
  final TextEditingController qtyCtl;
  final TextEditingController rateCtl;
  _ItemRow(this.descCtl, this.qtyCtl, this.rateCtl);
}
