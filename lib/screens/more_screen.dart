import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _moreItems.length,
                itemBuilder: (context, index) {
                  final item = _moreItems[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pushNamed(context, item.route),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item.icon, color: item.color, size: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              textAlign: TextAlign.center,
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
      ),
    );
  }
}

class _MoreItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _MoreItem(this.label, this.icon, this.color, this.route);
}

final List<_MoreItem> _moreItems = [
  const _MoreItem('Invoices', Icons.receipt_rounded, Color(0xFF1565C0), '/invoices'),
  const _MoreItem('Add Udhaar', Icons.receipt_long_rounded, Color(0xFFFF6F00), '/add-udhaar'),
  const _MoreItem('Cash In', Icons.payments_rounded, Color(0xFF2E7D32), '/cash-in'),
  const _MoreItem('Cash Out', Icons.money_off_rounded, Color(0xFFC62828), '/cash-out'),
  const _MoreItem('WhatsApp', Icons.chat_rounded, Color(0xFF25D366), '/whatsapp-reminder'),
  const _MoreItem('Create Invoice', Icons.post_add_rounded, Color(0xFF6A1B9A), '/create-invoice'),
  const _MoreItem('Export', Icons.file_download_rounded, Color(0xFF00695C), '/export'),
  const _MoreItem('Backup', Icons.backup_rounded, Color(0xFF37474F), '/backup'),
  const _MoreItem('Staff', Icons.group_rounded, Color(0xFF4E342E), '/staff'),
  const _MoreItem('Security', Icons.lock_rounded, Color(0xFFD84315), '/security'),
];
