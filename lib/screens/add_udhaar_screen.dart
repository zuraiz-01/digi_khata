import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/supplier_provider.dart';
import '../providers/ledger_provider.dart';
import '../widgets/custom_text_field.dart';

class AddUdhaarScreen extends StatefulWidget {
  const AddUdhaarScreen({super.key});

  @override
  State<AddUdhaarScreen> createState() => _AddUdhaarScreenState();
}

class _AddUdhaarScreenState extends State<AddUdhaarScreen> {
  final _amountCtl = TextEditingController();
  final _descCtl = TextEditingController();
  String _partyType = 'customer';
  String _selectedPartyId = '';
  String _selectedPartyName = '';
  bool _isUdhaarGiven = true;

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  void _loadParties() {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) {
      context.read<CustomerProvider>().loadCustomers(bp.currentBusiness!.id);
      context.read<SupplierProvider>().loadSuppliers(bp.currentBusiness!.id);
    }
  }

  @override
  void dispose() {
    _amountCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedPartyId.isEmpty || _amountCtl.text.trim().isEmpty) return;

    final bp = context.read<BusinessProvider>();
    final type = _partyType == 'customer'
        ? (_isUdhaarGiven ? 'udhaar_given' : 'udhaar_received')
        : (_isUdhaarGiven ? 'payment_made' : 'payment_received');

    await context.read<LedgerProvider>().addEntry(
          businessId: bp.currentBusiness!.id,
          type: type,
          partyId: _selectedPartyId,
          partyName: _selectedPartyName,
          partyType: _partyType,
          amount: double.parse(_amountCtl.text.trim()),
          description: _descCtl.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();
    final sp = context.watch<SupplierProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Udhaar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Party Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _choiceChip('Customer', _partyType == 'customer', () => setState(() => _partyType = 'customer')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _choiceChip('Supplier', _partyType == 'supplier', () => setState(() => _partyType = 'supplier')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Select Party', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _partyType == 'customer'
                ? _partyDropdown(cp.customers.map((c) => MapEntry(c.id, c.name)).toList())
                : _partyDropdown(sp.suppliers.map((s) => MapEntry(s.id, s.name)).toList()),
            const SizedBox(height: 20),
            const Text('Udhaar Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _choiceChip(
                    _partyType == 'customer' ? 'You Gave' : 'You Paid',
                    _isUdhaarGiven,
                    () => setState(() => _isUdhaarGiven = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _choiceChip(
                    _partyType == 'customer' ? 'You Got' : 'You Received',
                    !_isUdhaarGiven,
                    () => setState(() => _isUdhaarGiven = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _amountCtl,
              label: 'Amount (Rs.)',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.money),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _descCtl,
              label: 'Description (optional)',
              prefixIcon: const Icon(Icons.note_outlined),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Udhaar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1565C0) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _partyDropdown(List<MapEntry<String, String>> items) {
    return DropdownButtonFormField<String>(
      initialValue: null,
      decoration: const InputDecoration(labelText: 'Select'),
      items: items.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
      onChanged: (v) {
        setState(() {
          _selectedPartyId = v!;
          _selectedPartyName = items.firstWhere((e) => e.key == v).value;
        });
      },
    );
  }
}
