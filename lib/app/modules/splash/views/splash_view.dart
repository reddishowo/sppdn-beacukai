import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Tampilan widget ini harus identik dengan splash screen native
    // yang dikonfigurasi di pubspec.yaml untuk transisi yang mulus.
    // AuthController yang akan mengurus navigasi dari layar ini.

    return Scaffold(
      // Gunakan warna yang sama persis dengan yang ada di pubspec.yaml
      backgroundColor: Colors.white, 
      body: Center(
        // Gunakan ClipRRect untuk membuat sudut yang tumpul (rounded corners)
        child: ClipRRect(
          // Atur radius lengkungan sudut di sini.
          // Semakin besar nilainya, semakin bulat sudutnya.
          borderRadius: BorderRadius.circular(24.0), 
          child: SizedBox(
            width: 200, // Atur lebar logo sesuai kebutuhan
            height: 200, // Atur tinggi logo sesuai kebutuhan
            child: Image.asset(
              'assets/logo.png', // Path ke logo Anda
              fit: BoxFit.cover, // 'cover' memastikan gambar mengisi SizedBox
            ),
          ),
        ),
      ),
    );
  }
}