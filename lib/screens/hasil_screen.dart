import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../topsis/topsis_calculator.dart';

class HasilScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HasilScreen({Key? key, required this.onNavigate}) : super(key: key);

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.onNavigate(0),
        ),
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
    List<Map<String, dynamic>> top5 = _hasilRanking.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 1. BAR CHART TOP 5
          const Text('Top 5 Tanaman Terbaik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 30),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                maxY: 1.0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.green[700], // Perbaikan error getTooltipColor
                    getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                      '${top5[groupIndex]['nama'].toString().toUpperCase()}\n${rod.toY.toStringAsFixed(3)}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      getTitlesWidget: (v, m) => RotatedBox(
                        quarterTurns: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(top5[v.toInt()]['nama'].toString(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.25,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10),
                        ),
                      )
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(top5.length, (i) => BarChartGroupData(
                    x: i,
                    barRods: [BarChartRodData(toY: top5[i]['skor'], color: Colors.green[600], width: 25, borderRadius: BorderRadius.circular(4))]
                )),
              ),
            ),
          ),
          const Divider(height: 60, thickness: 2),

          // 2. LINE CHART SELURUH RANKING
          const Text('Trend Nilai Seluruh Tanaman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 30),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final val = _hasilRanking[barSpot.x.toInt()];
                        return LineTooltipItem(
                          'Rank ${barSpot.x.toInt() + 1}\n${val['nama'].toUpperCase()}\n${val['skor'].toStringAsFixed(4)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.25,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10),
                        ),
                      )
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _hasilRanking.length > 10 ? 3 : 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        (value.toInt() + 1).toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _hasilRanking.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['skor'])).toList(),
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    dotData: FlDotData(show: _hasilRanking.length < 20),
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Sumbu X = Ranking Tanaman', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}