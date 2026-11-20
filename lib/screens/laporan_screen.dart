import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/riwayat_provider.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();
    final data = provider.riwayatList;

    double totalMasuk = 0;
    double piutang = 0;
    double totalPinjaman = 0;
    double totalSimpanan = 0;
    double totalPenarikan = 0;

    /// ================= DATA PINJAMAN =================
    for (var item in data) {
      if ((item['jenis'] ?? 'pinjaman') == 'pinjaman') {
        totalPinjaman +=
            double.tryParse(item['jumlahPinjaman'].toString()) ?? 0;

        final jadwal = item['jadwal'];

        if (jadwal is List) {
          for (var j in jadwal) {
            double angsuran =
                double.tryParse(j['angsuran'].toString()) ?? 0;

            if (j['isPaid'] == true) {
              totalMasuk += angsuran;
            } else {
              piutang += angsuran;
            }
          }
        }
      }

      /// ================= SIMPANAN =================
      if (item['jenis'] == 'simpanan') {
        totalSimpanan +=
            double.tryParse(item['nominal'].toString()) ?? 0;
      }
    }

    /// ================= PENARIKAN =================
    for (var t in provider.transaksi) {
      if (t['jenis'] == 'tarik_simpanan') {
        totalPenarikan +=
            double.tryParse(t['nominal'].toString()) ?? 0;
      }
    }

    /// ================= KAS =================
    double kas = totalMasuk + totalSimpanan - totalPenarikan;

    /// ================= 🔥 FIX TOTAL ASET =================
    double aset = kas + piutang + totalSimpanan;

    /// ================= LABA =================
    double pendapatan = totalMasuk;
    double beban = 0;
    double labaBersih = pendapatan - beban;

    /// ================= ARUS KAS =================
    double kasMasuk = totalMasuk + totalSimpanan;
    double kasKeluar = totalPinjaman + totalPenarikan;
    double saldoKas = kasMasuk - kasKeluar;

    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _header(format.format(labaBersih)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  _cardModern(
                    "Laba Rugi",
                    Icons.bar_chart,
                    Colors.blue,
                    [
                      _row("Pendapatan", format.format(pendapatan)),
                      _row("Beban", format.format(beban)),
                      const Divider(),
                      _rowBold("Laba Bersih", format.format(labaBersih)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ================= NERACA FIX =================
                  _cardModern(
                    "Neraca",
                    Icons.account_balance,
                    Colors.green,
                    [
                      _section("ASET"),
                      _row("Kas", format.format(kas)),
                      _row("Piutang", format.format(piutang)),
                      _row("Simpanan", format.format(totalSimpanan)),
                      const Divider(),
                      _rowBold("Total Aset", format.format(aset)),

                      const SizedBox(height: 10),

                      _section("MODAL"),
                      _rowBold("Modal", format.format(aset)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _cardModern(
                    "Arus Kas",
                    Icons.swap_vert,
                    Colors.orange,
                    [
                      _row("Kas Masuk", format.format(kasMasuk)),
                      _row("Kas Keluar", format.format(kasKeluar)),
                      _row("Penarikan Simpanan",
                          format.format(totalPenarikan)),
                      const Divider(),
                      _rowBold("Saldo Kas", format.format(saldoKas)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _cardModern(
                    "Catatan",
                    Icons.info_outline,
                    Colors.purple,
                    const [
                      Text("• Pendapatan = cicilan dibayar"),
                      Text("• Simpanan = aset + kas koperasi"),
                      Text("• Penarikan = mengurangi kas"),
                      Text("• Piutang = belum dibayar"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= UI (TIDAK DIUBAH) =================
  Widget _header(String laba) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 71, 186, 75), Color.fromARGB(255, 100, 223, 81)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "LAPORAN KEUANGAN",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(
            laba,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _cardModern(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          ...children
        ],
      ),
    );
  }

  Widget _section(String title) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(title));

  Widget _row(String t, String v) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t), Text(v)]);

  Widget _rowBold(String t, String v) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
      
}