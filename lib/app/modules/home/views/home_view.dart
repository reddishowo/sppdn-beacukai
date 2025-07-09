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
      
      // PERUBAHAN: FAB dengan Gradient
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: controller.onAddButtonPressed,
          backgroundColor: Colors.transparent, // Warna dibuat transparan karena sudah di-handle oleh Container
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0, // Jarak lebih besar agar lebih estetik
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 20.0, // Bayangan lebih dramatis
        shadowColor: Colors.black.withOpacity(0.1),
        height: 75,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(
                icon: Icons.dashboard_rounded, // Ganti ikon agar lebih modern
                label: 'Beranda',
                index: 0,
              ),
              const Spacer(flex: 2), // Beri ruang lebih besar untuk FAB
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PERUBAHAN: Widget item navigasi yang lebih cantik
   Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = controller.tabIndex.value == index;
    
    return Expanded(
      flex: 3, // Beri bobot agar tombol lebih lebar
      child: InkWell(
        onTap: () => controller.changeTabIndex(index),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Beritahu Column agar tidak "rakus" ruang
          children: <Widget>[
            Icon(
              icon,
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade500,
              size: 26, // Ikon sedikit lebih besar
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                fontSize: 11, // Ukuran font sedikit lebih kecil agar rapi
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}