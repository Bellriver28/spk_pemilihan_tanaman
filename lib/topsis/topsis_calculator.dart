import 'dart:math';
import '../database/db_helper.dart';

class TopsisCalculator {
  final DBHelper _db = DBHelper();

  Future<List<Map<String, dynamic>>> hitungTopsis() async {
    // 1. Ambil data dari Database
    List<Map<String, dynamic>> kriteriaData = await _db.getKriteria();
    List<Map<String, dynamic>> alternatifData = await _db.getAlternatif();

    if (kriteriaData.isEmpty || alternatifData.isEmpty) return [];

    // Keys kriteria berdasarkan database (sesuaikan dengan kolom tabel alternatif)
    List<String> keys = ['n', 'p', 'k', 'temperature', 'humidity', 'ph', 'rainfall'];

    // 2. Pembagi (Kuadrat & Akar) untuk Normalisasi
    Map<String, double> pembagi = {};
    for (var key in keys) {
      double sum = 0.0;
      for (var alt in alternatifData) {
        sum += pow((alt[key] as num).toDouble(), 2);
      }
      pembagi[key] = sqrt(sum);
    }

    // 3. Matriks Ternormalisasi Terbobot
    List<Map<String, dynamic>> matriksY = [];
    for (var alt in alternatifData) {
      Map<String, dynamic> rowY = {'id': alt['id'], 'nama': alt['nama']};
      for (int i = 0; i < keys.length; i++) {
        String key = keys[i];
        double bobot = kriteriaData.length > i ? (kriteriaData[i]['bobot'] as num).toDouble() : 0.0;
        double x = (alt[key] as num).toDouble();

        // R * W (Normalisasi dikali Bobot)
        rowY[key] = (x / pembagi[key]!) * bobot;
      }
      matriksY.add(rowY);
    }

    // 4. Solusi Ideal Positif (A+) dan Negatif (A-)
    Map<String, double> aPlus = {};
    Map<String, double> aMin = {};

    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      // Asumsi semua kriteria di dataset ini adalah 'Benefit' (Semakin besar semakin baik)
      // Jika ada 'Cost', logika MAX dan MIN dibalik.
      bool isBenefit = true;
      if (kriteriaData.length > i && kriteriaData[i]['jenis'] == 'Cost') {
        isBenefit = false;
      }

      List<double> kolomNilai = matriksY.map((e) => e[key] as double).toList();
      if (isBenefit) {
        aPlus[key] = kolomNilai.reduce(max);
        aMin[key] = kolomNilai.reduce(min);
      } else {
        aPlus[key] = kolomNilai.reduce(min);
        aMin[key] = kolomNilai.reduce(max);
      }
    }

    // 5. Jarak Ideal (D+ dan D-) & Nilai Preferensi (V)
    List<Map<String, dynamic>> hasilAkhir = [];
    for (var y in matriksY) {
      double dPlus = 0.0;
      double dMin = 0.0;

      for (var key in keys) {
        dPlus += pow(y[key] - aPlus[key]!, 2);
        dMin += pow(y[key] - aMin[key]!, 2);
      }

      dPlus = sqrt(dPlus);
      dMin = sqrt(dMin);

      // Rumus V = D- / (D+ + D-)
      double v = dMin / (dPlus + dMin);

      hasilAkhir.add({
        'id': y['id'],
        'nama': y['nama'],
        'skor': v,
      });
    }

    // 6. Urutkan dari Skor Tertinggi ke Terendah (Ranking)
    hasilAkhir.sort((a, b) => (b['skor'] as double).compareTo(a['skor'] as double));

    return hasilAkhir;
  }
}