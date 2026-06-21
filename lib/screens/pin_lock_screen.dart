import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _pinCtl = TextEditingController();
  final _newPinCtl = TextEditingController();
  final _confirmPinCtl = TextEditingController();
  bool _isSettingPin = false;
  bool _showError = false;
  final _localAuth = LocalAuthentication();

  @override
  void dispose() {
    _pinCtl.dispose();
    _newPinCtl.dispose();
    _confirmPinCtl.dispose();
    super.dispose();
  }

  Future<void> _authenticateWithBiometrics() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    if (canCheck) {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Digi Khata',
      );
      if (authenticated && mounted) {
        context.read<SecurityProvider>().authenticate();
      }
    }
  }

  Future<void> _validatePin() async {
    final sp = context.read<SecurityProvider>();
    final isValid = await sp.validatePin(_pinCtl.text.trim());
    if (isValid) {
      sp.authenticate();
    } else {
      setState(() => _showError = true);
    }
  }

  Future<void> _savePin() async {
    if (_newPinCtl.text.trim().length < 4) return;
    if (_newPinCtl.text.trim() != _confirmPinCtl.text.trim()) return;

    await context.read<SecurityProvider>().setPin(_newPinCtl.text.trim());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SecurityProvider>();

    if (_isSettingPin) {
      return _buildSetupPinScreen();
    }

    if (sp.isPinEnabled && !sp.isAuthenticated) {
      return _buildUnlockScreen();
    }

    return _buildSettingsScreen(sp);
  }

  Widget _buildUnlockScreen() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Color(0xFF1565C0)),
                const SizedBox(height: 20),
                const Text('Enter PIN', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _pinCtl,
                  obscureText: true,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    errorText: _showError ? 'Invalid PIN' : null,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _validatePin, child: const Text('Unlock')),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _authenticateWithBiometrics,
                  child: const Text('Use Fingerprint'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsScreen(SecurityProvider sp) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('App Lock (PIN)'),
                subtitle: Text(sp.isPinEnabled ? 'PIN is enabled' : 'Set a PIN to lock the app'),
                value: sp.isPinEnabled,
                onChanged: (v) {
                  if (v) {
                    setState(() => _isSettingPin = true);
                  } else {
                    sp.disablePin();
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Biometric Auth'),
                subtitle: const Text('Use fingerprint to unlock'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _authenticateWithBiometrics,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupPinScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pin, size: 48, color: Color(0xFF1565C0)),
            const SizedBox(height: 20),
            TextField(
              controller: _newPinCtl,
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'New PIN (4-6 digits)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPinCtl,
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                errorText: _confirmPinCtl.text.isNotEmpty &&
                        _newPinCtl.text != _confirmPinCtl.text
                    ? 'PINs do not match'
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _savePin, child: const Text('Save PIN')),
          ],
        ),
      ),
    );
  }
}
