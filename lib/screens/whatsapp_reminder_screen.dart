import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/business_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/auth_provider.dart';
import '../models/customer_model.dart';

class WhatsAppReminderScreen extends StatefulWidget {
  const WhatsAppReminderScreen({super.key});

  @override
  State<WhatsAppReminderScreen> createState() => _WhatsAppReminderScreenState();
}

class _WhatsAppReminderScreenState extends State<WhatsAppReminderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCustomers());
  }

  Future<void> _loadCustomers() async {
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

  Future<void> _sendReminder(Customer customer) async {
    final businessName = context.read<BusinessProvider>().currentBusiness?.name ?? 'Business';
    final message = 'Assalam o Alaikum ${customer.name},\n'
        'This is a reminder from $businessName regarding your outstanding balance of '
        'Rs. ${customer.totalUdhaar.toStringAsFixed(0)}.\n'
        'Kindly clear your dues at your earliest convenience.\n'
        'Thank you!';

    final encoded = Uri.encodeComponent(message);
    final url = 'https://wa.me/${customer.phone}?text=$encoded';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();
    final customersWithUdhaar = cp.customers.where((c) => c.totalUdhaar > 0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('WhatsApp Reminder')),
      body: customersWithUdhaar.isEmpty
          ? const Center(child: Text('No customers with outstanding balance'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: customersWithUdhaar.length,
              itemBuilder: (context, index) {
                final c = customersWithUdhaar[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      child: const Icon(Icons.chat, color: Colors.green),
                    ),
                    title: Text(c.name),
                    subtitle: Text('Rs. ${c.totalUdhaar.toStringAsFixed(0)}'),
                    trailing: c.phone.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.send, color: Colors.green),
                            onPressed: () => _sendReminder(c),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
