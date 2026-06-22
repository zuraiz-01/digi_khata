import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/business_provider.dart';
import '../providers/auth_provider.dart';
import '../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _backupService = BackupService();
  bool _isProcessing = false;

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

  Future<void> _exportBackup() async {
    setState(() => _isProcessing = true);
    final bp = context.read<BusinessProvider>();
    final messenger = ScaffoldMessenger.of(context);
    if (bp.currentBusiness != null) {
      try {
        await _backupService.exportBackup(bp.currentBusiness!.id);
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Backup exported successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() => _isProcessing = true);
    final bp = context.read<BusinessProvider>();
    final messenger = ScaffoldMessenger.of(context);
    if (bp.currentBusiness != null) {
      try {
        await _backupService.importBackup(bp.currentBusiness!.id, File(result.files.single.path!));
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Backup restored successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.backup, color: Colors.blue),
                ),
                title: const Text('Export Backup'),
                subtitle: const Text('Save all data as JSON file'),
                trailing: const Icon(Icons.download),
                onTap: _isProcessing ? null : _exportBackup,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restore, color: Colors.orange),
                ),
                title: const Text('Restore Backup'),
                subtitle: const Text('Import data from JSON file'),
                trailing: const Icon(Icons.upload),
                onTap: _isProcessing ? null : _importBackup,
              ),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
