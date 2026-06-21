import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff_model.dart';

class StaffProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<StaffMember> _staffList = [];
  bool _isLoading = false;

  List<StaffMember> get staffList => _staffList;
  bool get isLoading => _isLoading;

  Future<void> loadStaff(String businessId) async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('staff')
        .orderBy('addedAt', descending: true)
        .get();

    _staffList = snapshot.docs.map((doc) => StaffMember.fromMap(doc.data())).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStaff({
    required String businessId,
    required String name,
    required String email,
    required String role,
  }) async {
    final docRef = _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('staff')
        .doc();

    final staff = StaffMember(
      id: docRef.id,
      businessId: businessId,
      name: name,
      email: email,
      role: role,
      addedAt: DateTime.now(),
    );
    await docRef.set(staff.toMap());
    _staffList.insert(0, staff);
    notifyListeners();
  }

  Future<void> removeStaff(String businessId, String staffId) async {
    await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('staff')
        .doc(staffId)
        .delete();
    _staffList.removeWhere((s) => s.id == staffId);
    notifyListeners();
  }
}
