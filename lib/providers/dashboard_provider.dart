import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ledger_entry_model.dart';

class DashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _totalReceivable = 0;
  double _totalPayable = 0;
  double _todayCashIn = 0;
  double _todayCashOut = 0;
  List<LedgerEntry> _recentTransactions = [];
  bool _isLoading = false;

  double get totalReceivable => _totalReceivable;
  double get totalPayable => _totalPayable;
  double get todayCashIn => _todayCashIn;
  double get todayCashOut => _todayCashOut;
  List<LedgerEntry> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData(String businessId) async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadReceivablePayable(businessId),
      _loadTodayCash(businessId),
      _loadRecentTransactions(businessId),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadReceivablePayable(String businessId) async {
    final custSnap = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('customers')
        .get();

    _totalReceivable = 0;
    for (var doc in custSnap.docs) {
      _totalReceivable += (doc.data()['totalUdhaar'] ?? 0).toDouble();
    }

    final suppSnap = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('suppliers')
        .get();

    _totalPayable = 0;
    for (var doc in suppSnap.docs) {
      _totalPayable += (doc.data()['totalPayable'] ?? 0).toDouble();
    }
  }

  Future<void> _loadTodayCash(String businessId) async {
    final startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final snap = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('ledger')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .get();

    _todayCashIn = 0;
    _todayCashOut = 0;
    for (var doc in snap.docs) {
      final type = doc.data()['type'] ?? '';
      final amount = (doc.data()['amount'] ?? 0).toDouble();
      if (type == 'cash_in' || type == 'udhaar_received' || type == 'payment_received') {
        _todayCashIn += amount;
      } else if (type == 'cash_out' || type == 'udhaar_given' || type == 'payment_made') {
        _todayCashOut += amount;
      }
    }
  }

  Future<void> _loadRecentTransactions(String businessId) async {
    final snap = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('ledger')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    _recentTransactions = snap.docs.map((doc) => LedgerEntry.fromMap(doc.data())).toList();
  }
}
