import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier_model.dart';

class SupplierProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Supplier> _suppliers = [];
  bool _isLoading = false;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;

  Future<void> loadSuppliers(String businessId) async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('suppliers')
        .orderBy('createdAt', descending: true)
        .get();

    _suppliers = snapshot.docs.map((doc) => Supplier.fromMap(doc.data())).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSupplier({
    required String businessId,
    required String name,
    String phone = '',
    String address = '',
    double openingBalance = 0,
  }) async {
    final docRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('suppliers')
        .doc();

    final supplier = Supplier(
      id: docRef.id,
      businessId: businessId,
      name: name,
      phone: phone,
      address: address,
      openingBalance: openingBalance,
      totalPayable: openingBalance,
      createdAt: DateTime.now(),
    );
    await docRef.set(supplier.toMap());
    _suppliers.insert(0, supplier);
    notifyListeners();
  }

  Future<void> deleteSupplier(String businessId, String supplierId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('suppliers')
        .doc(supplierId)
        .delete();
    _suppliers.removeWhere((s) => s.id == supplierId);
    notifyListeners();
  }
}
