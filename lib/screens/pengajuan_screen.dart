import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/riwayat_provider.dart';
import 'bukti_pencairan_screen.dart';

class PengajuanScreen extends StatefulWidget {
  const PengajuanScreen({super.key});

  @override
  State<PengajuanScreen> createState() => _PengajuanScreenState();
}

class _PengajuanScreenState extends State<PengajuanScreen> {
  late RiwayatProvider riwayatProvider;

  final _formKey = GlobalKey<FormState>();

  String modeForm = 'create';

  List<Map<String, dynamic>> draftList = [];
  List<Map<String, dynamic>> riwayatList = [];

  int? selectedIndex;

  final idController = TextEditingController();
  final namaController = TextEditingController();
  final tempatLahirController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final alamatController = TextEditingController();
  final noHpController = TextEditingController();
  final pekerjaanController = TextEditingController();

  String statusNasabah = 'Belum Kawin';
  String namaPaket = 'Reguler';
  String tanggalDaftar = '';

  int selectedMenu = 0;

  @override
  void initState() {
    super.initState();
    tanggalDaftar = DateTime.now().toString().substring(0, 10);
  }

  void simpanData() {
    if (_formKey.currentState!.validate()) {
      if (modeForm == 'edit') {
        updateData();
        return;
      }

      setState(() {
        draftList.add({
          'id': idController.text,
          'nama': namaController.text,
          'tempat_lahir': tempatLahirController.text,
          'tanggal_lahir': tanggalLahirController.text,
          'alamat': alamatController.text,
          'hp': noHpController.text,
          'pekerjaan': pekerjaanController.text,
          'tanggal_daftar': tanggalDaftar,
          'status': statusNasabah,
          'paket': namaPaket,
          'jadwal': [],
          'totalBayar': 0,
          'totalBunga': 0,
          'rekap': false,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data masuk ke Draft'),
        ),
      );

      modeForm = 'create';
      selectedIndex = null;

      clearForm();
    }
  }

  void updateData() {
    if (_formKey.currentState!.validate() &&
        selectedIndex != null) {
      setState(() {
        draftList[selectedIndex!] = {
          'id': idController.text,
          'nama': namaController.text,
          'tempat_lahir': tempatLahirController.text,
          'tanggal_lahir': tanggalLahirController.text,
          'alamat': alamatController.text,
          'hp': noHpController.text,
          'pekerjaan': pekerjaanController.text,
          'tanggal_daftar': tanggalDaftar,
          'status': statusNasabah,
          'paket': namaPaket,
        };

        modeForm = 'create';
        selectedIndex = null;
        selectedMenu = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diupdate'),
        ),
      );

      clearForm();
    }
  }

  void deleteData() {
    if (selectedIndex != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Yakin ingin hapus data?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  draftList.removeAt(selectedIndex!);

                  selectedIndex = null;
                  modeForm = 'create';
                  selectedMenu = 1;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Data berhasil dihapus',
                    ),
                  ),
                );

                clearForm();
              },
              child: const Text('Hapus'),
            ),
          ],
        ),
      );
    }
  }

  void clearForm() {
    namaController.clear();
    idController.clear();
    tempatLahirController.clear();
    tanggalLahirController.clear();
    alamatController.clear();
    noHpController.clear();
    pekerjaanController.clear();

    tanggalDaftar =
        DateTime.now().toString().substring(0, 10);

    statusNasabah = 'Belum Kawin';
    namaPaket = 'Reguler';
  }

  @override
  Widget build(BuildContext context) {
    riwayatProvider =
        Provider.of<RiwayatProvider>(context);

    final isMobile =
        MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text('Pengajuan Nasabah'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      body: isMobile
          ? Column(
              children: [

                // MENU MOBILE
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: buildSidebarItem(
                          Icons.person,
                          'Form',
                          0,
                        ),
                      ),
                      Expanded(
                        child: buildSidebarItem(
                          Icons.edit,
                          'Draft',
                          1,
                        ),
                      ),
                    ],
                  ),
                ),

                // CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: selectedMenu == 0
                        ? buildForm()
                        : buildDraftList(),
                  ),
                ),
              ],
            )

          // DESKTOP
          : Row(
              children: [

                // SIDEBAR
                Container(
                  width: 200,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      buildSidebarItem(
                        Icons.person,
                        'Form Pengajuan',
                        0,
                      ),

                      buildSidebarItem(
                        Icons.edit,
                        'Draft',
                        1,
                      ),
                    ],
                  ),
                ),

                // CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: selectedMenu == 0
                        ? buildForm()
                        : buildDraftList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildSidebarItem(
    IconData icon,
    String title,
    int index,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedMenu = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selectedMenu == index
                  ? Colors.green
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selectedMenu == index
                  ? Colors.green
                  : Colors.grey,
            ),

            const SizedBox(height: 5),

            Text(
              title,
              style: TextStyle(
                color: selectedMenu == index
                    ? Colors.green
                    : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FORM
  Widget buildForm() {
    return SingleChildScrollView(
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,

      child: Card(
        elevation: 5,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        child: Padding(
          padding: const EdgeInsets.all(15),

          child: Form(
            key: _formKey,

            child: Column(
              children: [

                TextFormField(
                  controller: idController,

                  decoration: const InputDecoration(
                    labelText: 'ID Nasabah',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),

                  validator: (v) =>
                      v!.isEmpty ? 'Wajib diisi' : null,
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: namaController,

                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),

                  validator: (v) =>
                      v!.isEmpty ? 'Wajib diisi' : null,
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: tempatLahirController,

                  decoration: const InputDecoration(
                    labelText: 'Tempat Lahir',
                    prefixIcon:
                        Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),

                  validator: (v) =>
                      v!.isEmpty ? 'Wajib diisi' : null,
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: tanggalLahirController,

                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir',
                    prefixIcon:
                        Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),

                  validator: (v) =>
                      v!.isEmpty ? 'Wajib diisi' : null,
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: alamatController,

                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    prefixIcon: Icon(Icons.home),
                    border: OutlineInputBorder(),
                  ),

                  validator: (v) =>
                      v!.isEmpty ? 'Wajib diisi' : null,
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,

                  decoration: const InputDecoration(
                    labelText: 'No HP',
                    prefixIcon: Icon(Icons.call),
                    border: OutlineInputBorder(),
                  ),

                  validator: (v) =>
                      v!.isEmpty ? 'Wajib diisi' : null,
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: pekerjaanController,

                  decoration: const InputDecoration(
                    labelText: 'Pekerjaan',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),

                  validator: (v) =>
                      v!.isEmpty ? 'Wajib diisi' : null,
                ),

                const SizedBox(height: 10),

                TextFormField(
                  initialValue: tanggalDaftar,
                  readOnly: true,

                  decoration: const InputDecoration(
                    labelText: 'Tanggal Daftar',
                    prefixIcon:
                        Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: statusNasabah,

                  items: const [
                    DropdownMenuItem(
                      value: 'Belum Kawin',
                      child: Text('Belum Kawin'),
                    ),
                    DropdownMenuItem(
                      value: 'Kawin',
                      child: Text('Kawin'),
                    ),
                    DropdownMenuItem(
                      value: 'Cerai Hidup',
                      child: Text('Cerai Hidup'),
                    ),
                    DropdownMenuItem(
                      value: 'Cerai Mati',
                      child: Text('Cerai Mati'),
                    ),
                  ],

                  onChanged: (value) {
                    setState(() {
                      statusNasabah = value!;
                    });
                  },

                  decoration: const InputDecoration(
                    labelText: 'Status Nasabah',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: namaPaket,

                  items: const [
                    DropdownMenuItem(
                      value: 'Reguler',
                      child: Text('Reguler'),
                    ),
                    DropdownMenuItem(
                      value: 'Cepat',
                      child: Text('Cepat'),
                    ),
                    DropdownMenuItem(
                      value: 'Khusus',
                      child: Text('Khusus'),
                    ),
                  ],

                  onChanged: (value) {
                    setState(() {
                      namaPaket = value!;
                    });
                  },

                  decoration: const InputDecoration(
                    labelText: 'Nama Paket',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,

                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),

                        onPressed:
                            modeForm == 'create'
                                ? simpanData
                                : updateData,

                        child: Text(
                          modeForm == 'create'
                              ? 'Simpan'
                              : 'Update',
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    if (modeForm == 'edit')
                      Expanded(
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red,
                          ),

                          onPressed: deleteData,

                          child: const Text(
                            'Delete',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DRAFT LIST
  Widget buildDraftList() {
    if (draftList.isEmpty) {
      return const Center(
        child: Text('Belum ada data draft'),
      );
    }

    return ListView.builder(
      itemCount: draftList.length,

      itemBuilder: (context, index) {
        final data = draftList[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),

          child: Column(
            children: [

              // DATA NASABAH
              ListTile(
                title: Text(
                  data['nama']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),

                  child: Text(
                    'ID: ${data['id']}\n'
                    'Tempat/Tanggal Lahir: '
                    '${data['tempat_lahir']}, '
                    '${data['tanggal_lahir']}\n'
                    'Alamat: ${data['alamat']}\n'
                    'No HP: ${data['hp']}\n'
                    'Pekerjaan: ${data['pekerjaan']}\n'
                    'Tgl Daftar: ${data['tanggal_daftar']}\n'
                    'Status: ${data['status']}\n'
                    'Paket: ${data['paket']}\n'
                    '${data['rekap'] == true ? 'SUDAH DIREKAP' : ''}',
                  ),
                ),

                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),

              // BUTTON ACTION
              if (selectedIndex == index)
                Padding(
                  padding: const EdgeInsets.all(10),

                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,

                    children: [

                      // UPDATE
                      SizedBox(
                        width: 120,

                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.orange,
                          ),

                          onPressed: () {
                            setState(() {
                              modeForm = 'edit';

                              selectedIndex = index;

                              idController.text =
                                  data['id']!;

                              namaController.text =
                                  data['nama']!;

                              tempatLahirController
                                      .text =
                                  data[
                                      'tempat_lahir']!;

                              tanggalLahirController
                                      .text =
                                  data[
                                      'tanggal_lahir']!;

                              alamatController.text =
                                  data['alamat']!;

                              noHpController.text =
                                  data['hp']!;

                              pekerjaanController
                                      .text =
                                  data['pekerjaan']!;

                              tanggalDaftar =
                                  data[
                                      'tanggal_daftar']!;

                              statusNasabah =
                                  data['status']!;

                              namaPaket =
                                  data['paket']!;

                              selectedMenu = 0;
                            });
                          },

                          child: const Text(
                            'Update',
                          ),
                        ),
                      ),

                      // DELETE
                      SizedBox(
                        width: 120,

                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red,
                          ),

                          onPressed: () {
                            setState(() {
                              draftList.removeAt(index);

                              selectedIndex = null;
                            });

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Data dihapus',
                                ),
                              ),
                            );
                          },

                          child: const Text(
                            'Delete',
                          ),
                        ),
                      ),

                      // DISETUJUI
                      SizedBox(
                        width: 120,

                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green,
                          ),

                          onPressed: () async {
                            final result =
                                await Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (context) =>
                                    BuktiPencairanScreen(
                                  data:
                                      draftList[index],

                                  index: index,
                                ),
                              ),
                            );

                            if (result != null) {
                              final riwayatProvider =
                                  Provider.of<
                                      RiwayatProvider>(
                                context,
                                listen: false,
                              );

                              riwayatProvider
                                  .tambahRiwayat({
                                ...draftList[index],
                                ...result,
                                'rekap': true,
                              });

                              setState(() {
                                draftList[index]
                                    ['rekap'] = true;
                              });

                              if (!mounted) return;

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pengajuan berhasil disetujui',
                                  ),
                                ),
                              );

                              Navigator.pushNamed(
                                context,
                                '/riwayat',
                              );
                            }
                          },

                          child: const Text(
                            'Disetujui',
                          ),
                        ),
                      ),

                      // DITOLAK
                      SizedBox(
                        width: 120,

                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey,
                          ),

                          onPressed: () {
                            setState(() {
                              draftList.removeAt(index);

                              selectedIndex = null;
                            });

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pengajuan ditolak',
                                ),
                              ),
                            );
                          },

                          child: const Text(
                            'Ditolak',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}