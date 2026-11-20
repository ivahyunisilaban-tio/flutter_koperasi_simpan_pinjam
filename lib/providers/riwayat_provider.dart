import 'package:flutter/material.dart';

class RiwayatProvider extends ChangeNotifier {

  // ================= DRAFT =================
  final List<Map<String, dynamic>> _draftList = [];

  List<Map<String, dynamic>> get draftList => _draftList;

  void tambahDraft(Map<String, dynamic> data) {
    _draftList.add(data);
    notifyListeners();
  }

  void updateDraft(int index, Map<String, dynamic> data) {
    _draftList[index] = {
      ..._draftList[index],
      ...data,
    };
    notifyListeners();
  }

  void hapusDraft(int index) {
    _draftList.removeAt(index);
    notifyListeners();
  }

  void setRekapDraft(int index) {
    _draftList[index]['rekap'] = true;
    notifyListeners();
  }

  // ================= RIWAYAT =================
  final List<Map<String, dynamic>> _riwayat = [];

  List<Map<String, dynamic>> get riwayatList => _riwayat;

  int _saldoKas = 0;
  final List<Map<String, dynamic>> _transaksi = [];

  int get saldoKas => _saldoKas;
  List<Map<String, dynamic>> get transaksi => _transaksi;

  // ================= TAMBAH =================
  void tambahRiwayat(Map<String, dynamic> data) {
    _riwayat.add({
      ...data,
      'rekap': true,
    });
    notifyListeners();
  }

  // ================= UPDATE UMUM =================
  void updateById(String id, Map<String, dynamic> newData) {
    final index = _riwayat.indexWhere((e) => e['id'] == id);

    if (index != -1) {
      _riwayat[index] = {
        ..._riwayat[index],
        ...newData,
      };
      notifyListeners();
    }
  }

  // ================= REKAP =================
  void updateRekapById(String id, Map<String, dynamic> hasil) {
    final index = _riwayat.indexWhere((e) => e['id'] == id);

    if (index != -1) {
      _riwayat[index] = {
        ..._riwayat[index],
        'rekap': true,
        'jadwal': hasil['jadwal'] ?? [],
        'image': hasil['image'],
        'totalBayar': hasil['totalBayar'] ?? 0,
        'totalBunga': hasil['totalBunga'] ?? 0,
      };
      notifyListeners();
    }
  }

  // ================= HAPUS =================
  void hapusById(String id) {
    _riwayat.removeWhere((e) => e['id'] == id);
    notifyListeners();
  }

  // ================= BAYAR CICILAN + SALDO =================
  void bayarCicilanDanTambahSaldo(
    String id,
    int index,
    bool value,
  ) {
    final i = _riwayat.indexWhere((e) => e['id'] == id);
    if (i == -1) return;

    final jadwal =
        List<Map<String, dynamic>>.from(_riwayat[i]['jadwal'] ?? []);

    if (index < 0 || index >= jadwal.length) return;

    final item = Map<String, dynamic>.from(jadwal[index]);

    final nominal = (item['angsuran'] is num)
        ? (item['angsuran'] as num).toDouble()
        : double.tryParse(item['angsuran'].toString()) ?? 0.0;

    if (value == true && item['isPaid'] != true) {
      item['isPaid'] = true;
      _saldoKas += nominal.toInt();

      _transaksi.add({
        'jenis': 'cicilan',
        'id': id,
        'cicilan_ke': item['cicilan_ke'],
        'nominal': nominal,
        'tanggal': DateTime.now().toIso8601String(),
        'nama': _riwayat[i]['nama'] ?? '-',
      });

    } else if (value == false && item['isPaid'] == true) {
      item['isPaid'] = false;
      _saldoKas -= nominal.toInt();

      _transaksi.removeWhere((t) =>
          t['id'] == id &&
          t['cicilan_ke'] == item['cicilan_ke']);
    }

    jadwal[index] = item;
    _riwayat[i]['jadwal'] = jadwal;

    notifyListeners();
  }

  // ================= PROGRESS =================
  double progressCicilan(Map data) {
    final jadwal = data['jadwal'];

    if (jadwal is! List || jadwal.isEmpty) return 0;

    final list = jadwal.whereType<Map>().toList();

    if (list.isEmpty) return 0.0;

    final sudahBayar =
        list.where((e) => e['isPaid'] == true).length;

    return sudahBayar / list.length;
  }

  // ================= SIMPANAN =================
  void tambahSimpanan(Map<String, dynamic> data) {
    _riwayat.add({
      ...data,
      'jenis': 'simpanan',
      'nominal': data['nominal'] ?? 0,
      'jumlah_transaksi': 0,
    });
    notifyListeners();
  }

  void tambahSaldoSimpanan(int index, int nominal) {
    int current =
        int.tryParse(_riwayat[index]['nominal'].toString()) ?? 0;

    int count =
        (_riwayat[index]['jumlah_transaksi'] ?? 0) + 1;

    _riwayat[index]['nominal'] = current + nominal;
    _riwayat[index]['jumlah_transaksi'] = count;

    _transaksi.add({
      'jenis': 'simpanan',
      'nominal': nominal,
      'tanggal': DateTime.now().toString(),
      'nama': _riwayat[index]['nama'] ?? '-',
      'keterangan': 'Simpanan ke-$count',
    });

    notifyListeners();
  }

  void tarikSaldoSimpanan(int index, int nominal) {
    int current =
        int.tryParse(_riwayat[index]['nominal'].toString()) ?? 0;

    if (nominal <= 0 || nominal > current) return;

    int count =
        (_riwayat[index]['jumlah_transaksi'] ?? 0) + 1;

    _riwayat[index]['nominal'] = current - nominal;
    _riwayat[index]['jumlah_transaksi'] = count;

    _transaksi.add({
      'jenis': 'tarik_simpanan',
      'nominal': nominal,
      'tanggal': DateTime.now().toString(),
      'nama': _riwayat[index]['nama'] ?? '-',
      'keterangan': 'Penarikan ke-$count',
    });

    notifyListeners();
  }
}