class Kriteria {
  final int? id;
  final String nama;
  final double bobot;
  final String jenis; // 'Benefit' atau 'Cost'

  Kriteria({this.id, required this.nama, required this.bobot, required this.jenis});

  factory Kriteria.fromMap(Map<String, dynamic> map) {
    return Kriteria(
      id: map['id'],
      nama: map['nama'],
      bobot: (map['bobot'] as num).toDouble(),
      jenis: map['jenis'],
    );
  }

  // PENTING: Untuk simpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'bobot': bobot,
      'jenis': jenis,
    };
  }
}