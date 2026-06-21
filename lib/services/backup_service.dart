import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> exportBackup(String businessId) async {
    final data = <String, dynamic>{};

    final collections = ['customers', 'suppliers', 'ledger', 'invoices'];
    for (final col in collections) {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection(col)
          .get();
      data[col] = snap.docs.map((doc) {
        final d = doc.data();
        d['_id'] = doc.id;
        return d;
      }).toList();
    }

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/digi_khata_backup.json');
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)], text: 'Digi Khata Backup');
  }

  Future<void> importBackup(String businessId, File file) async {
    final json = await file.readAsString();
    final data = jsonDecode(json) as Map<String, dynamic>;

    final collections = ['customers', 'suppliers', 'ledger', 'invoices'];
    for (final col in collections) {
      if (data[col] == null) continue;
      for (final item in data[col] as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        final id = map.remove('_id') ?? _firestore.collection('tmp').doc().id;
        await _firestore
            .collection('businesses')
            .doc(businessId)
            .collection(col)
            .doc(id as String)
            .set(map);
      }
    }
  }
}
