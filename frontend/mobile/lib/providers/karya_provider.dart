import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/karya_model.dart';

class KaryaProvider extends ChangeNotifier {
  List<KaryaModel> _karyaList = [];
  bool _isLoading = false;
  String _selectedProdi = 'Semua';
  String _searchQuery = '';

  List<KaryaModel> get karyaList => _karyaList;
  bool get isLoading => _isLoading;
  String get selectedProdi => _selectedProdi;
  String get searchQuery => _searchQuery;

  List<KaryaModel> get filteredKaryaList {
    return _karyaList.where((k) {
      final matchesSearch = _searchQuery.isEmpty ||
          k.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          k.penulis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          k.kataKunci.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesProdi = _selectedProdi == 'Semua' || k.prodi == _selectedProdi;

      return matchesSearch && matchesProdi;
    }).toList();
  }

  List<KaryaModel> get myWorks {
    return _karyaList;
  }

  List<KaryaModel> get curationQueue {
    return _karyaList.where((k) => k.status == 'Diajukan' || k.status == 'Dalam Review').toList();
  }

  KaryaProvider() {
    loadMockKarya();
    fetchKarya();
  }

  void setFilterProdi(String prodi) {
    _selectedProdi = prodi;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchKarya() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient.get('/karya');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] != null && data['data'] is List) {
          _karyaList = (data['data'] as List).map((k) => KaryaModel.fromJson(k)).toList();
        }
      }
    } catch (_) {
      // Mock data retained
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMockKarya() {
    _karyaList = [
      KaryaModel(
        id: '2024-819',
        judul: 'Penerapan Deep Learning Convolutional Neural Network untuk Deteksi Dini Hama Padi Berbasis Mobile',
        penulis: 'Amanda Putri Wibowo',
        nim: '2110512034',
        pembimbing: 'Dr. Eng. Hendra Sucipto, M.T.',
        jenis: 'skripsi',
        jenisLabel: 'Skripsi S-1',
        prodi: 'Teknik Informatika',
        tahun: 2024,
        abstrak: 'Penelitian ini merancang arsitektur MobileNetV3 yang dioptimasi untuk mendeteksi 6 jenis penyakit daun padi dengan akurasi 96,8%. Model dikompresi dengan teknik INT8 quantization untuk inferensi waktu-nyata luring di smartphone petani.',
        kataKunci: ['Deep Learning', 'Computer Vision', 'MobileNetV3', 'Smart Agriculture'],
        unduhan: 1420,
        sitasi: 18,
        status: 'Diterbitkan',
        tanggalTerbit: '14 Juli 2024',
        doi: '10.2412/imc.2024.089',
        fileSize: '6.4 MB',
        skorTurnitin: 11,
      ),
      KaryaModel(
        id: 'karya-rev-001',
        judul: 'Rancang Bangun Microservices Architecture Berbasis Node.js & Docker pada Sistem E-Katalog Kampus',
        penulis: 'Amanda Putri Wibowo',
        nim: '2110512034',
        pembimbing: 'Budi Santoso, M.Kom.',
        jenis: 'skripsi',
        jenisLabel: 'Skripsi S-1',
        prodi: 'Teknik Informatika',
        tahun: 2026,
        abstrak: 'Perancangan backend berkinerja tinggi dengan pola API Gateway, isolasi layanan, dan database sharding untuk menangani lonjakan traffic unggah karya ilmiah sivitas akademika.',
        kataKunci: ['Microservices', 'Node.js', 'Docker', 'REST API'],
        unduhan: 0,
        sitasi: 0,
        status: 'Perlu Revisi',
        tanggalTerbit: '18 November 2026',
        fileSize: '5.2 MB',
        catatanRevisi: '1. Lampirkan lembar pengesahan TTE Dekan resmi.\n2. Tambahkan abstrak bahasa Inggris.\n3. Sesuaikan format sitasi APA edisi ke-7.',
        skorTurnitin: 14,
      ),
      KaryaModel(
        id: '2024-512',
        judul: 'Optimasi Logistik Distribusi Rantai Dingin Produk Perikanan Menggunakan Algoritma Genetika',
        penulis: 'Bagas Aditya Pratama',
        nim: '2105120045',
        pembimbing: 'Prof. Dr. Ir. Setyo Utomo, M.Sc.',
        jenis: 'skripsi',
        jenisLabel: 'Skripsi S-1',
        prodi: 'Teknik Industri',
        tahun: 2024,
        abstrak: 'Penerapan Genetic Algorithm dalam Vehicle Routing Problem with Time Windows (VRPTW) untuk meminimalkan degradasi mutu ikan tangkap dan biaya operasional bahan bakar armada berpendingin sebesar 22,4%.',
        kataKunci: ['Rantai Dingin', 'Algoritma Genetika', 'Optimasi Rute', 'Logistik'],
        unduhan: 890,
        sitasi: 12,
        status: 'Diterbitkan',
        tanggalTerbit: '10 Juni 2024',
        doi: '10.2412/imc.2024.052',
        fileSize: '4.8 MB',
        skorTurnitin: 9,
      ),
      KaryaModel(
        id: 'karya-queue-001',
        judul: 'Analisis Faktor Penerimaan Sistem Informasi Perpustakaan Digital Menggunakan Model UTAUT 2',
        penulis: 'Fajar Danuarta',
        nim: '2108561023',
        pembimbing: 'Dra. Endang Sulastri, M.Si.',
        jenis: 'skripsi',
        jenisLabel: 'Skripsi S-1',
        prodi: 'Sistem Informasi',
        tahun: 2026,
        abstrak: 'Kajian empiris terhadap 450 mahasiswa aktif pengguna portal repositori kampus untuk mengevaluasi pengaruh performance expectancy, effort expectancy, dan habit terhadap intensi pemanfaatan koleksi repositori.',
        kataKunci: ['UTAUT 2', 'Adopsi Teknologi', 'Repositori Digital', 'SEM-PLS'],
        unduhan: 0,
        sitasi: 0,
        status: 'Dalam Review',
        tanggalTerbit: '22 November 2026',
        fileSize: '3.9 MB',
        skorTurnitin: 8,
      ),
    ];
  }

  Future<bool> submitRevision(String id, String responseText) async {
    final index = _karyaList.indexWhere((k) => k.id == id);
    if (index != -1) {
      final current = _karyaList[index];
      _karyaList[index] = KaryaModel(
        id: current.id,
        judul: current.judul,
        penulis: current.penulis,
        nim: current.nim,
        pembimbing: current.pembimbing,
        jenis: current.jenis,
        jenisLabel: current.jenisLabel,
        prodi: current.prodi,
        tahun: current.tahun,
        abstrak: current.abstrak,
        kataKunci: current.kataKunci,
        unduhan: current.unduhan,
        sitasi: current.sitasi,
        status: 'Dalam Review',
        tanggalTerbit: current.tanggalTerbit,
        doi: current.doi,
        fileSize: current.fileSize,
        skorTurnitin: current.skorTurnitin,
      );
      notifyListeners();
    }
    return true;
  }

  Future<bool> updateStatus(String id, String newStatus, {String? notes}) async {
    final index = _karyaList.indexWhere((k) => k.id == id);
    if (index != -1) {
      final current = _karyaList[index];
      _karyaList[index] = KaryaModel(
        id: current.id,
        judul: current.judul,
        penulis: current.penulis,
        nim: current.nim,
        pembimbing: current.pembimbing,
        jenis: current.jenis,
        jenisLabel: current.jenisLabel,
        prodi: current.prodi,
        tahun: current.tahun,
        abstrak: current.abstrak,
        kataKunci: current.kataKunci,
        unduhan: current.unduhan,
        sitasi: current.sitasi,
        status: newStatus,
        tanggalTerbit: current.tanggalTerbit,
        doi: current.doi,
        fileSize: current.fileSize,
        catatanRevisi: notes ?? current.catatanRevisi,
        skorTurnitin: current.skorTurnitin,
      );
      notifyListeners();
    }
    return true;
  }

  void addKarya(KaryaModel karya) {
    _karyaList.insert(0, karya);
    notifyListeners();
  }
}
