import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ledger_entry_model.dart';

class LedgerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<LedgerEntry> _entries = [];
  bool _isLoading = false;

  List<LedgerEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> loadEntries(String businessId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('ledger')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _entries = snapshot.docs.map((doc) => LedgerEntry.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('loadEntries error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry({
    required String businessId,
    required String type,
    String? partyId,
    String? partyName,
    String partyType = '',
    required double amount,
    String description = '',
  }) async {
    final docRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('ledger')
        .doc();

    final entry = LedgerEntry(
      id: docRef.id,
      businessId: businessId,
      type: type,
      partyId: partyId,
      partyName: partyName,
      partyType: partyType,
      amount: amount,
      description: description,
      createdAt: DateTime.now(),
    );
    await docRef.set(entry.toMap());
    _entries.insert(0, entry);

    if (partyId != null && partyId.isNotEmpty) {
      await _updatePartyBalance(businessId, partyId, partyType, type, amount);
    }

    notifyListeners();
  }

  Future<void> _updatePartyBalance(
    String businessId,
    String partyId,
    String partyType,
    String type,
    double amount,
  ) async {
    final collection = partyType == 'customer' ? 'customers' : 'suppliers';
    final docRef = _firestore.collection('businesses').doc(businessId).collection(collection).doc(partyId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final field = partyType == 'customer' ? 'totalUdhaar' : 'totalPayable';
      final current = (doc.data()?[field] ?? 0).toDouble();

      if (type == 'udhaar_given' || type == 'payment_made') {
        transaction.update(docRef, {field: current + amount});
      } else if (type == 'udhaar_received' || type == 'payment_received') {
        transaction.update(docRef, {field: current - amount});
      }
    });
  }
}
