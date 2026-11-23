class KaryaModel {
  final String id;
  final String judul;
  final String penulis;
  final String? nim;
  final String? pembimbing;
  final String jenis;
  final String? jenisLabel;
  final String prodi;
  final int tahun;
  final String abstrak;
  final List<String> kataKunci;
  final int unduhan;
  final int sitasi;
  final String status;
  final String tanggalTerbit;
  final String? doi;
  final String? fileSize;
  final String? fileUrl;
  final String? catatanRevisi;
  final int? skorTurnitin;
  final String? penulisId;

  KaryaModel({
    required this.id,
    required this.judul,
    required this.penulis,
    this.nim,
    this.pembimbing,
    required this.jenis,
    this.jenisLabel,
    required this.prodi,
    required this.tahun,
    required this.abstrak,
    required this.kataKunci,
    required this.unduhan,
    required this.sitasi,
    required this.status,
    required this.tanggalTerbit,
    this.doi,
    this.fileSize,
    this.fileUrl,
    this.catatanRevisi,
    this.skorTurnitin,
    this.penulisId,
  });

  factory KaryaModel.fromJson(Map<String, dynamic> json) {
    List<String> keywords = [];
    if (json['kataKunci'] != null) {
      if (json['kataKunci'] is List) {
        keywords = List<String>.from(json['kataKunci']);
      } else if (json['kataKunci'] is String) {
        keywords = (json['kataKunci'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    return KaryaModel(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      penulis: json['penulis'] ?? '',
      nim: json['nim'],
      pembimbing: json['pembimbing'],
      jenis: json['jenis'] ?? 'skripsi',
      jenisLabel: json['jenisLabel'] ?? 'Skripsi S-1',
      prodi: json['prodi'] ?? 'Teknik Informatika',
      tahun: json['tahun'] is int ? json['tahun'] : int.tryParse(json['tahun']?.toString() ?? '2024') ?? 2024,
      abstrak: json['abstrak'] ?? '',
      kataKunci: keywords,
      unduhan: json['unduhan'] is int ? json['unduhan'] : int.tryParse(json['unduhan']?.toString() ?? '0') ?? 0,
      sitasi: json['sitasi'] is int ? json['sitasi'] : int.tryParse(json['sitasi']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'Draft',
      tanggalTerbit: json['tanggalTerbit'] ?? 'Baru saja',
      doi: json['doi'],
      fileSize: json['fileSize'] ?? '4.8 MB',
      fileUrl: json['fileUrl'],
      catatanRevisi: json['catatanRevisi'],
      skorTurnitin: json['skorTurnitin'] is int ? json['skorTurnitin'] : 14,
      penulisId: json['penulisId'],
    );
  }
}
