import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Customer> _customers = [];
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> loadCustomers(String businessId) async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .get();

    _customers = snapshot.docs.map((doc) => Customer.fromMap(doc.data())).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer({
    required String businessId,
    required String name,
    String phone = '',
    String address = '',
    double openingBalance = 0,
  }) async {
    final docRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('customers')
        .doc();

    final customer = Customer(
      id: docRef.id,
      businessId: businessId,
      name: name,
      phone: phone,
      address: address,
      openingBalance: openingBalance,
      createdAt: DateTime.now(),
    );
    await docRef.set(customer.toMap());
    _customers.insert(0, customer);
    notifyListeners();
  }

  Future<void> deleteCustomer(String businessId, String customerId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('customers')
        .doc(customerId)
        .delete();
    _customers.removeWhere((c) => c.id == customerId);
    notifyListeners();
  }
}
