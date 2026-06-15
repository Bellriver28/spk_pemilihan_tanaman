import 'dart:math';
import '../database/db_helper.dart';

class TopsisCalculator {
  final DBHelper _db = DBHelper();

  // Helper untuk pembulatan 3 digit (sama dengan standar Excel)
  double to3(double val) => double.parse(val.toStringAsFixed(3));

  Future<List<Map<String, dynamic>>> hitungTopsis() async {
    List<Map<String, dynamic>> kriteriaData = await _db.getKriteria();
    List<Map<String, dynamic>> alternatifData = await _db.getAlternatif();

    if (kriteriaData.isEmpty || alternatifData.isEmpty) return [];

    // --- DINAMIS: Mengambil nama kolom/keys dari DB ---
    List<String> keys = kriteriaData.map((k) => k['nama'].toString().toLowerCase()).toList();

    Map<String, double> mapBobot = {};
    Map<String, bool> mapIsBenefit = {};

    for (var k in kriteriaData) {
      String key = k['nama'].toString().toLowerCase();
      mapBobot[key] = (k['bobot'] as num).toDouble();
      mapIsBenefit[key] = k['jenis'].toString().toLowerCase() != 'cost';
    }

    // 1. Normalisasi Vektor (Menggunakan SQRT)
    Map<String, double> pembagi = {};
    for (var key in keys) {
      double sumSq = 0.0;
      for (var alt in alternatifData) {
        double val = (alt[key] as num).toDouble();
        sumSq += pow(val, 2);
      }
      pembagi[key] = sqrt(sumSq);
    }

    // 2. Matriks Ternormalisasi Terbobot (Y)
    List<Map<String, dynamic>> matriksY = [];
    for (var alt in alternatifData) {
      Map<String, dynamic> rowY = {'id': alt['id'], 'nama': alt['nama']};
      for (var key in keys) {
        double x = (alt[key] as num).toDouble();
        double pembagiVal = pembagi[key] ?? 1.0;
        double bobot = mapBobot[key] ?? 1.0;

        // Pembulatan per langkah agar sama dengan Excel
        double normalized = (pembagiVal == 0) ? 0 : (x / pembagiVal);
        rowY[key] = to3(normalized) * bobot;
      }
      matriksY.add(rowY);
    }

    // 3. Solusi Ideal Positif (A+) & Negatif (A-)
    Map<String, double> aPlus = {};
    Map<String, double> aMin = {};

    for (var key in keys) {
      bool isBenefit = mapIsBenefit[key] ?? true;
      List<double> kolomNilai = matriksY.map((e) => e[key] as double).toList();

      if (isBenefit) {
        aPlus[key] = kolomNilai.reduce(max);
        aMin[key] = kolomNilai.reduce(min);
      } else {
        aPlus[key] = kolomNilai.reduce(min);
        aMin[key] = kolomNilai.reduce(max);
      }
    }

    // 4. Perhitungan Jarak (D+ & D-) & Nilai Preferensi (V)
    List<Map<String, dynamic>> hasilAkhir = [];
    for (var y in matriksY) {
      double dPlus = 0.0;
      double dMin = 0.0;

      for (var key in keys) {
        dPlus += pow((y[key] as double) - (aPlus[key] ?? 0.0), 2);
        dMin += pow((y[key] as double) - (aMin[key] ?? 0.0), 2);
      }

      dPlus = sqrt(dPlus);
      dMin = sqrt(dMin);

      double v = (dPlus + dMin) == 0 ? 0 : dMin / (dPlus + dMin);

      hasilAkhir.add({
        'id': y['id'],
        'nama': y['nama'],
        'skor': to3(v), // Pembulatan hasil akhir
      });
    }

    // 5. Ranking
    hasilAkhir.sort((a, b) => (b['skor'] as double).compareTo(a['skor'] as double));
    return hasilAkhir;
  }
}