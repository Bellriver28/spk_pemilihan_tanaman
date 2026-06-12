import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class InputNilaiScreen extends StatefulWidget {
  const InputNilaiScreen({Key? key}) : super(key: key);

  @override
  State<InputNilaiScreen> createState() => _InputNilaiScreenState();
}

class _InputNilaiScreenState extends State<InputNilaiScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _alternatifList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _dbHelper.getAlternatif();
    setState(() {
      _alternatifList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Input Nilai (Matriks)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _alternatifList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.green[50]),
            columns: const [
              DataColumn(label: Text('Tanaman', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('N', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('P', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('K', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Temp', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Hum', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('pH', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Rainfall', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _alternatifList.map((data) {
              return DataRow(cells: [
                DataCell(Text(data['nama'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(data['n'].toString())),
                DataCell(Text(data['p'].toString())),
                DataCell(Text(data['k'].toString())),
                DataCell(Text(data['temperature'].toString())),
                DataCell(Text(data['humidity'].toString())),
                DataCell(Text(data['ph'].toString())),
                DataCell(Text(data['rainfall'].toString())),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}