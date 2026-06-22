import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../providers/staff_provider.dart';
import '../widgets/custom_text_field.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStaff());
  }

  void _loadStaff() {
    final bp = context.read<BusinessProvider>();
    if (bp.currentBusiness != null) {
      context.read<StaffProvider>().loadStaff(bp.currentBusiness!.id);
    }
  }

  void _showAddStaffDialog() {
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();
    String selectedRole = 'viewer';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Staff Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: nameCtl, label: 'Full Name'),
            const SizedBox(height: 12),
            CustomTextField(controller: emailCtl, label: 'Email'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'accountant', child: Text('Accountant')),
                DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
              ],
              onChanged: (v) => selectedRole = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtl.text.isEmpty || emailCtl.text.isEmpty) return;
              final bp = context.read<BusinessProvider>();
              if (bp.currentBusiness == null) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('No business selected'), backgroundColor: Colors.red),
                  );
                }
                return;
              }
              await context.read<StaffProvider>().addStaff(
                    businessId: bp.currentBusiness!.id,
                    name: nameCtl.text.trim(),
                    email: emailCtl.text.trim(),
                    role: selectedRole,
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
    final sp = context.watch<StaffProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddStaffDialog,
          ),
        ],
      ),
      body: sp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sp.staffList.isEmpty
              ? const Center(child: Text('No staff members yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sp.staffList.length,
                  itemBuilder: (context, index) {
                    final staff = sp.staffList[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
                          child: Text(
                            staff.name[0].toUpperCase(),
                            style: const TextStyle(color: Color(0xFF1565C0)),
                          ),
                        ),
                        title: Text(staff.name),
                        subtitle: Text('${staff.email}  •  ${staff.role.toUpperCase()}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            final bp = context.read<BusinessProvider>();
                            if (bp.currentBusiness == null) return;
                            context.read<StaffProvider>().removeStaff(
                                  bp.currentBusiness!.id,
                                  staff.id,
                                );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
