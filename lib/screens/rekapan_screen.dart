import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/riwayat_provider.dart';
import 'nasabah_simpanan_screen.dart';

class RekapanScreen extends StatelessWidget {
  const RekapanScreen({super.key});

  String rupiah(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();

    final data = provider.riwayatList;
    final transaksi = provider.transaksi;

    /// ===== PINJAMAN =====
    final pinjamanList = data
        .where((e) => (e['jenis'] ?? 'pinjaman') == 'pinjaman')
        .toList();

    int totalPinjaman = pinjamanList.length;

    int lunas = pinjamanList.where((e) {
      final jadwal = (e['jadwal'] ?? []) as List;
      return jadwal.isNotEmpty &&
          jadwal.every((j) => j['isPaid'] == true);
    }).length;

    int aktif = totalPinjaman - lunas;

    /// ===== SIMPANAN =====
    final simpananList = data
        .where((e) => (e['jenis'] ?? '') == 'simpanan')
        .toList();

    int totalSimpanan = simpananList.length;

    int totalSaldoSimpanan = simpananList.fold(
      0,
      (sum, item) =>
          sum + (int.tryParse(item['nominal'].toString()) ?? 0),
    );

    /// ===== PEMASUKAN (CICILAN SAJA) =====
    int totalPemasukan = transaksi.fold(0, (sum, item) {
      if ((item['jenis'] ?? '') == 'cicilan') {
        return sum + (int.tryParse(item['nominal'].toString()) ?? 0);
      }
      return sum;
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Rekapan Keuangan"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ===== REKAPAN PINJAMAN =====
            const Text(
              "Rekapan Pinjaman",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _miniCard("Total", totalPinjaman.toString(), Colors.blue),
                _miniCard("Aktif", aktif.toString(), Colors.orange),
                _miniCard("Lunas", lunas.toString(), Colors.green),
              ],
            ),

            const SizedBox(height: 20),

            /// ===== TOTAL PEMASUKAN (CICILAN SAJA) =====
            _mainCard(
              title: "Total Pemasukan (Cicilan)",
              value: rupiah(totalPemasukan),
              color: Colors.green,
              icon: Icons.trending_up,
            ),

            const SizedBox(height: 20),

            /// ===== PROGRESS PINJAMAN (TIDAK DIUBAH) =====
            const Text(
              "Progress Pinjaman",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            pinjamanList.isEmpty
                ? _empty()
                : Column(
                    children: pinjamanList.map((item) {
                      final progress =
                          provider.progressCicilan(item);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama'] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                            ),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  "${(progress * 100).toInt()}%"),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 20),

            /// ===== REKAPAN SIMPANAN =====
            const Text(
              "Rekapan Simpanan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const NasabahSimpananScreen(),
                  ),
                );
              },
              child: _mainCard(
                title: "Nasabah",
                value: totalSimpanan.toString(),
                color: Colors.purple,
                icon: Icons.people,
              ),
            ),

            const SizedBox(height: 10),

            _mainCard(
              title: "Total Simpanan",
              value: rupiah(totalSaldoSimpanan),
              color: Colors.purple,
              icon: Icons.account_balance_wallet,
            ),
          ],
        ),
      ),
    );
  }

  /// ================= UI =================

  Widget _miniCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white70)),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("Belum ada data"),
      ),
    );
  }
}