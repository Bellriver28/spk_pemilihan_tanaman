class Tanaman {
  int? id;
  String nama;
  double n;
  double p;
  double k;
  double temperature;
  double humidity;
  double ph;
  double rainfall;

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

  // Mengubah dari Map (Database) ke Objek Tanaman
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

  // Mengubah dari Objek Tanaman ke Map (Untuk disimpan ke Database)
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