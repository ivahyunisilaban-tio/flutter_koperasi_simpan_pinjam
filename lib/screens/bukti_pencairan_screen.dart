import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

class BuktiPencairanScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;

  const BuktiPencairanScreen({
    super.key,
    required this.data,
    required this.index,
  });

  @override
  State<BuktiPencairanScreen> createState() => _BuktiPencairanScreenState();
}

class _BuktiPencairanScreenState extends State<BuktiPencairanScreen> {
  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final Map<String, Map<String, dynamic>> paketData = {
    'Reguler': {'bunga': 0.02, 'bulan': 12, 'cicilan': 24, 'max': 6000000},
    'Cepat': {'bunga': 0.03, 'bulan': 6, 'cicilan': 12, 'max': 3000000},
    'Khusus': {'bunga': 0.015, 'bulan': 24, 'cicilan': 48, 'max': 10000000},
  };

  Uint8List? imageBytes;
  File? imageFile;

  final jumlahController = TextEditingController();

  List<Map<String, dynamic>> jadwal = [];

  double totalBayar = 0;
  double totalBunga = 0;
  double angsuran = 0;

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();

      setState(() {
        imageBytes = bytes;
        if (!kIsWeb) {
          imageFile = File(picked.path);
        }
      });
    }
  }

  void generateAngsuran() {
    final jumlah = int.tryParse(jumlahController.text) ?? 0;

    final paketInput = widget.data['paket']?.toString().trim();
    final dataPaket = paketData[paketInput];

    if (jumlah == 0 || dataPaket == null) return;

    double bunga = dataPaket['bunga'];
    int cicilanCount = dataPaket['cicilan'];

    totalBunga = jumlah * bunga * dataPaket['bulan'];
    totalBayar = jumlah + totalBunga;
    angsuran = totalBayar / cicilanCount;

    final startDate = DateTime.now().add(const Duration(days: 14));

    List<Map<String, dynamic>> temp = [];

    for (int i = 0; i < cicilanCount; i++) {
      final jatuhTempo = startDate.add(Duration(days: 14 * i));
      temp.add({
        'cicilan_ke': i + 1,
        'angsuran': angsuran.ceil(),
        'isPaid': false,
        'jatuh_tempo': jatuhTempo.toIso8601String(),
      });
    }

    setState(() {
      jadwal = temp;
    });
  }

  @override
  void dispose() {
    jumlahController.dispose();
    super.dispose();
  }

  Widget buildInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "$title : ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Bukti Pencairan'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.receipt_long, color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'BUKTI PENCAIRAN DANA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= DATA NASABAH =================
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    buildInfo('ID', widget.data['id'] ?? '-'),
                    buildInfo('Nama', widget.data['nama'] ?? '-'),
                    buildInfo(
                      'TTL',
                      '${widget.data['tempat_lahir']}, ${widget.data['tanggal_lahir']}',
                    ),
                    buildInfo('Alamat', widget.data['alamat'] ?? '-'),
                    buildInfo('HP', widget.data['hp'] ?? '-'),
                    buildInfo('Paket', widget.data['paket'] ?? '-'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= FOTO =================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'Bukti Foto',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    imageBytes == null
                        ? const Text('Belum ada gambar')
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(imageBytes!, height: 150),
                          ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload'),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= INPUT PINJAMAN =================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'Peminjaman',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Pinjaman',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: generateAngsuran,
                      child: const Text('Generate'),
                    ),
                  ],
                ),
              ),
            ),

            // ================= HASIL =================
            if (jadwal.isNotEmpty) ...[
              const SizedBox(height: 16),

              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        'Total Bayar: ${formatRupiah.format(totalBayar)}',
                      ),
                      Text(
                        'Total Bunga: ${formatRupiah.format(totalBunga)}',
                      ),
                      Text(
                        'Cicilan: ${formatRupiah.format(angsuran)}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ================= JADWAL CICILAN (DISPLAY ONLY) =================
              Column(
                children: List.generate(jadwal.length, (index) {
                  final item = jadwal[index];

                  final tanggal = DateTime.parse(item['jatuh_tempo'])
                      .toLocal()
                      .toString()
                      .split(' ')[0];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text("${item['cicilan_ke']}"),
                      ),
                      title: Text("Cicilan ke-${item['cicilan_ke']}"),
                      subtitle: Text(
                        "Rp ${item['angsuran']}\nJatuh tempo: $tanggal",
                      ),
                      trailing: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }),
              ),
            ],

            const SizedBox(height: 20),

            // ================= BUTTON SIMPAN =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  final result = {
                    'jadwal': jadwal,
                    'image': imageBytes,
                    'totalBayar': totalBayar,
                    'totalBunga': totalBunga,
                  };

                  Navigator.pop(context, result);
                },
                child: const Text('Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}