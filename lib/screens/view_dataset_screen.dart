import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class ViewDatasetScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const ViewDatasetScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<ViewDatasetScreen> createState() => _ViewDatasetScreenState();
}

class _ViewDatasetScreenState extends State<ViewDatasetScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _alternatifList = [];
  List<Map<String, dynamic>> _kriteriaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final alt = await _dbHelper.getAlternatif();
    final kri = await _dbHelper.getKriteria();
    setState(() {
      _alternatifList = alt;
      _kriteriaList = kri;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // PERUBAHAN DI SINI: Gunakan Navigator.pop(context)
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dataset Tanaman', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alternatifList.isEmpty
          ? _buildEmptyState()
          : InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 2.0,
        constrained: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 60),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.hardEdge,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.green[700]),
              dataRowHeight: 50,
              border: TableBorder.all(color: Colors.grey.shade200),
              columns: [
                const DataColumn(
                    label: Text('TANAMAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                ),
                ..._kriteriaList.map((k) => DataColumn(
                    label: Text(k['nama'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                )).toList(),
              ],
              rows: _alternatifList.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                        Text(item['nama'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                    ),
                    ..._kriteriaList.map((k) {
                      String key = k['nama'].toString().toLowerCase();
                      return DataCell(
                        Text(item[key]?.toString() ?? '0', textAlign: TextAlign.center),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 64, color: Colors.green[200]),
          const SizedBox(height: 16),
          const Text('Data belum tersedia', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}