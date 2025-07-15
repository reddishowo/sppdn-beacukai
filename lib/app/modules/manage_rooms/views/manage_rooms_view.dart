import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_rooms_controller.dart';

class ManageRoomsView extends GetView<ManageRoomsController> {
  const ManageRoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController tetap di sini
    return DefaultTabController(
      length: 2,
      // **PERUBAHAN: Bungkus Scaffold dengan Builder**
      child: Builder(builder: (BuildContext builderContext) { // 'builderContext' adalah context yang baru & benar
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kelola Ruangan'),
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.looks_one), text: 'Lantai 1'),
                Tab(icon: Icon(Icons.looks_two), text: 'Lantai 2'),
              ],
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _buildRoomList(1, controller.floor1Rooms),
                _buildRoomList(2, controller.floor2Rooms),
              ],
            );
          }),
          floatingActionButton: FloatingActionButton(
            // **PERUBAHAN: Gunakan 'builderContext' dari Builder**
            onPressed: () => _showAddRoomDialog(builderContext),
            tooltip: 'Tambah Ruangan',
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }

  // **PERUBAHAN: Parameter context sekarang menerima context yang benar**
  Widget _buildRoomList(int floor, List<String> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Text(
          'Belum ada ruangan di lantai ini.\nTekan tombol + untuk menambah.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final roomName = rooms[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(roomName),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
            // **PERUBAHAN: Berikan context dari list item**
            onPressed: () => _showDeleteConfirmation(context, floor, roomName),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int floor, String roomName) {
    // ... (Fungsi ini tidak perlu diubah, karena Get.dialog tidak bergantung pada context itu)
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Hapus Ruangan'),
      content: Text('Anda yakin ingin menghapus ruangan "$roomName"? Tindakan ini tidak dapat dibatalkan.'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Get.back();
            controller.deleteRoom(floor, roomName);
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _showAddRoomDialog(BuildContext context) {
    final newRoomController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    // Dapatkan TabController dari context untuk mengetahui lantai yang aktif
    // **SEKARANG INI AKAN BERFUNGSI DENGAN BAIK**
    final tabController = DefaultTabController.of(context);

    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Tambah Ruangan di Lantai ${tabController.index + 1}'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: newRoomController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama Ruangan',
            hintText: 'e.g. Ruang Rapat Baru',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final int currentFloor = tabController.index + 1;
              controller.addRoom(currentFloor, newRoomController.text);
            }
          },
          child: const Text('Tambah'),
        ),
      ],
    ));
  }
}