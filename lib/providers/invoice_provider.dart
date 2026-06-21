import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice_model.dart';

class InvoiceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Invoice> _invoices = [];
  bool _isLoading = false;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;

  Future<void> loadInvoices(String businessId) async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('invoices')
        .orderBy('createdAt', descending: true)
        .get();

    _invoices = snapshot.docs.map((doc) => Invoice.fromMap(doc.data())).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createInvoice({
    required String businessId,
    String? customerId,
    String? customerName,
    required String invoiceNumber,
    required List<InvoiceItem> items,
  }) async {
    final docRef = _firestore.collection('businesses').doc(businessId).collection('invoices').doc();
    final total = items.fold<double>(0, (s, item) => s + item.amount);

    final invoice = Invoice(
      id: docRef.id,
      businessId: businessId,
      customerId: customerId,
      customerName: customerName,
      invoiceNumber: invoiceNumber,
      items: items,
      totalAmount: total,
      createdAt: DateTime.now(),
    );
    await docRef.set(invoice.toMap());
    _invoices.insert(0, invoice);
    notifyListeners();
  }

  Future<void> updateInvoiceStatus(String businessId, String invoiceId, String status) async {
    await _firestore.collection('businesses').doc(businessId).collection('invoices').doc(invoiceId).update({
      'status': status,
    });
    final idx = _invoices.indexWhere((i) => i.id == invoiceId);
    if (idx != -1) {
      final updated = _invoices[idx];
      _invoices[idx] = Invoice(
        id: updated.id,
        businessId: updated.businessId,
        customerId: updated.customerId,
        customerName: updated.customerName,
        invoiceNumber: updated.invoiceNumber,
        items: updated.items,
        totalAmount: updated.totalAmount,
        status: status,
        createdAt: updated.createdAt,
      );
      notifyListeners();
    }
  }
}
