import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataWargaScreen extends StatefulWidget {
  @override
  _DataWargaScreenState createState() => _DataWargaScreenState();
}

class _DataWargaScreenState extends State<DataWargaScreen> {
  List<dynamic> wargaList = [];

  @override
  void initState() {
    super.initState();
    _fetchDataWarga();
  }

  Future<void> _fetchDataWarga() async {
    try {
      final response = await http.get(Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/warga/datawarga.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          wargaList = data['warga'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data warga')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  void _showActionDialog(String nik) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Lihat Detail'),
              onTap: () {
                Navigator.pop(context);
                _showDetailDialog(nik);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Ubah Data'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(nik);
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Mutasi Data'),
              onTap: () {
                print("Mutasi Data tapped for NIK: $nik");  // Debug log
                Navigator.pop(context);
                _showMutasiDialog(nik);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Hapus Data', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteData(nik);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDetailDialog(String nik) async {
    final response = await http.get(Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/warga/lihat_warga.php?nik=$nik'));
    final data = json.decode(response.body);

    if (data['error'] != null) {
      print(data['error']);
    } else {
      final warga = data['data'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Detail Warga'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A. Data Pribadi', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('NIK: ${warga['nik_warga']}'),
                  Text('Nama Warga: ${warga['nama_warga']}'),
                  Text('Tempat Lahir: ${warga['tempat_lahir_warga']}'),
                  Text('Tanggal Lahir: ${warga['tanggal_lahir_warga']}'),
                  Text('Jenis Kelamin: ${warga['jenis_kelamin_warga']}'),
                  SizedBox(height: 12),
                  Text('B. Data Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Alamat KTP: ${warga['alamat_ktp_warga']}'),
                  Text('Alamat: ${warga['alamat_warga']}'),
                  Text('Desa/Kelurahan: ${warga['desa_kelurahan_warga']}'),
                  Text('Kecamatan: ${warga['kecamatan_warga']}'),
                  Text('Kabupaten/Kota: ${warga['kabupaten_kota_warga']}'),
                  Text('Provinsi: ${warga['provinsi_warga']}'),
                  Text('Negara: ${warga['negara_warga']}'),
                  Text('RT: ${warga['rt_warga']}'),
                  Text('RW: ${warga['rw_warga']}'),
                  SizedBox(height: 12),
                  Text('C. Data Lain-lain', style: TextStyle (fontWeight: FontWeight.bold)),
                  Text('Agama: ${warga['agama_warga']}'),
                  Text('Pendidikan: ${warga['pendidikan_terakhir_warga']}'),
                  Text('Pekerjaan: ${warga['pekerjaan_warga']}'),
                  Text('Status Perkawinan: ${warga['status_perkawinan_warga']}'),
                  Text('Status Tinggal: ${warga['status_warga']}'),
                  SizedBox(height: 12),
                  Text('D. Data Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Diinput oleh: ${warga['id_user']}'),
                  Text('Diinput: ${warga['created_at']}'),
                  Text('Diperbaharui: ${warga['updated_at']}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Tutup'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showEditDialog(String nik) async {
    final response = await http.get(Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/warga/lihat_warga.php?nik=$nik'));
    final warga = json.decode(response.body)['data'];

    final TextEditingController nameController = TextEditingController(text: warga['nama_warga']);
    final TextEditingController tempatLahirController = TextEditingController(text: warga['tempat_lahir_warga']);
    final TextEditingController pekerjaanController = TextEditingController(text: warga['pekerjaan_warga']);

    // Initialize dropdown values with validation
    String jenisKelamin = warga['jenis_kelamin_warga'];
    if (!['Laki-laki', 'Perempuan'].contains(jenisKelamin)) {
      jenisKelamin = 'Laki-laki'; // Default value
    }

    String agama = warga['agama_warga'];
    if (!['Islam', 'Kristen', 'Katholik', 'Hindu', 'Budha'].contains(agama)) {
      agama = 'Islam'; // Default value
    }

    String pendidikan = warga['pendidikan_terakhir_warga'];
    if (!['Tidak Sekolah', 'Tidak Tamat SD', 'SD', 'SMP', 'SMA'].contains(pendidikan)) {
      pendidikan = 'SD'; // Default value
    }

    String statusPerkawinan = warga['status_perkawinan_warga'];
    if (!['Kawin', 'Tidak Kawin'].contains(statusPerkawinan)) {
      statusPerkawinan = 'Tidak Kawin'; // Default value
    }

    String statusTinggal = warga['status_warga'];
    if (!['Tetap', 'Kontrak'].contains(statusTinggal)) {
      statusTinggal = 'Tetap'; // Default value
    }

    DateTime? tanggalLahir = DateTime.tryParse(warga['tanggal_lahir_warga']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ubah Data Warga'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: tempatLahirController,
                  decoration: InputDecoration(labelText: 'Tempat Lahir'),
                ),
                GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: tanggalLahir ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        tanggalLahir = pickedDate;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Tanggal Lahir'),
                      controller: TextEditingController(
                        text: tanggalLahir == null
                            ? ''
                            : '${tanggalLahir!.year}-${tanggalLahir!.month.toString().padLeft(2, '0')}-${tanggalLahir!.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: jenisKelamin,
                  items: ['Laki-laki', 'Perempuan']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => jenisKelamin = value!),
                  decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                ),
                DropdownButtonFormField<String>(
                  value: agama,
                  items: ['Islam', 'Kristen', 'Katholik', 'Hindu', 'Budha']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => agama = value!),
                  decoration: InputDecoration(labelText: 'Agama'),
                ),
                DropdownButtonFormField<String>(
                  value: pendidikan,
                  items: ['Tidak Sekolah', 'Tidak Tamat SD', 'SD', 'SMP', 'SMA']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => pendidikan = value!),
                  decoration: InputDecoration(labelText: 'Pendidikan Terakhir'),
                ),
                TextField(
                  controller: pekerjaanController,
                  decoration: InputDecoration(labelText: 'Pekerjaan'),
                ),
                DropdownButtonFormField<String>(
                  value: statusPerkawinan,
                  items: ['Kawin', 'Tidak Kawin']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => statusPerkawinan = value!),
                  decoration: InputDecoration(labelText: 'Status Perkawinan'),
                ),
                DropdownButtonFormField<String>(
                  value: statusTinggal,
                  items: ['Tetap', 'Kontrak']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => statusTinggal = value!),
                  decoration: InputDecoration(labelText: 'Status Tinggal'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final response = await http.post(
                  Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/warga/update_warga.php'),
                  body: {
                    'nik': nik,
                    'nama': nameController.text,
                    'tempat_lahir': tempatLahirController.text,
                    'tanggal_lahir': tanggalLahir?.toIso8601String(),
                    'jenis_kelamin': jenisKelamin,
                    'agama': agama,
                    'pendidikan_terakhir': pendidikan,
                    'pekerjaan': pekerjaanController.text,
                    'status_perkawinan': statusPerkawinan,
                    'status_warga': statusTinggal,
                  },
                );

                final data = json.decode(response.body);
                if (data['error'] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Error: ${data['error']}',
                              style: TextStyle(color: Colors.black), // Mengubah warna teks
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.greenAccent),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Data berhasil diperbarui',
                              style: TextStyle(color: Colors.black), // Mengubah warna teks
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                  _fetchDataWarga();
                  Navigator.pop(context);
                }

              },
              child: Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMutasiDialog(String nik) async {
    // Tetapkan id_user secara statis menjadi '1'
    String idUser = '1';

    // Tampilkan dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Mutasi Data'),
          content: Text('Apakah Anda yakin ingin memindahkan data warga dengan NIK $nik ke tabel mutasi?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                String idMutasi = 'your_mutasi_id_here'; // ID mutasi yang Anda gunakan
                if (nik.isEmpty || idMutasi.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('NIK atau ID Mutasi tidak boleh kosong')),
                  );
                  return;
                }

                try {
                  final response = await http.post(
                    Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/warga/mutasi_warga.php'),
                    body: {
                      'nik': nik,
                      'id_mutasi': idMutasi,
                      'id_user': idUser, // Kirim ID User yang ditetapkan secara statis
                    },
                  );

                  if (response.statusCode == 200) {
                    final data = json.decode(response.body);

                    if (data.containsKey('success')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(data['success'])),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${data['error']}')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Server error: ${response.statusCode}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Terjadi kesalahan: $e')),
                  );
                }
              },
              child: Text('Ya'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Tidak'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _deleteData(String nik) async {
    final response = await http.post(
      Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/warga/hapus_warga.php'),
      body: {'nik': nik},
    );

    final data = json.decode(response.body);
    if (data['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Error: ${data['error']}',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Data berhasil dihapus',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      _fetchDataWarga();
    }
  }

  Future<void> _addWarga() async {
    final TextEditingController nikController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController tempatLahirController = TextEditingController();
    final TextEditingController alamatKTPController = TextEditingController();
    final TextEditingController alamatController = TextEditingController();
    final TextEditingController desaController = TextEditingController();
    final TextEditingController kecamatanController = TextEditingController();
    final TextEditingController kabupatenController = TextEditingController();
    final TextEditingController provinsiController = TextEditingController();
    final TextEditingController negaraController = TextEditingController();
    final TextEditingController rtController = TextEditingController();
    final TextEditingController rwController = TextEditingController();
    final TextEditingController pekerjaanController = TextEditingController();

    String jenisKelamin = 'Laki-laki';
    String agama = 'Islam';
    String pendidikan = 'Tidak Sekolah';
    String statusPerkawinan = 'Tidak Kawin';
    String statusTinggal = 'Tetap';
    int? tahunLahir;
    int? bulanLahir;
    int? tanggalLahir;

    // Get id_user from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idUser = prefs.getInt('id_user');

    if (idUser == null) {
      // Jika `id_user` tidak ditemukan, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kesalahan autentikasi. Silakan login kembali.'),
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Data Warga'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A. Data Pribadi
                Text('A. Data Pribadi', style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: nikController,
                  decoration: InputDecoration(labelText: 'NIK'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama Warga'),
                ),
                TextField(
                  controller: tempatLahirController,
                  decoration: InputDecoration(labelText: 'Tempat Lahir'),
                ),
                // Input Tanggal Lahir with DatePicker
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        tahunLahir = pickedDate.year;
                        bulanLahir = pickedDate.month;
                        tanggalLahir = pickedDate.day;
                      });
                    }
                  },
                  child: Text('Pilih Tanggal Lahir'),
                ),
                // Dropdown for Jenis Kelamin
                DropdownButtonFormField<String>(
                  value: jenisKelamin,
                  items: ['Laki-laki', 'Perempuan']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => jenisKelamin = value!),
                  decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                ),
                // B. Data Alamat
                SizedBox(height: 16),
                Text('B. Data Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: alamatKTPController,
                  decoration: InputDecoration(labelText: 'Alamat KTP'),
                ),
                TextField(
                  controller: alamatController,
                  decoration: InputDecoration(labelText: 'Alamat Tinggal'),
                ),
                TextField(
                  controller: desaController,
                  decoration: InputDecoration(labelText: 'Desa/Kelurahan'),
                ),
                TextField(
                  controller: kecamatanController,
                  decoration: InputDecoration(labelText: 'Kecamatan'),
                ),
                TextField(
                  controller: kabupatenController,
                  decoration: InputDecoration(labelText: 'Kabupaten/Kota'),
                ),
                TextField(
                  controller: provinsiController,
                  decoration: InputDecoration(labelText: 'Provinsi'),
                ),
                TextField(
                  controller: negaraController,
                  decoration: InputDecoration(labelText: 'Negara'),
                ),
                TextField(
                  controller: rtController,
                  decoration: InputDecoration(labelText: 'RT'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rwController,
                  decoration: InputDecoration(labelText: 'RW'),
                  keyboardType: TextInputType.number,
                ),
                // C. Data Lain-lain
                SizedBox(height: 16),
                Text('C. Data Lain-lain', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: agama,
                  items: ['Islam', 'Kristen', 'Katholik', 'Hindu', 'Budha']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => agama = value!),
                  decoration: InputDecoration(labelText: 'Agama'),
                ),
                DropdownButtonFormField<String>(
                  value: pendidikan,
                  items: ['Tidak Sekolah', 'Tidak Tamat SD', 'SD', 'SMP', 'SMA']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => pendidikan = value!),
                  decoration: InputDecoration(labelText: 'Pendidikan Terakhir'),
                ),
                TextField(
                  controller: pekerjaanController,
                  decoration: InputDecoration(labelText: 'Pekerjaan'),
                ),
                DropdownButtonFormField<String>(
                  value: statusPerkawinan,
                  items: ['Kawin', 'Tidak Kawin']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => statusPerkawinan = value!),
                  decoration: InputDecoration(labelText: 'Status Perkawinan'),
                ),
                DropdownButtonFormField<String>(
                  value: statusTinggal,
                  items: ['Tetap', 'Kontrak']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => statusTinggal = value!),
                  decoration: InputDecoration(labelText: 'Status Tinggal'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Validation
                if (nikController.text.isEmpty ||
                    nameController.text.isEmpty ||
                    tempatLahirController.text.isEmpty ||
                    tahunLahir == null ||
                    bulanLahir == null ||
                    tanggalLahir == null ||
                    alamatKTPController.text.isEmpty ||
                    alamatController.text.isEmpty ||
                    desaController.text.isEmpty ||
                    kecamatanController.text.isEmpty ||
                    kabupatenController.text.isEmpty ||
                    provinsiController.text.isEmpty ||
                    negaraController.text.isEmpty ||
                    rtController.text.isEmpty ||
                    rwController.text.isEmpty ||
                    pekerjaanController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Semua kolom wajib diisi')));
                  return;
                }

                try {
                  final response = await http.post(
                    Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/warga/tambah_warga.php'),
                    body: {
                      'nik_warga': nikController.text,
                      'nama_warga': nameController.text,
                      'tempat_lahir_warga': tempatLahirController.text,
                      'tanggal_lahir_warga': '$tahunLahir-${bulanLahir.toString().padLeft(2, '0')}-${tanggalLahir.toString().padLeft(2, '0')}',
                      'jenis_kelamin_warga': jenisKelamin,
                      'alamat_ktp_warga': alamatKTPController.text,
                      'alamat_warga': alamatController.text,
                      'desa_kelurahan_warga': desaController.text,
                      'kecamatan_warga': kecamatanController.text,
                      'kabupaten_kota_warga': kabupatenController.text,
                      'provinsi_warga': provinsiController.text,
                      'negara_warga': negaraController.text,
                      'rt_warga': rtController.text, // Pastikan ini string
                      'rw_warga': rwController.text, // Pastikan ini string
                      'agama_warga': agama,
                      'pendidikan_terakhir_warga': pendidikan,
                      'pekerjaan_warga': pekerjaanController.text,
                      'status_perkawinan_warga': statusPerkawinan,
                      'status_warga': statusTinggal,
                      'id_user': idUser.toString(), // Ubah menjadi string
                    },
                  );

                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.greenAccent),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Data warga berhasil ditambahkan',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                    _fetchDataWarga(); // Refresh data
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Gagal menambahkan data warga',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orangeAccent),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Terjadi kesalahan: $e',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Warga'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: wargaList.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3 / 4,
          ),
          itemCount: wargaList.length,
          itemBuilder: (context, index) {
            final warga = wargaList[index];
            return GestureDetector(
              onTap: () => _showActionDialog(warga['nik']),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blueAccent.shade100,
                        child: Text(
                          warga['nama'][0],
                          style: TextStyle(fontSize: 32, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        warga['nama'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'NIK: ${warga['nik']}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWarga,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}