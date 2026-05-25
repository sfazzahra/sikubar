import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool isLoading = false;
  bool isLoggedIn = false;
  Map<String, dynamic>? user;
  String? error;

  AuthProvider() {
    _checkLoginStatus();
  }

  String? get role => user?['role'];
  bool get isWarga => role == 'warga';
  bool get isAdmin => role == 'admin';

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');
    if (token != null && userData != null) {
      user = jsonDecode(userData);
      isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> loginWarga(String nik, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await _api.loginWarga(nik, password);
      await _saveSession(res['data']['token'], res['data']['user']);
      user = res['data']['user'];
      isLoggedIn = true;
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Tidak dapat terhubung ke server.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginStaff(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await _api.loginStaff(email, password);
      await _saveSession(res['data']['token'], res['data']['user']);
      user = res['data']['user'];
      isLoggedIn = true;
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Tidak dapat terhubung ke server.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.logout(isWarga: isWarga);
    user = null;
    isLoggedIn = false;
    notifyListeners();
  }

  Future<void> _saveSession(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(userData));
  }
}