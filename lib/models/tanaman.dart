class Kriteria {
  final int? id;
  final String nama;
  final double bobot;
  final String jenis; // 'Benefit' atau 'Cost'

  Kriteria({
    this.id,
    required this.nama,
    required this.bobot,
    required this.jenis,
  });

  // Konversi Database (Map) -> Objek
  factory Kriteria.fromMap(Map<String, dynamic> map) {
    return Kriteria(
      id: map['id'],
      nama: map['nama'],
      bobot: (map['bobot'] as num).toDouble(),
      jenis: map['jenis'],
    );
  }

  // Konversi Objek -> Map (untuk Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'bobot': bobot,
      'jenis': jenis,
    };
  }
}

class Tanaman {
  final int? id;
  final String nama;
  final double n;
  final double p;
  final double k;
  final double temperature;
  final double humidity;
  final double ph;
  final double rainfall;

  Tanaman({
    this.id,
    required this.nama,
    required this.n,
    required this.p,
    required this.k,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.rainfall,
  });

  factory Tanaman.fromMap(Map<String, dynamic> map) {
    return Tanaman(
      id: map['id'],
      nama: map['nama'],
      n: (map['n'] as num).toDouble(),
      p: (map['p'] as num).toDouble(),
      k: (map['k'] as num).toDouble(),
      temperature: (map['temperature'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      ph: (map['ph'] as num).toDouble(),
      rainfall: (map['rainfall'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'n': n,
      'p': p,
      'k': k,
      'temperature': temperature,
      'humidity': humidity,
      'ph': ph,
      'rainfall': rainfall,
    };
  }
}