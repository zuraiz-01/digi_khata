import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';

class BusinessProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Business> _businesses = [];
  Business? _currentBusiness;
  bool _isLoading = false;

  List<Business> get businesses => _businesses;
  Business? get currentBusiness => _currentBusiness;
  bool get isLoading => _isLoading;

  Future<void> loadBusinesses(String ownerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('businesses')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      _businesses = snapshot.docs.map((doc) => Business.fromMap(doc.data())).toList();
      _businesses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (_currentBusiness == null && _businesses.isNotEmpty) {
        _currentBusiness = _businesses.first;
      }
    } catch (e) {
      debugPrint('loadBusinesses error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBusiness({
    required String name,
    required String ownerId,
    String? phone,
    String? address,
  }) async {
    final docRef = _firestore.collection('businesses').doc();
    final business = Business(
      id: docRef.id,
      name: name,
      ownerId: ownerId,
      phone: phone,
      address: address,
      createdAt: DateTime.now(),
    );
    await docRef.set(business.toMap());
    _businesses.insert(0, business);
    _currentBusiness = business;
    notifyListeners();
  }

  void switchBusiness(String businessId) {
    _currentBusiness = _businesses.firstWhere((b) => b.id == businessId);
    notifyListeners();
  }
}
