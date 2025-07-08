// File: /sppdn/lib/app/modules/home/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai tab yang dipilih
      body: Obx(() => IndexedStack(
            index: controller.tabIndex.value,
            children: controller.pages,
          )),
      
      // Floating Action Button di tengah
      floatingActionButton: FloatingActionButton(
        onPressed: controller.onAddButtonPressed,
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.tabIndex.value,
            onTap: controller.changeTabIndex,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
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