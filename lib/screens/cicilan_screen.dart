import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/riwayat_provider.dart';

class CicilanScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const CicilanScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RiwayatProvider>(context);

    // 🔥 AMBIL DATA REAL DARI PROVIDER
    final nasabah = provider.riwayatList.firstWhere(
      (e) => e['id'] == data['id'],
      orElse: () => data,
    );

    final jadwal = (nasabah['jadwal'] as List?) ?? [];

    bool lunas = jadwal.isNotEmpty &&
        jadwal.every((e) => (e['isPaid'] ?? false) == true);

    int total = jadwal.length;
    int paid = jadwal.where((e) => e['isPaid'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: Text("Cicilan ${nasabah['nama']}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Column(
        children: [

          /// ================= LUNAS BANNER =================
          if (lunas)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "CICILAN SUDAH LUNAS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          /// ================= HEADER =================
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      nasabah['nama'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: lunas ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lunas ? "LUNAS" : "BERJALAN",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "$paid dari $total cicilan dibayar",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: provider.progressCicilan(nasabah),
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),

          /// ================= LIST CICILAN =================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: jadwal.length,
              itemBuilder: (context, index) {
                final item = jadwal[index];
                bool isPaid = item['isPaid'] ?? false;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPaid
                          ? Colors.green.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [

                      /// ICON
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isPaid
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPaid ? Icons.check_circle : Icons.schedule,
                          color: isPaid ? Colors.green : Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cicilan ke-${item['cicilan_ke']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp ${item['angsuran']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      /// CHECKBOX
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          activeColor: Colors.green,
                          value: isPaid,
                          onChanged: lunas
                              ? null
                              : (value) {
                                  provider.bayarCicilanDanTambahSaldo(
                                    nasabah['id'],
                                    index,
                                    value!,
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}