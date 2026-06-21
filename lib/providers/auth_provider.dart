import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;
  String? get errorMessage => _errorMessage;

  AppAuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _firebaseUser = user;
    if (user != null) {
      _loadUserProfile(user.uid);
    } else {
      _userProfile = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    _userProfile = await _firestoreService.getUserProfile(uid);
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String fullName,
    required String businessName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      final user = UserProfile(
        uid: credential.user!.uid,
        fullName: fullName,
        businessName: businessName,
        phoneNumber: phoneNumber,
        email: email.trim(),
        createdAt: DateTime.now(),
      );
      await _firestoreService.saveUserProfile(user);
      _userProfile = user;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Signup failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userProfile = null;
    _firebaseUser = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
