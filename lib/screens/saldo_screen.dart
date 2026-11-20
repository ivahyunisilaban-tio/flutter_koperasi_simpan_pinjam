import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/riwayat_provider.dart';

class SaldoScreen extends StatelessWidget {
  const SaldoScreen({super.key});

  String formatRupiah(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();

    final transaksi = provider.transaksi;

    /// ================= HITUNG SALDO KAS BARU =================
    int saldoKas = 0;

    for (var item in transaksi) {
      int nominal = int.tryParse(item['nominal'].toString()) ?? 0;
      String jenis = item['jenis'] ?? '';

      if (jenis == 'cicilan') {
        saldoKas += nominal; // masuk kas
      } 
      else if (jenis == 'simpanan') {
        saldoKas += nominal; // masuk kas
      } 
      else if (jenis == 'tarik_simpanan') {
        saldoKas -= nominal; // keluar kas
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text("Saldo Kas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: Column(
        children: [

          /// ================= SALDO CARD =================
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Saldo Kas",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),

                Text(
                  formatRupiah(saldoKas),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Total Transaksi: ${transaksi.length}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// ================= LIST TRANSAKSI =================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Transaksi",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transaksi.length,
              itemBuilder: (context, i) {
                final item = transaksi[i];

                final jenis = item['jenis'] ?? '';
                final nama = item['nama'] ?? '-';
                final nominal =
                    int.tryParse(item['nominal'].toString()) ?? 0;

                final cicilanKe = item['cicilan_ke'];
                final tanggal = item['tanggal'] != null
                    ? DateTime.tryParse(item['tanggal']) ??
                        DateTime.now()
                    : DateTime.now();

                /// ================= ICON + WARNA =================
                IconData icon;
                Color color;
                String title;

                if (jenis == 'cicilan') {
                  icon = Icons.payments;
                  color = Colors.green;
                  title = "Pembayaran Cicilan";
                } else if (jenis == 'simpanan') {
                  icon = Icons.savings;
                  color = Colors.blue;
                  title = "Simpanan Masuk";
                } else if (jenis == 'tarik_simpanan') {
                  icon = Icons.money_off;
                  color = Colors.red;
                  title = "Penarikan Simpanan";
                } else {
                  icon = Icons.swap_horiz;
                  color = Colors.grey;
                  title = "Transaksi";
                }

                /// ================= UI ITEM =================
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: Row(
                    children: [

                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(icon, color: color),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              nama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              cicilanKe != null
                                  ? "$title - Cicilan ke $cicilanKe"
                                  : title,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),

                            Text(
                              DateFormat("dd MMM yyyy - HH:mm")
                                  .format(tanggal),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "${jenis == 'tarik_simpanan' ? '-' : '+'}"
                        "${formatRupiah(nominal)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
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