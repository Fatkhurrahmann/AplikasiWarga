import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'DataWargaScreen.dart';
import 'DataKartuKeluargaScreen.dart';
import 'DataMutasiScreen.dart';
import 'ProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalWarga = 0;
  int totalLakiLaki = 0;
  int totalPerempuan = 0;
  int totalKK = 0;
  int totalMutasi = 0;

  String namaUser = '';
  String ucapan = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Cek status login pengguna
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      setState(() {
        namaUser = prefs.getString('nama_user') ?? 'Pengguna';
      });
      await _ambilData(); // Ambil data dari server jika sudah login
      _setUcapanWaktu();
    } else {
      // Jika belum login, arahkan ke halaman login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Ambil data dari server
  Future<void> _ambilData() async {
    try {
      final response = await http.get(
        Uri.parse('http://teknologi22.xyz/project_api/api_dzaky_v2/home/get_dashboard_data.php'), // Ganti dengan URL server Anda
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response: $data'); // Log response untuk memastikan data yang diterima

        if (data['status'] == 'success') {
          setState(() {
            totalWarga = data['data']['total_warga'] ?? 0;
            totalLakiLaki = data['data']['total_laki_laki'] ?? 0;
            totalPerempuan = data['data']['total_perempuan'] ?? 0;
            totalKK = data['data']['total_kartu_keluarga'] ?? 0;
            totalMutasi = data['data']['total_mutasi'] ?? 0;
            namaUser = data['data']['nama_user'] ?? 'Pengguna';
          });
          _setUcapanWaktu();
        } else {
          print('Data tidak valid: ${data['message']}');
        }
      } else {
        print('Gagal mendapatkan data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  // Set ucapan berdasarkan waktu
  void _setUcapanWaktu() {
    final hour = DateTime.now().hour;
    String newUcapan = '';
    if (hour < 12) {
      newUcapan = "Selamat Pagi, $namaUser!";
    } else if (hour < 18) {
      newUcapan = "Selamat Siang, $namaUser!";
    } else if (hour < 20) {
      newUcapan = "Selamat Sore, $namaUser!";
    } else {
      newUcapan = "Selamat Malam, $namaUser!";
    }

    setState(() {
      ucapan = newUcapan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(userId: '123')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Row(
                children: [
                  Icon(Icons.account_circle, size: 50, color: Colors.white),
                  SizedBox(width: 16),
                  Text(
                    'Menu Utama',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.people, size: 30, color: Colors.blue),
              title: Text('Data Warga'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataWargaScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home, size: 30, color: Colors.green),
              title: Text('Data Kartu Keluarga'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataKartuKeluargaScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz, size: 30, color: Colors.orange),
              title: Text('Data Mutasi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataMutasiScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ucapan,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DataWargaScreen()),
                      );
                    },
                    child: _buildDashboardCard(
                      title: 'Total Warga',
                      count: totalWarga,
                      subtitle: 'Laki: $totalLakiLaki | Perempuan: $totalPerempuan',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DataKartuKeluargaScreen()),
                      );
                    },
                    child: _buildDashboardCard(
                      title: 'Total Kartu Keluarga',
                      count: totalKK,
                      icon: Icons.home,
                      color: Colors.green,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DataMutasiScreen()),
                      );
                    },
                    child: _buildDashboardCard(
                      title: 'Total Mutasi',
                      count: totalMutasi,
                      icon: Icons.swap_horiz,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required int count,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
