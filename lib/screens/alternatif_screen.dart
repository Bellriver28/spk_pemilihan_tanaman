import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class AlternatifScreen extends StatefulWidget {
  const AlternatifScreen({Key? key}) : super(key: key);

  @override
  State<AlternatifScreen> createState() => _AlternatifScreenState();
}

class _AlternatifScreenState extends State<AlternatifScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _listAlternatif = [];

  @override
  void initState() {
    super.initState();
    _refreshAlternatif();
  }

  void _refreshAlternatif() async {
    final data = await _dbHelper.getAlternatif();
    setState(() {
      _listAlternatif = data;
    });
  }

  void _deleteAlternatif(int id) async {
    final db = await _dbHelper.db;
    await db.delete(DBHelper.tableAlternatif, where: 'id = ?', whereArgs: [id]);
    _refreshAlternatif();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Data Alternatif', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () {
              // Nanti bisa ditambahkan Form Tambah Alternatif Baru jika diperlukan
            },
          )
        ],
      ),
      body: _listAlternatif.isEmpty
          ? const Center(child: Text('Belum ada data tanaman.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _listAlternatif.length,
        itemBuilder: (context, index) {
          final item = _listAlternatif[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: const Icon(Icons.eco, color: Colors.green),
              ),
              title: Text(
                item['nama'].toString().toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  'N: ${item['n']} | P: ${item['p']} | K: ${item['k']}\npH: ${item['ph']} | Rain: ${item['rainfall']}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.green), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAlternatif(item['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}