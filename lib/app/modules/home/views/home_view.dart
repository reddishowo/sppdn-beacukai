// File 18: /lib/app/modules/home/views/home_view.dart

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
      
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor.withOpacity(0.8), Theme.of(context).primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: controller.onAddButtonPressed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          // Icon color is inherited from the FAB's theme foregroundColor
          child: const Icon(Icons.add, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        height: 75,
        // Color and shadow now come from BottomAppBarTheme
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(
                context: context,
                icon: Icons.dashboard_rounded,
                label: 'Home',
                index: 0,
              ),
              const Spacer(flex: 2),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

   Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = controller.tabIndex.value == index;
    final Color activeColor = Theme.of(context).primaryColor;
    final Color inactiveColor = Colors.grey.shade500;
    
    return Expanded(
      flex: 3,
      child: InkWell(
        onTap: () => controller.changeTabIndex(index),
        splashColor: activeColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 11,
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