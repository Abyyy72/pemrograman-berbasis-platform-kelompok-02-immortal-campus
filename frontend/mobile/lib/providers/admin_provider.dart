import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AdminProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  final bool _isLoading = false;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  int get totalUsers => _users.length;
  int get totalPenulis => _users.where((u) => u.isPenulis).length;
  int get totalKurator => _users.where((u) => u.isKurator).length;
  int get totalAdmin => _users.where((u) => u.isAdmin).length;

  AdminProvider() {
    loadMockUsers();
  }

  void loadMockUsers() {
    _users = [
      UserModel(
        id: 'user-admin-001',
        nama: 'Administrator Utama Perpustakaan',
        email: 'admin@campus.ac.id',
        nip: 'ADMIN-001',
        prodi: 'UPT Perpustakaan & TI',
        role: 'admin',
      ),
      UserModel(
        id: 'user-002',
        nama: 'Dr. Rina Suryani, M.Kom.',
        email: 'rina.suryani@campus.ac.id',
        nip: '198204152008122001',
        prodi: 'UPT Perpustakaan',
        role: 'kurator',
      ),
      UserModel(
        id: 'user-kurator-002',
        nama: 'Budi Santoso, S.Sos., M.Lib.',
        email: 'budi.santoso@campus.ac.id',
        nip: '198805122014021003',
        prodi: 'UPT Perpustakaan',
        role: 'kurator',
      ),
      UserModel(
        id: 'user-kurator-003',
        nama: 'Dewi Rahayu, S.I.Pust.',
        email: 'dewi.rahayu@campus.ac.id',
        nip: '199203182019032008',
        prodi: 'UPT Perpustakaan',
        role: 'kurator',
      ),
      UserModel(
        id: 'user-001',
        nama: 'Amanda Putri Wibowo',
        email: 'amanda@campus.ac.id',
        nim: '2110512034',
        prodi: 'Teknik Informatika',
        role: 'penulis',
      ),
      UserModel(
        id: 'user-003',
        nama: 'Fajar Danuarta',
        email: 'fajar@campus.ac.id',
        nim: '2108561023',
        prodi: 'Sistem Informasi',
        role: 'penulis',
      ),
    ];
    notifyListeners();
  }

  void addKurator({
    required String nama,
    required String email,
    required String nip,
    required String prodi,
  }) {
    _users.insert(
      0,
      UserModel(
        id: 'user-kurator-${DateTime.now().millisecondsSinceEpoch}',
        nama: nama,
        email: email,
        nip: nip,
        prodi: prodi,
        role: 'kurator',
      ),
    );
    notifyListeners();
  }

  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}
