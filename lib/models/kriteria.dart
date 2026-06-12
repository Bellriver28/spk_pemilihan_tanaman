class Kriteria {
  int? id;
  String nama;
  double bobot;
  String jenis; // 'Benefit' atau 'Cost'

  Kriteria({
    this.id,
    required this.nama,
    required this.bobot,
    required this.jenis,
  });

  // Mengubah dari Map (Database) ke Objek Kriteria
  factory Kriteria.fromMap(Map<String, dynamic> map) {
    return Kriteria(
      id: map['id'],
      nama: map['nama'],
      bobot: (map['bobot'] as num).toDouble(),
      jenis: map['jenis'],
    );
  }

  // Mengubah dari Objek Kriteria ke Map (Untuk disimpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'bobot': bobot,
      'jenis': jenis,
    };
  }
}