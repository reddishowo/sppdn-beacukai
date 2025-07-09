import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_activity_controller.dart';

class AddActivityView extends GetView<AddActivityController> {
  const AddActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Kegiatan - Lantai ${controller.floor}'),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Field Nama Petugas (Read-only)
              _buildReadOnlyTextField(
                label: 'Nama Petugas',
                icon: Icons.person,
                value: controller.officerName,
              ),
              const SizedBox(height: 16),

              // Dropdown Pilihan Ruangan
              _buildRoomDropdown(),
              const SizedBox(height: 16),
              
              // Tampilan Foto
              _buildPhotoPicker(),
              const SizedBox(height: 16),

              // Info Tanggal/Jam
              _buildInfoField(
                label: 'Tanggal / Jam',
                icon: Icons.calendar_today,
                value: 'Akan dicatat otomatis saat disimpan',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // Tombol Aksi di bagian bawah
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  // Widget untuk field read-only
  Widget _buildReadOnlyTextField({required String label, required IconData icon, required String value}) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget untuk dropdown ruangan
  Widget _buildRoomDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedRoom.value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Ruangan',
        prefixIcon: const Icon(Icons.meeting_room, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      hint: const Text('Pilih ruangan'),
      items: controller.roomList.map((String room) {
        return DropdownMenuItem<String>(value: room, child: Text(room));
      }).toList(),
      onChanged: (value) {
        controller.selectedRoom.value = value;
      },
      validator: (value) => value == null ? 'Pilih ruangan terlebih dahulu' : null,
    ));
  }
  
  // Widget untuk info field
  Widget _buildInfoField({required String label, required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100)
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: TextStyle(color: Colors.blue.shade800)))
        ],
      ),
    );
  }

  // Widget untuk pemilih foto
  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto Kegiatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: controller.pickImage,
            child: Obx(() {
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: controller.imageFile.value == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Ketuk untuk mengambil foto'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(controller.imageFile.value!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
              );
            }),
          ),
        ),
      ],
    );
  }
  
  // Widget untuk tombol aksi
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.isLoading.value ? null : controller.cancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Batal'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.saveActivity,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ),
        ],
      )),
    );
  }
}