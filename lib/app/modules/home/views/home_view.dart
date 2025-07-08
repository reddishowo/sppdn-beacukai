// File: /sppdn/lib/app/modules/home/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.tabIndex.value,
            children: controller.pages,
          )),
      
      floatingActionButton: FloatingActionButton(
        onPressed: controller.onAddButtonPressed,
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ** PERBAIKI BAGIAN INI **
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: Obx(
          () => BottomNavigationBar(
            // ** 1. TAMBAHKAN TYPE **
            type: BottomNavigationBarType.fixed, // Mencegah item bergeser & membantu layout
            
            currentIndex: controller.tabIndex.value,
            onTap: controller.changeTabIndex,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,

            // ** 2. SESUAIKAN UKURAN FONT **
            selectedFontSize: 12.0, // Sedikit lebih kecil untuk mencegah overflow
            unselectedFontSize: 12.0,

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}