import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {}; // Untuk menyimpan data pengguna

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Memanggil fungsi untuk mengambil data profil
  }

  // Mengambil data profil pengguna dari server
  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse(
          'http://teknologi22.xyz/project_api/api_dzaky_v2/home/user_profile.php?id_user=1'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // Parsing JSON

        if (data is Map<String, dynamic> && data.isNotEmpty) {
          setState(() {
            userData = data;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Pengguna tidak ditemukan atau data kosong')));
        }
      } else {
        throw Exception('Gagal memuat data profil');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  // Fungsi untuk logout dengan pop-up konfirmasi
  void _logout() async {
    // Menampilkan pop-up konfirmasi dengan tampilan modern
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3), // Shadow position
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Ikon dan pesan
                Icon(
                  Icons.exit_to_app,
                  size: 40,
                  color: Colors.redAccent,
                ),
                SizedBox(height: 20),
                Text(
                  'Apakah Anda yakin ingin keluar?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // Tombol "Ya" dan "Tidak"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol "Tidak"
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Menutup dialog
                      },
                      child: Text(
                        'Tidak',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Tombol "Ya"
                    ElevatedButton(
                      onPressed: () async {
                        // Menghapus status login di SharedPreferences
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('is_logged_in', false); // Set status login ke false

                        // Navigasi ke halaman login dan hapus rute sebelumnya
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false, // Menghapus semua rute sebelumnya
                        );
                      },
                      child: Text(
                        'Ya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange, // Menggunakan warna lain selain redAccent
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Pengguna'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: userData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Logo Profil
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://icon-icons.com/icons2/2506/PNG/512/user_icon_150670.png'), // URL gambar profil
                onBackgroundImageError: (error, stackTrace) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Gagal memuat logo profil')));
                },
              ),
            ),
            SizedBox(height: 20),
            // Username
            Card(
              margin: EdgeInsets.only(bottom: 10),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.teal[50],
              child: ListTile(
                title: Text(
                  'Username',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  '${userData['username_user']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[700],
                  ),
                ),
              ),
            ),
            // Nama
            Card(
              margin: EdgeInsets.only(bottom: 10),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.teal[50],
              child: ListTile(
                title: Text(
                  'Nama',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  '${userData['nama_user']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[700],
                  ),
                ),
              ),
            ),
            // Keterangan
            Card(
              margin: EdgeInsets.only(bottom: 10),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.teal[50],
              child: ListTile(
                title: Text(
                  'Keterangan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  '${userData['keterangan_user']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[700],
                  ),
                ),
              ),
            ),
            // Alamat
            Card(
              margin: EdgeInsets.only(bottom: 10),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.teal[50],
              child: ListTile(
                title: Text(
                  'Alamat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  '${userData['desa_kelurahan_user']}, ${userData['kecamatan_user']}, ${userData['kabupaten_kota_user']}, ${userData['provinsi_user']}, ${userData['negara_user']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[700],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
