import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../topsis/topsis_calculator.dart';

class HasilScreen extends StatefulWidget {
  const HasilScreen({Key? key}) : super(key: key);

  @override
  State<HasilScreen> createState() => _HasilScreenState();
}

class _HasilScreenState extends State<HasilScreen> with SingleTickerProviderStateMixin {
  final TopsisCalculator _calculator = TopsisCalculator();
  List<Map<String, dynamic>> _hasilRanking = [];
  bool _isLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _hitungTopsis();
  }

  void _hitungTopsis() async {
    final hasil = await _calculator.hitungTopsis();
    setState(() {
      _hasilRanking = hasil;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Hasil Perankingan', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Tabel'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Grafik'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildTabelLayout(),
          _buildGrafikLayout(),
        ],
      ),
    );
  }

  Widget _buildTabelLayout() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hasilRanking.length,
      itemBuilder: (context, index) {
        final item = _hasilRanking[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: index == 0 ? Colors.amber : (index == 1 ? Colors.blueGrey : Colors.brown),
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(item['nama'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text((item['skor'] as double).toStringAsFixed(4), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        );
      },
    );
  }

  Widget _buildGrafikLayout() {
    // Ambil top 5 tanaman saja agar grafik pas di layar hp
    List<Map<String, dynamic>> top5 = _hasilRanking.take(5).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('Grafik 5 Nilai Preferensi Tertinggi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 30),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1.0,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < top5.length) {
                          return Padding(
                            // PERBAIKAN DI SINI:
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(top5[idx]['nama'].toString().substring(0, min(top5[idx]['nama'].toString().length, 5)), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(top5.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: top5[index]['skor'],
                        color: Colors.green[600],
                        width: 25,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}