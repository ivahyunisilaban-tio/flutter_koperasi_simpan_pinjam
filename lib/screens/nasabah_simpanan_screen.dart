import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/riwayat_provider.dart';

class NasabahSimpananScreen extends StatelessWidget {
  const NasabahSimpananScreen({super.key});

  String rupiah(int value) => "Rp $value";

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiwayatProvider>();

    final simpananList = provider.riwayatList
        .where((e) => e['jenis'] == 'simpanan')
        .toList();

    int totalSimpanan = simpananList.fold(
      0,
      (sum, item) =>
          sum + (int.tryParse(item['nominal'].toString()) ?? 0),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Nasabah Simpanan"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tambahNasabah(context),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [

          /// ===== TOTAL =====
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Total Simpanan\n${rupiah(totalSimpanan)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ===== LIST =====
          Expanded(
            child: simpananList.isEmpty
                ? const Center(child: Text("Belum ada nasabah"))
                : ListView.builder(
                    itemCount: simpananList.length,
                    itemBuilder: (context, index) {
                      final item = simpananList[index];

                      /// 🔥 INDEX ASLI
                      final realIndex =
                          provider.riwayatList.indexOf(item);

                      final saldo = int.tryParse(
                              item['nominal'].toString()) ??
                          0;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.purple.withOpacity(0.2),
                            child: const Icon(Icons.person,
                                color: Colors.purple),
                          ),
                          title: Text(item['nama'] ?? '-'),
                          subtitle: Text(rupiah(saldo)),

                          /// 🔥 AKSI
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.green),
                                onPressed: () => _tambahSaldo(
                                    context, realIndex),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.red),
                                onPressed: () => _tarikSaldo(
                                    context, realIndex),
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

  /// ================= TAMBAH NASABAH =================
  void _tambahNasabah(BuildContext context) {
    final nama = TextEditingController();
    final nominal = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Nasabah"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nama,
              decoration:
                  const InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: nominal,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Setoran Awal"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Provider.of<RiwayatProvider>(context,
                      listen: false)
                  .tambahSimpanan({
                'nama': nama.text,
                'nominal':
                    int.tryParse(nominal.text) ?? 0,
                'jenis': 'simpanan',
              });

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  /// ================= TAMBAH SALDO =================
  void _tambahSaldo(BuildContext context, int index) {
    final nominal = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Saldo"),
        content: TextField(
          controller: nominal,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: "Nominal"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              final value =
                  int.tryParse(nominal.text) ?? 0;

              Provider.of<RiwayatProvider>(context,
                      listen: false)
                  .tambahSaldoSimpanan(index, value);

              Navigator.pop(context);
            },
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }

  /// ================= TARIK SALDO =================
  void _tarikSaldo(BuildContext context, int index) {
    final nominal = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tarik Saldo"),
        content: TextField(
          controller: nominal,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: "Nominal"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              final value =
                  int.tryParse(nominal.text) ?? 0;

              Provider.of<RiwayatProvider>(context,
                      listen: false)
                  .tarikSaldoSimpanan(index, value);

              Navigator.pop(context);
            },
            child: const Text("Tarik"),
          ),
        ],
      ),
    );
  }
}