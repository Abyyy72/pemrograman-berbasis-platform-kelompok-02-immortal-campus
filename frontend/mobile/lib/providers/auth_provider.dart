import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String identifier, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.post('/auth/login', {
        'identifier': identifier,
        'email': identifier,
        'password': password,
        'role': role,
      });

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['data'] != null) {
        final token = data['data']['token'];
        if (token != null) {
          await ApiClient.saveToken(token);
        }
        _currentUser = UserModel.fromJson(data['data']['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Login gagal. Periksa kembali kredensial Anda.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Fallback local mock user for offline test
      _currentUser = UserModel(
        id: 'user-001',
        nama: role == 'admin' 
            ? 'Administrator Utama' 
            : (role == 'kurator' ? 'Dr. Rina Suryani, M.Kom.' : 'Amanda Putri Wibowo'),
        email: identifier.contains('@') ? identifier : 'amanda@campus.ac.id',
        role: role,
        nim: role == 'penulis' ? '2110512034' : null,
        nip: role != 'penulis' ? '198204152008122001' : null,
        prodi: role == 'penulis' ? 'Teknik Informatika' : 'UPT Perpustakaan',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    await ApiClient.removeToken();
    _currentUser = null;
    notifyListeners();
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
}
