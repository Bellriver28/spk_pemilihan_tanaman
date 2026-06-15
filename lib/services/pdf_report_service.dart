import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../database/db_helper.dart';
import '../topsis/topsis_calculator.dart';

class PdfReportService {
  static Future<void> generateAndPrintReport() async {
    final pdf = pw.Document();
    final db = DBHelper();
    final calc = TopsisCalculator();

    final dataset = await db.getAlternatif();
    final kriteria = await db.getKriteria();
    final ranking = await calc.hitungTopsis();
    final top5 = ranking.take(5).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text("Laporan Hasil SPK Tanaman")),

            // 1. DATASET
            pw.Text("1. Dataset Tanaman", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              cellStyle: const pw.TextStyle(fontSize: 8),
              data: [
                ['Tanaman', ...kriteria.map((k) => k['nama'].toString().toUpperCase())],
                ...dataset.map((d) => [
                  d['nama'].toString().toUpperCase(),
                  ...kriteria.map((k) => d[k['nama'].toString().toLowerCase()].toString())
                ])
              ],
            ),

            pw.SizedBox(height: 20),

            // 2. HASIL RANKING
            pw.Text("2. Hasil Perankingan", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              cellStyle: const pw.TextStyle(fontSize: 8),
              data: [
                ['Rank', 'Tanaman', 'Skor'],
                ...ranking.asMap().entries.map((e) => [
                  (e.key + 1).toString(),
                  e.value['nama'].toString().toUpperCase(),
                  (e.value['skor'] as double).toStringAsFixed(4)
                ])
              ],
            ),

            pw.SizedBox(height: 30),

            // 3. GRAFIK
            pw.Text("3. Grafik Top 5 Tanaman Terbaik", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.SizedBox(
              height: 250,
              child: pw.Chart(
                grid: pw.CartesianGrid(
                  // PERBAIKAN: Menambahkan -0.5 dan 4.5 agar grafik punya "padding" kiri dan kanan
                  xAxis: pw.FixedAxis(
                    [-0.5, 0.0, 1.0, 2.0, 3.0, 4.0, 4.5],
                    divisions: true,
                  ),
                  yAxis: pw.FixedAxis(
                    [0, 0.2, 0.4, 0.6, 0.8, 1.0],
                    divisions: true,
                  ),
                ),
                datasets: [
                  pw.BarDataSet(
                    data: top5.asMap().entries.map((e) => pw.PointChartValue(e.key.toDouble(), e.value['skor'] as double)).toList(),
                    color: PdfColors.green700,
                    width: 30,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Keterangan
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: List.generate(top5.length, (i) {
                return pw.Text("${i + 1}. ${top5[i]['nama'].toString().toUpperCase()}",
                    style: const pw.TextStyle(fontSize: 8));
              }),
            ),

            pw.SizedBox(height: 10),
            pw.Center(
                child: pw.Text("Keterangan: Grafik menampilkan Top 5 Tanaman dengan Skor Tertinggi",
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700))
            )
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}