import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DataMutasiScreen extends StatefulWidget {
  @override
  _DataMutasiScreenState createState() => _DataMutasiScreenState();
}

class _DataMutasiScreenState extends State<DataMutasiScreen> {
  List<dynamic> mutasiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMutasiData();
  }

  Future<void> fetchMutasiData() async {
    try {
      final response = await http.get(Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/mutasi/mutasi.php'));
      if (response.statusCode == 200) {
        setState(() {
          mutasiList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> deleteMutasi(int id) async {
    try {
      final response = await http.post(
        Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/mutasi/delete_mutasi.php'),
        body: {'id_mutasi': id.toString()},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          setState(() {
            mutasiList.removeWhere((item) => item['id_mutasi'] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data berhasil dihapus')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus data')),
          );
        }
      } else {
        throw Exception('Failed to delete data');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menghapus data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Mutasi')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: mutasiList.length,
        itemBuilder: (context, index) {
          final mutasi = mutasiList[index];
          return ListTile(
            leading: Icon(Icons.person),
            title: Text(mutasi['nama_mutasi'] ?? 'Tidak ada nama'),
            subtitle: Text('NIK: ${mutasi['nik_mutasi'] ?? 'Tidak ada NIK'}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteMutasi(int.parse(mutasi['id_mutasi'] ?? '0')), // Konversi id_mutasi ke int
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailMutasiScreen(
                    idMutasi: int.parse(mutasi['id_mutasi'] ?? '0'), // Konversi id_mutasi ke int
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

class DetailMutasiScreen extends StatelessWidget {
  final int idMutasi;

  const DetailMutasiScreen({Key? key, required this.idMutasi}) : super(key: key);

  Future<Map<String, dynamic>> fetchDetailData() async {
    final response = await http.get(Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/mutasi/detail_mutasi.php?id_mutasi=$idMutasi'));
    if (response.statusCode == 200) {
      try {
        // Try to decode the JSON
        return json.decode(response.body);
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Failed to parse detail data');
      }
    } else {
      throw Exception('Failed to load detail data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Mutasi')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetailData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Data tidak ditemukan'));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A. Data Pribadi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('NIK: ${data['nik_mutasi']}'),
                Text('Nama Mutasi: ${data['nama_mutasi']}'),
                Text('Tempat Lahir: ${data['tempat_lahir_mutasi']}'),
                Text('Tanggal Lahir: ${data['tanggal_lahir_mutasi']}'),
                Text('Jenis Kelamin: ${data['jenis_kelamin_mutasi']}'),
                SizedBox(height: 16),
                Text('B. Data Alamat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Alamat KTP: ${data['alamat_ktp_mutasi']}'),
                Text('Alamat: ${data['alamat_mutasi']}'),
                Text('Desa/Kelurahan: ${data['desa_kelurahan_mutasi']}'),
                Text('Kecamatan: ${data['kecamatan_mutasi']}'),
                Text('Kabupaten/Kota: ${data['kabupaten_kota_mutasi']}'),
                Text('Provinsi: ${data['provinsi_mutasi']}'),
                Text('Negara: ${data['negara_mutasi']}'),
                Text('RT: ${data['rt_mutasi']}'),
                Text('RW: ${data['rw_mutasi']}'),
                SizedBox(height: 16),
                Text('C. Data Lain-lain', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Agama: ${data['agama_mutasi']}'),
                Text('Pendidikan: ${data['pendidikan_terakhir_mutasi']}'),
                Text('Pekerjaan: ${data['pekerjaan_mutasi']}'),
                Text('Status Perkawinan: ${data['status_perkawinan_mutasi']}'),
                Text('Status Tinggal: ${data['status_mutasi']}'),
                SizedBox(height: 16),
                Text('D. Data Aplikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Diinput oleh: ${data['id_user']}'),
                Text('Diinput: ${data['created_at']}'),
                Text('Diperbaharui: ${data['updated_at']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
