import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/riwayat_provider.dart';
import 'package:intl/intl.dart';
import 'cicilan_screen.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();

    /// ================= HANYA PINJAMAN =================
    final pinjamanList = provider.riwayatList.where((e) {
      final jenis = (e['jenis'] ?? 'pinjaman');
      final rekap = (e['rekap'] ?? false);
      return jenis == 'pinjaman' && rekap == true;
    }).toList();

    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text(
          "Riwayat Kredit",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: pinjamanList.isEmpty
          ? const Center(
              child: Text("Belum ada data pinjaman"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pinjamanList.length,
              itemBuilder: (context, index) {
                final data = pinjamanList[index];

                final jadwal =
                    (data['jadwal'] is List) ? data['jadwal'] : [];

                final sudahLunas = jadwal.isNotEmpty &&
                    jadwal.every((e) => e['isPaid'] == true);

                final progress =
                    provider.progressCicilan(data);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      /// ================= HEADER =================
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: sudahLunas
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            child: Icon(
                              sudahLunas
                                  ? Icons.check_circle
                                  : Icons.timelapse,
                              color: sudahLunas
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['nama'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "ID: ${data['id'] ?? '-'}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  formatRupiah.format(
                                      data['totalBayar'] ?? 0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: sudahLunas
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Text(
                              sudahLunas ? "LUNAS" : "BERJALAN",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// ================= PROGRESS =================
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "${(progress * 100).toInt()}% Terbayar",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ================= BUTTON DETAIL =================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CicilanScreen(data: data),
                              ),
                            );
                          },
                          child: const Text("Lihat Detail Cicilan"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}