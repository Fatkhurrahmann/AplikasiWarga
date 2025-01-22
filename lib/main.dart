import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'welcomescreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pendataan Warga',
      initialRoute: '/welcome',
      onGenerateRoute: (settings) {
        return _animatedPageRoute(settings);
      },
    );
  }

  // Fungsi untuk menambahkan animasi pada rute
  Route _animatedPageRoute(RouteSettings settings) {
    late Widget page;

    // Pilih halaman berdasarkan nama rute
    switch (settings.name) {
      case '/welcome':
        page = WelcomeScreen();
        break;
      case '/login':
        page = LoginScreen();
        break;
      case '/home':
        page = HomeScreen();
        break;
      default:
        page = WelcomeScreen();
    }

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animasi slide dari kanan ke kiri
        const begin = Offset(1.0, 0.0); // Mulai dari sisi kanan layar
        const end = Offset.zero; // Berakhir di posisi layar utama
        const curve = Curves.easeInOut; // Kurva transisi

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}