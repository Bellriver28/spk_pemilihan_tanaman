import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class KriteriaScreen extends StatefulWidget {
  const KriteriaScreen({Key? key}) : super(key: key);

  @override
  State<KriteriaScreen> createState() => _KriteriaScreenState();
}

class _KriteriaScreenState extends State<KriteriaScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _listKriteria = [];
  double _totalBobot = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshKriteria();
  }

  // Fungsi untuk mengambil data terbaru dari database lokal
  void _refreshKriteria() async {
    final data = await _dbHelper.getKriteria();
    double total = 0.0;
    for (var item in data) {
      total += (item['bobot'] as num).toDouble();
    }
    setState(() {
      _listKriteria = data;
      _totalBobot = total;
    });
  }

  // Fungsi untuk menghapus kriteria
  void _deleteKriteria(int id) async {
    final db = await _dbHelper.db;
    await db.delete(DBHelper.tableKriteria, where: 'id = ?', whereArgs: [id]);
    _refreshKriteria();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kriteria berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Data Kriteria', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () => _showForm(null), // Tambah data baru
          ),
        ],
      ),
      body: Column(
        children: [
          // List Kriteria
          Expanded(
            child: _listKriteria.isEmpty
                ? const Center(child: Text('Belum ada data kriteria.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listKriteria.length,
              itemBuilder: (context, index) {
                final item = _listKriteria[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[50],
                      // PERBAIKAN DI SINI: Hapus textColor dan pindahkan warnanya ke dalam TextStyle di bawah
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Bobot: ${item['bobot']} • ${item['jenis']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _showForm(item), // Edit data
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteKriteria(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Total Bobot (Bagian Bawah sesuai Mockup)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Bobot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  _totalBobot.toStringAsFixed(2),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Form Dialog Tambah / Edit Kriteria (Mockup 2a)
  void _showForm(Map<String, dynamic>? item) {
    final nameController = TextEditingController();
    final bobotController = TextEditingController();
    String jenisKriteria = 'Benefit';

    if (item != null) {
      nameController.text = item['nama'];
      bobotController.text = item['bobot'].toString();
      jenisKriteria = item['jenis'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20, left: 20, right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item == null ? 'Tambah Kriteria' : 'Ubah Kriteria',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Kriteria', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bobotController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Bobot (0 - 1)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: jenisKriteria,
              items: ['Benefit', 'Cost'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
              onChanged: (value) => jenisKriteria = value!,
              decoration: const InputDecoration(labelText: 'Jenis', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                  onPressed: () async {
                    final db = await _dbHelper.db;
                    Map<String, dynamic> row = {
                      'nama': nameController.text,
                      'bobot': double.tryParse(bobotController.text) ?? 0.0,
                      'jenis': jenisKriteria,
                    };

                    if (item == null) {
                      await db.insert(DBHelper.tableKriteria, row);
                    } else {
                      await db.update(DBHelper.tableKriteria, row, where: 'id = ?', whereArgs: [item['id']]);
                    }

                    Navigator.pop(context);
                    _refreshKriteria();
                  },
                  child: Text(item == null ? 'Simpan' : 'Perbarui'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}