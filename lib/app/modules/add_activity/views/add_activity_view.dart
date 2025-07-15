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
        title: Text('Add Activity - Floor ${controller.floor}'),
      ),
      // The background color is now inherited from the global theme
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildReadOnlyTextField(
                context,
                label: 'Officer Name',
                icon: Icons.person,
                value: controller.officerName,
              ),
              const SizedBox(height: 16),
              _buildRoomDropdown(context),
              const SizedBox(height: 16),
              _buildPhotoPicker(context),
              const SizedBox(height: 16),
              _buildReadOnlyTextField(
                context,
                label: 'Activity Date',
                icon: Icons.calendar_today,
                value: controller.formattedDate,
              ),
              const SizedBox(height: 16),
              _buildReadOnlyTextField(
                context,
                label: 'Activity Time',
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

  Widget _buildReadOnlyTextField(BuildContext context, {required String label, required IconData icon, required String value}) {
    // This now uses theme colors for a disabled/read-only state
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).hintColor),
        filled: true,
        // Using a subtle theme color for the background
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRoomDropdown(BuildContext context) {
    // The InputDecoration now fully relies on the global theme
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedRoom.value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Room',
        prefixIcon: Icon(Icons.meeting_room, color: Theme.of(context).hintColor),
        hintText: 'Select a room',
      ),
      items: controller.roomList.map((String room) {
        return DropdownMenuItem<String>(value: room, child: Text(room));
      }).toList(),
      onChanged: (value) {
        controller.selectedRoom.value = value;
      },
      validator: (value) => value == null ? 'Please select a room first' : null,
    ));
  }

  Widget _buildPhotoPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity Photo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: controller.pickImage,
            child: Obx(() {
              // The container now uses theme colors for its placeholder state
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: controller.imageFile.value == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 50, color: Theme.of(context).hintColor),
                          const SizedBox(height: 8),
                          Text('Tap to take a photo', style: TextStyle(color: Theme.of(context).hintColor)),
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
    // The buttons now get their entire style from the global theme
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.isLoading.value ? null : controller.cancel,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.saveActivity,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      // The indicator color is now inherited from the button's theme
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      )),
    );
  }
}