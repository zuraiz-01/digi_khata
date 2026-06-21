import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityProvider extends ChangeNotifier {
  bool _isPinEnabled = false;
  bool _isAuthenticated = false;

  bool get isPinEnabled => _isPinEnabled;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isPinEnabled = prefs.getBool('pin_enabled') ?? false;
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin', pin);
    await prefs.setBool('pin_enabled', true);
    _isPinEnabled = true;
    notifyListeners();
  }

  Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pin_enabled', false);
    await prefs.remove('app_pin');
    _isPinEnabled = false;
    notifyListeners();
  }

  Future<bool> validatePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('app_pin');
    return pin == stored;
  }

  void authenticate() {
    _isAuthenticated = true;
    notifyListeners();
  }
}
