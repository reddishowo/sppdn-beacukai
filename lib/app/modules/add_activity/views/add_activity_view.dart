// lib/app/modules/add_activity/views/add_activity_view.dart

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
        title: Text('Tambah Kegiatan - Lt. ${controller.floor}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildReadOnlyTextField(
                context,
                label: 'Nama Petugas',
                icon: Icons.person,
                value: controller.officerName,
              ),
              const SizedBox(height: 16),
              _buildRoomDropdown(context),
              const SizedBox(height: 16),
              // --- NEW KETERANGAN FIELD ADDED HERE ---
              _buildKeteranganField(context),
              const SizedBox(height: 24),
              _buildPhotoPicker(context),
              const SizedBox(height: 16),
              _buildReadOnlyTextField(
                context,
                label: 'Tanggal Kegiatan',
                icon: Icons.calendar_today,
                value: controller.formattedDate,
              ),
              const SizedBox(height: 16),
              _buildReadOnlyTextField(
                context,
                label: 'Waktu Kegiatan',
                icon: Icons.access_time_filled,
                value: controller.formattedTime,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildActionButtons(context),
    );
  }

  // --- WIDGET FOR THE NEW KETERANGAN FIELD ---
  Widget _buildKeteranganField(BuildContext context) {
    return TextFormField(
      controller: controller.keteranganController,
      decoration: InputDecoration(
        labelText: 'Keterangan',
        hintText: 'e.g., Pengecekan rutin kondisi AC',
        prefixIcon: Icon(Icons.notes_rounded, color: Theme.of(context).hintColor),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: 3,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Keterangan wajib diisi'; // Validation message
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyTextField(BuildContext context,
      {required String label, required IconData icon, required String value}) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).hintColor),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRoomDropdown(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedRoom.value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Ruangan',
            prefixIcon:
                Icon(Icons.meeting_room, color: Theme.of(context).hintColor),
            hintText: 'Pilih ruangan',
          ),
          items: controller.roomList.map((String room) {
            return DropdownMenuItem<String>(value: room, child: Text(room));
          }).toList(),
          onChanged: (value) {
            controller.selectedRoom.value = value;
          },
          validator: (value) => value == null ? 'Pilih ruangan terlebih dahulu' : null,
        ));
  }

  Widget _buildPhotoPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto Kegiatan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: controller.pickImage,
            child: Obx(() {
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: controller.imageFile.value == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 50, color: Theme.of(context).hintColor),
                          const SizedBox(height: 8),
                          Text('Ketuk untuk mengambil foto',
                              style: TextStyle(color: Theme.of(context).hintColor)),
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

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.cancel,
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveActivity,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          )),
    );
  }
}