import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kartu Keluarga App'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Lihat Data Kartu Keluarga'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DataKartuKeluargaScreen()),
            );
          },
        ),
      ),
    );
  }
}

class DataKartuKeluargaScreen extends StatefulWidget {
  @override
  _DataKartuKeluargaScreenState createState() =>
      _DataKartuKeluargaScreenState();
}

class _DataKartuKeluargaScreenState extends State<DataKartuKeluargaScreen> {
  List<dynamic> kartuKeluargaList = [];
  List<dynamic> kepalaKeluargaList = [];
  String? selectedKepalaKeluarga;

  final TextEditingController nomorKeluargaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController desaController = TextEditingController();
  final TextEditingController kecamatanController = TextEditingController();
  final TextEditingController kabupatenController = TextEditingController();
  final TextEditingController provinsiController = TextEditingController();
  final TextEditingController negaraController = TextEditingController();
  final TextEditingController rtController = TextEditingController();
  final TextEditingController rwController = TextEditingController();
  final TextEditingController kodePosController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchKartuKeluarga();
    fetchKepalaKeluarga();
  }

  Future<void> fetchKartuKeluarga() async {
    final url = Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/kartukeluarga/kartu_keluarga.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        kartuKeluargaList = data['kartu_keluarga'];
      });
    } else {
      throw Exception('Failed to load kartu keluarga');
    }
  }

  Future<void> fetchKepalaKeluarga() async {
    final url = Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/kartukeluarga/ambil_warga.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        kepalaKeluargaList = data['warga'];
      });
    } else {
      throw Exception('Failed to load kepala keluarga');
    }
  }

  Future<void> addKartuKeluarga() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mendapatkan waktu saat ini
    String createdAt = DateTime.now().toIso8601String();
    String updatedAt = DateTime.now().toIso8601String();

    final url = Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/kartukeluarga/tambah_kartu_keluarga.php');
    final response = await http.post(
      url,
      body: {
        'nomor_keluarga': nomorKeluargaController.text,
        'id_kepala_keluarga': selectedKepalaKeluarga!,
        'alamat_keluarga': alamatController.text,
        'desa_kelurahan_keluarga': desaController.text,
        'kecamatan_keluarga': kecamatanController.text,
        'kabupaten_kota_keluarga': kabupatenController.text,
        'provinsi_keluarga': provinsiController.text,
        'negara_keluarga': negaraController.text,
        'rt_keluarga': rtController.text,
        'rw_keluarga': rwController.text,
        'kode_pos_keluarga': kodePosController.text,
        'id_user': '1', // Gantilah sesuai ID user yang login
        'created_at': createdAt,
        'updated_at': updatedAt,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        fetchKartuKeluarga(); // Refresh list
        Navigator.pop(context); // Close the form
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Data berhasil ditambahkan!',
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.redAccent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gagal menambahkan data!',
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
    } else {
      throw Exception('Failed to add kartu keluarga');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Kartu Keluarga'),
      ),
      body: ListView.builder(
        itemCount: kartuKeluargaList.length,
        itemBuilder: (context, index) {
          final kartuKeluarga = kartuKeluargaList[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text('Nomor KK: ${kartuKeluarga['nomor_keluarga']}'),
              subtitle: Text('Kepala Keluarga: ${kartuKeluarga['nama_warga']}'),
              onTap: () {
                // Navigasi ke Detail Kartu Keluarga
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailKartuKeluargaScreen(
                      kartuKeluarga: kartuKeluarga,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: nomorKeluargaController,
                        decoration: InputDecoration(labelText: 'Nomor Kartu Keluarga'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor Kartu Keluarga harus diisi';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedKepalaKeluarga,
                        items: kepalaKeluargaList.map((kepalaKeluarga) {
                          return DropdownMenuItem(
                            value: kepalaKeluarga['id_warga'].toString(),
                            child: Text(
                                '${kepalaKeluarga['nama_warga']} (${kepalaKeluarga['nik_warga']})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedKepalaKeluarga = value;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Kepala Keluarga'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih Kepala Keluarga';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: alamatController,
                        decoration: InputDecoration(labelText: 'Alamat'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Alamat harus diisi';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: desaController,
                        decoration: InputDecoration(labelText: 'Desa/Kelurahan'),
                      ),
                      TextFormField(
                        controller: kecamatanController,
                        decoration: InputDecoration(labelText: 'Kecamatan'),
                      ),
                      TextFormField(
                        controller: kabupatenController,
                        decoration: InputDecoration(labelText: 'Kabupaten/Kota'),
                      ),
                      TextFormField(
                        controller: provinsiController,
                        decoration: InputDecoration(labelText: 'Provinsi'),
                      ),
                      TextFormField(
                        controller: negaraController,
                        decoration: InputDecoration(labelText: 'Negara'),
                      ),
                      TextFormField(
                        controller: rtController,
                        decoration: InputDecoration(labelText: 'RT'),
                      ),
                      TextFormField(
                        controller: rwController,
                        decoration: InputDecoration(labelText: 'RW'),
                      ),
                      TextFormField(
                        controller: kodePosController,
                        decoration: InputDecoration(labelText: 'Kode Pos'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Cek jika validasi berhasil
                          addKartuKeluarga();
                        },
                        child: Text('Simpan'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailKartuKeluargaScreen extends StatelessWidget {
  final Map kartuKeluarga;

  DetailKartuKeluargaScreen({required this.kartuKeluarga});

  // Fungsi untuk mengambil data anggota kartu keluarga
  Future<List<Map<String, dynamic>>> fetchAnggotaKartuKeluarga(int idKeluarga) async {
    final response = await http.get(Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/kartukeluarga/jumlah_keluarga.php?id_keluarga=$idKeluarga'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } catch (e) {
        throw Exception('Format JSON tidak valid: $e');
      }
    } else {
      throw Exception('Failed to load anggota kartu keluarga');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kartu Keluarga'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // A. Data Pribadi
            Text(
              'A. Data Pribadi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Nomor Kartu Keluarga: ${kartuKeluarga['nomor_keluarga']}'),
            Text('Kepala Keluarga: ${kartuKeluarga['nama_warga']}'),
            Text('NIK Kepala Keluarga: ${kartuKeluarga['nik_warga']}'),
            SizedBox(height: 20),

            // B. Data Alamat
            Text(
              'B. Data Alamat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Alamat: ${kartuKeluarga['alamat_keluarga']}'),
            Text('RT: ${kartuKeluarga['rt_keluarga']}'),
            Text('RW: ${kartuKeluarga['rw_keluarga']}'),
            Text('Desa/Kelurahan: ${kartuKeluarga['desa_kelurahan_keluarga']}'),
            Text('Kecamatan: ${kartuKeluarga['kecamatan_keluarga']}'),
            Text('Kabupaten/Kota: ${kartuKeluarga['kabupaten_kota_keluarga']}'),
            Text('Provinsi: ${kartuKeluarga['provinsi_keluarga']}'),
            Text('Negara: ${kartuKeluarga['negara_keluarga']}'),
            Text('Kode Pos: ${kartuKeluarga['kode_pos_keluarga']}'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}