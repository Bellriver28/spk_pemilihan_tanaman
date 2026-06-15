import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class AlternatifScreen extends StatefulWidget {
  // Tambahkan fungsi onNavigate di sini
  final Function(int) onNavigate;

  const AlternatifScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<AlternatifScreen> createState() => _AlternatifScreenState();
}

class _AlternatifScreenState extends State<AlternatifScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _listAlternatif = [];
  List<Map<String, dynamic>> _listKriteria = [];

  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _namaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    final alternatif = await _dbHelper.getAlternatif();
    final kriteria = await _dbHelper.getKriteria();
    setState(() {
      _listAlternatif = alternatif;
      _listKriteria = kriteria;
    });
  }

  void _showForm(Map<String, dynamic>? item) {
    _controllers.clear();
    _namaController.text = item?['nama'] ?? '';

    for (var k in _listKriteria) {
      String key = k['nama'].toString().toLowerCase();
      _controllers[key] = TextEditingController(text: item?[key]?.toString() ?? '');
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Tambah Tanaman' : 'Edit Tanaman'),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(labelText: 'Nama Tanaman', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                ..._listKriteria.map((k) {
                  String key = k['nama'].toString().toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: TextField(
                      controller: _controllers[key],
                      decoration: InputDecoration(
                        labelText: k['nama'].toString().toUpperCase(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final db = await _dbHelper.db;
              Map<String, dynamic> data = {'nama': _namaController.text};

              for (var k in _listKriteria) {
                String key = k['nama'].toString().toLowerCase();
                data[key] = double.tryParse(_controllers[key]?.text ?? '0') ?? 0.0;
              }

              if (item == null) {
                await db.insert(DBHelper.tableAlternatif, data);
              } else {
                await db.update(DBHelper.tableAlternatif, data, where: 'id = ?', whereArgs: [item['id']]);
              }
              _refreshData();
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteAlternatif(int id) async {
    final db = await _dbHelper.db;
    await db.delete(DBHelper.tableAlternatif, where: 'id = ?', whereArgs: [id]);
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        // BACK BUTTON MENGGUNAKAN onNavigate(0)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.onNavigate(0),
        ),
        title: const Text('Data Tanaman', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _listAlternatif.isEmpty
          ? const Center(child: Text('Belum ada data tanaman.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _listAlternatif.length,
        itemBuilder: (context, index) {
          final item = _listAlternatif[index];
          String subtitleText = _listKriteria.map((k) {
            String key = k['nama'].toString().toLowerCase();
            return "${k['nama'].toString().toUpperCase()}: ${item[key] ?? 0}";
          }).join(" | ");

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.green[100], child: const Icon(Icons.eco, color: Colors.green)),
              title: Text(item['nama'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(subtitleText, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(item)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteAlternatif(item['id'])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}