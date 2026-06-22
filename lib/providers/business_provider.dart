import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';

class BusinessProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Business> _businesses = [];
  Business? _currentBusiness;
  bool _isLoading = false;
  bool _hasError = false;

  List<Business> get businesses => _businesses;
  Business? get currentBusiness => _currentBusiness;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasError || _businesses.isNotEmpty;

  Future<void> loadBusinesses(String ownerId) async {
    if (_isLoading) return;
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('businesses')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      _businesses = snapshot.docs.map((doc) => Business.fromMap(doc.data())).toList();
      _businesses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (_businesses.isNotEmpty && _businesses.indexWhere((b) => b.id == _currentBusiness?.id) < 0) {
        _currentBusiness = _businesses.first;
      }
    } catch (e) {
      _hasError = true;
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
    _hasError = false;
    notifyListeners();
  }

  void switchBusiness(String businessId) {
    _currentBusiness = _businesses.firstWhere((b) => b.id == businessId);
    notifyListeners();
  }
}
