import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/ledger_provider.dart';
import '../widgets/custom_text_field.dart';

class CashTransactionScreen extends StatefulWidget {
  final bool isCashIn;
  const CashTransactionScreen({super.key, this.isCashIn = true});

  @override
  State<CashTransactionScreen> createState() => _CashTransactionScreenState();
}

class _CashTransactionScreenState extends State<CashTransactionScreen> {
  final _amountCtl = TextEditingController();
  final _descCtl = TextEditingController();

  @override
  void dispose() {
    _amountCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_amountCtl.text.trim().isEmpty) return;

    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness == null) return;
    await context.read<LedgerProvider>().addEntry(
          businessId: bp.currentBusiness!.id,
          type: widget.isCashIn ? 'cash_in' : 'cash_out',
          amount: double.parse(_amountCtl.text.trim()),
          description: _descCtl.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isCashIn ? 'Cash In' : 'Cash Out')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (widget.isCashIn ? Colors.green : Colors.red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                widget.isCashIn ? Icons.payments : Icons.money_off,
                color: widget.isCashIn ? Colors.green : Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _amountCtl,
              label: 'Amount (Rs.)',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.money),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _descCtl,
              label: 'Description',
              prefixIcon: const Icon(Icons.note_outlined),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCashIn ? Colors.green.shade600 : Colors.red.shade600,
              ),
              child: Text(widget.isCashIn ? 'Add Cash In' : 'Add Cash Out'),
            ),
          ],
        ),
      ),
    );
  }
}
