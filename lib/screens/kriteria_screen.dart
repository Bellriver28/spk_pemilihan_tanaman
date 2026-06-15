import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class KriteriaScreen extends StatefulWidget {
  // Tambahkan fungsi onNavigate di sini
  final Function(int) onNavigate;

  const KriteriaScreen({Key? key, required this.onNavigate}) : super(key: key);

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

  void _deleteKriteria(int id) async {
    final db = await _dbHelper.db;
    await db.delete(DBHelper.tableKriteria, where: 'id = ?', whereArgs: [id]);
    _refreshKriteria();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kriteria berhasil dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        // BACK BUTTON MENGARAH KE HOME SCREEN (Index 0)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.onNavigate(0),
        ),
        title: const Text('Data Kriteria', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // TOTAL BOBOT DI ATAS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Bobot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  _totalBobot.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: (_totalBobot > 1.001 || _totalBobot < 0.999) ? Colors.red : Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          // LIST KRITERIA DI BAWAH
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
                      child: Text('${index + 1}', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                    ),
                    title: Text(item['nama'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Bobot: ${item['bobot']} • ${item['jenis']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _showForm(item),
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
        ],
      ),
    );
  }

  void _showForm(Map<String, dynamic>? item) {
    final nameController = TextEditingController(text: item?['nama'] ?? '');
    final bobotController = TextEditingController(text: item?['bobot']?.toString() ?? '');
    String jenisKriteria = item?['jenis'] ?? 'Benefit';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item == null ? 'Tambah Kriteria' : 'Ubah Kriteria', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Kriteria', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: bobotController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Bobot (Contoh: 0.25)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: jenisKriteria,
                  items: ['Benefit', 'Cost'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
                  onChanged: (value) => setModalState(() => jenisKriteria = value!),
                  decoration: const InputDecoration(labelText: 'Jenis', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], minimumSize: const Size(double.infinity, 50)),
                  onPressed: () async {
                    final db = await _dbHelper.db;
                    String namaBaru = nameController.text.toLowerCase();

                    Map<String, dynamic> row = {
                      'nama': namaBaru,
                      'bobot': double.tryParse(bobotController.text) ?? 0.0,
                      'jenis': jenisKriteria,
                    };

                    if (nameController.text.isEmpty || bobotController.text.isEmpty) return;

                    if (item == null) {
                      await db.insert(DBHelper.tableKriteria, row);
                      await _dbHelper.addNewKriteriaColumn(namaBaru);
                    } else {
                      await db.update(DBHelper.tableKriteria, row, where: 'id = ?', whereArgs: [item['id']]);
                    }

                    if (!mounted) return;
                    Navigator.pop(context);
                    _refreshKriteria();
                  },
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}