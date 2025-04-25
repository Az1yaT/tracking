import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_application/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  String? _userId;
  String _role = '';
  String _username = '';

  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;
  String get userId => _userId ?? '';
  String get username => _username;
  String get token => _token ?? '';

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _role = prefs.getString('role') ?? '';
    _username = prefs.getString('username') ?? '';
    _isLoggedIn = _token != null;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      prefs.setString('token', _token!);
      prefs.setString('userId', _userId!);
      prefs.setString('role', _role);
      prefs.setString('username', _username);
    } else {
      prefs.remove('token');
      prefs.remove('userId');
      prefs.remove('role');
      prefs.remove('username');
    }
  }

  Future<bool> login(ApiService apiService, String username, String password) async {
    try {
      final response = await apiService.login(username, password);
      _token = response['token'];
      _userId = response['userId'];
      _role = response['role'];
      _username = username;
      _isLoggedIn = true;
      
      // Обновляем токен в заголовках API
      apiService.updateAuthHeader(_token!);
      await _saveToStorage();
      
      notifyListeners();
      return true;
    } catch (e) {
      _isLoggedIn = false;
      _token = null;
      _userId = null;
      _role = '';
      _username = '';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _userId = null;
    _role = '';
    _username = '';
    await _saveToStorage();
    notifyListeners();
  }

  bool hasAccess(String requiredRole) {
    return _isLoggedIn && (_role == requiredRole || requiredRole == 'any');
  }
}