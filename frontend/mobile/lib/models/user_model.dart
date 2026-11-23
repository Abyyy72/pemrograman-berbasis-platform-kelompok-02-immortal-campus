class UserModel {
  final String id;
  final String nama;
  final String email;
  final String? nim;
  final String? nip;
  final String? prodi;
  final String role; // 'penulis' | 'kurator' | 'admin'

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.nim,
    this.nip,
    this.prodi,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      nim: json['nim'],
      nip: json['nip'],
      prodi: json['prodi'],
      role: json['role'] ?? 'penulis',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'nim': nim,
      'nip': nip,
      'prodi': prodi,
      'role': role,
    };
  }

  bool get isPenulis => role == 'penulis';
  bool get isKurator => role == 'kurator';
  bool get isAdmin => role == 'admin';
}
