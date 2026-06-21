import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';
import '../widgets/custom_text_field.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createBusiness() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AppAuthProvider>();
      final bp = context.read<BusinessProvider>();
      await bp.createBusiness(
        name: _nameController.text.trim(),
        ownerId: auth.firebaseUser!.uid,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: Color(0xFF1565C0),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Setup Your Business',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add your business details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Business Name',
                    hint: 'Enter business name',
                    prefixIcon: const Icon(Icons.store_outlined),
                    validator: (v) => v == null || v.isEmpty ? 'Business name required' : null,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Business Phone',
                    hint: 'Enter business phone',
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _addressController,
                    label: 'Business Address',
                    hint: 'Enter business address',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _createBusiness,
                    child: const Text('Continue to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
