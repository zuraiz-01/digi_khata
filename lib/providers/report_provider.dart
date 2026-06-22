import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _totalReceivable = 0;
  double _totalPayable = 0;
  double _monthlyCashIn = 0;
  double _monthlyCashOut = 0;
  int _totalCustomers = 0;
  int _totalSuppliers = 0;
  int _totalInvoices = 0;
  bool _isLoading = false;

  double get totalReceivable => _totalReceivable;
  double get totalPayable => _totalPayable;
  double get monthlyCashIn => _monthlyCashIn;
  double get monthlyCashOut => _monthlyCashOut;
  int get totalCustomers => _totalCustomers;
  int get totalSuppliers => _totalSuppliers;
  int get totalInvoices => _totalInvoices;
  bool get isLoading => _isLoading;

  Future<void> loadReports(String businessId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

      final futures = await Future.wait([
        _firestore.collection('businesses').doc(businessId).collection('customers').get(),
        _firestore.collection('businesses').doc(businessId).collection('suppliers').get(),
        _firestore.collection('businesses').doc(businessId).collection('invoices').get(),
        _firestore
            .collection('businesses')
            .doc(businessId)
            .collection('ledger')
            .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
            .get(),
      ]);

      final custSnap = futures[0];
      final suppSnap = futures[1];
      final invSnap = futures[2];
      final ledgerSnap = futures[3];

      _totalCustomers = custSnap.docs.length;
      _totalReceivable = 0;
      for (var doc in custSnap.docs) {
        _totalReceivable += (doc.data()['totalUdhaar'] ?? 0).toDouble();
      }

      _totalSuppliers = suppSnap.docs.length;
      _totalPayable = 0;
      for (var doc in suppSnap.docs) {
        _totalPayable += (doc.data()['totalPayable'] ?? 0).toDouble();
      }

      _totalInvoices = invSnap.docs.length;

      _monthlyCashIn = 0;
      _monthlyCashOut = 0;
      for (var doc in ledgerSnap.docs) {
        final type = doc.data()['type'] ?? '';
        final amount = (doc.data()['amount'] ?? 0).toDouble();
        if (type == 'cash_in' || type == 'udhaar_received' || type == 'payment_received') {
          _monthlyCashIn += amount;
        } else if (type == 'cash_out' || type == 'udhaar_given' || type == 'payment_made') {
          _monthlyCashOut += amount;
        }
      }
    } catch (e) {
      debugPrint('loadReports error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
