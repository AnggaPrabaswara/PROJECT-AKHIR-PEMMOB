class WisataModel {
  int? id;
  String nama;
  String lokasi;
  String deskripsi;
  String kategori;
  String gambarPath;
  int dana;
  String tanggalKunjungan;
  double? lat;
  double? lng;

  WisataModel({
    this.id,
    required this.nama,
    required this.lokasi,
    required this.deskripsi,
    required this.kategori,
    required this.gambarPath,
    required this.dana,
    required this.tanggalKunjungan,
    this.lat,
    this.lng,
  });

  factory WisataModel.fromMap(Map<String, dynamic> map) {
    return WisataModel(
      id: map['id'],
      nama: map['nama'],
      lokasi: map['lokasi'],
      deskripsi: map['deskripsi'],
      kategori: map['kategori'],
      gambarPath: map['gambarPath'],
      dana: map['dana'],
      tanggalKunjungan: map['tanggalKunjungan'],
      lat: map['lat'] != null ? map['lat'] * 1.0 : null,
      lng: map['lng'] != null ? map['lng'] * 1.0 : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'gambarPath': gambarPath,
      'dana': dana,
      'tanggalKunjungan': tanggalKunjungan,
      'lat': lat,
      'lng': lng,
    };
  }
} 