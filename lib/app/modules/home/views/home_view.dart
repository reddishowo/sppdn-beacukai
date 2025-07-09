import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Obx(() => IndexedStack(
            index: controller.tabIndex.value,
            children: controller.pages,
          )),
      
      // 1. Kembalikan FAB ke tengah
      floatingActionButton: FloatingActionButton(
        onPressed: controller.onAddButtonPressed,
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 2.0, // Sedikit bayangan untuk FAB
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 2. Gunakan BottomAppBar lagi untuk membuat 'notch' (lekukan)
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0, // Jarak antara FAB dan BottomAppBar
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 10.0, // Beri bayangan agar terpisah dari konten
        child: Obx(
          () => Row(
            // 3. Susun item navigasi secara manual menggunakan Row
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(
                icon: Icons.home_filled,
                label: 'Beranda',
                index: 0,
              ),
              // Tambahkan Spacer untuk memberikan ruang bagi FAB di tengah
              const Spacer(),
              _buildNavItem(
                icon: Icons.person,
                label: 'Profil',
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Buat helper widget untuk item navigasi agar kode lebih bersih
   Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = controller.tabIndex.value == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTabIndex(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        // ** PERBAIKAN KUNCI DI SINI **
        // Kita HAPUS widget Padding dan membiarkan Column menangani layout.
        child: Column(
          // 1. Ganti `mainAxisSize` menjadi `mainAxisAlignment`.
          //    `MainAxisAlignment.center` akan membuat Column mengisi
          //    seluruh tinggi yang tersedia dan menempatkan isinya di tengah.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            // 2. Kurangi sedikit jarak vertikal agar lebih pas.
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              // Mencegah teks turun ke baris baru jika terlalu panjang
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}