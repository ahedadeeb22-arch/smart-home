import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import '../controllers/device_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';
import '../models/device_model.dart';
import '../widgets/device_tile.dart';
import '../widgets/class_card.dart';

/// شاشة تفاصيل الغرفة
class RoomDetailsScreen extends StatefulWidget {
  const RoomDetailsScreen({super.key});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  late RoomController _roomController;
  late DeviceController _deviceController;
  late int _roomId;

  @override
  void initState() {
    super.initState();
    _roomController = Get.find<RoomController>();
    _deviceController = Get.find<DeviceController>();
    
    // الحصول على معرف الغرفة من المسار
    final params = Get.parameters;
    _roomId = int.parse(params['id'] ?? '0');
    
    // تحميل بيانات الغرفة
    _roomController.loadRoom(_roomId);
  }

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.cyberpunkGradient : null,
          color: isDark ? null : AppColors.lightBackground,
        ),
        child: SafeArea(
          child: Obx(() {
            if (_roomController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryCyan,
                ),
              );
            }

            final room = _roomController.currentRoom.value;
            if (room == null) {
              return Center(
                child: Text(
                  isArabic ? 'الغرفة غير موجودة' : 'Room not found',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _roomController.refreshRoom,
              color: AppColors.primaryCyan,
              child: CustomScrollView(
                slivers: [
                  // الهيدر
                  SliverToBoxAdapter(
                    child: _buildHeader(room, isDark, isArabic),
                  ),

                  // عنوان الأجهزة
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? 'الأجهزة' : 'Devices',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Obx(() => Text(
                                '${_roomController.devices.length} ${isArabic ? 'جهاز' : 'devices'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : Colors.grey,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),

                  // قائمة الأجهزة
                  Obx(() {
                    if (_roomController.devices.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyDevices(isDark, isArabic),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final device = _roomController.devices[index];
                            return DeviceTile(
                              device: device,
                              onToggle: () => _roomController.toggleDevice(device),
                              onValueChanged: (value) => _roomController.updateDeviceValue(device, value),
                              onLongPress: _roomController.isAdmin
                                  ? () => _showDeviceOptions(device, isDark, isArabic)
                                  : null,
                            );
                          },
                          childCount: _roomController.devices.length,
                        ),
                      ),
                    );
                  }),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            );
          }),
        ),
      ),

      // زر إضافة جهاز (للأدمن فقط)
      floatingActionButton: Obx(() => _roomController.isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddDeviceDialog(isDark, isArabic),
              backgroundColor: AppColors.primaryCyan,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildHeader(room, bool isDark, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // شريط العنوان
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                    color: isDark ? Colors.white70 : Colors.black87,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  room.getLocalizedName(isArabic),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (_roomController.isAdmin)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditRoomDialog(room, isDark, isArabic);
                    } else if (value == 'delete') {
                      _showDeleteRoomDialog(room, isDark, isArabic);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 8),
                          Text(isArabic ? 'تعديل' : 'Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            isArabic ? 'حذف' : 'Delete',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 24),

          // بطاقة معلومات الغرفة
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderColor: room.colorValue.withOpacity(0.5),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: room.colorValue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    room.iconData,
                    color: room.colorValue,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.getLocalizedName(isArabic),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final activeCount = _roomController.devices.where((d) => d.isOn).length;
                        final totalCount = _roomController.devices.length;
                        return Row(
                          children: [
                            _buildInfoChip(
                              icon: Icons.devices,
                              label: '$totalCount ${isArabic ? 'جهاز' : 'devices'}',
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            if (activeCount > 0)
                              _buildInfoChip(
                                icon: Icons.power,
                                label: '$activeCount ${isArabic ? 'نشط' : 'active'}',
                                color: AppColors.success,
                                isDark: isDark,
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
    required bool isDark,
  }) {
    final chipColor = color ?? (isDark ? Colors.white60 : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDevices(bool isDark, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.devices_other,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا توجد أجهزة في هذه الغرفة' : 'No devices in this room',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
          if (_roomController.isAdmin) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _showAddDeviceDialog(isDark, isArabic),
              icon: const Icon(Icons.add),
              label: Text(isArabic ? 'إضافة جهاز' : 'Add Device'),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddDeviceDialog(bool isDark, bool isArabic) {
    _deviceController.clearFields();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(isArabic ? 'إضافة جهاز جديد' : 'Add New Device'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _deviceController.nameController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم الجهاز (إنجليزي)' : 'Device Name (English)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deviceController.nameArController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم الجهاز (عربي)' : 'Device Name (Arabic)',
                ),
              ),
              const SizedBox(height: 16),
              _buildDeviceTypeSelector(isDark, isArabic),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: _deviceController.isLoading.value
                    ? null
                    : () async {
                        final success = await _deviceController.addDevice(_roomId);
                        if (success) {
                          Get.back();
                          _roomController.refreshRoom();
                        }
                      },
                child: _deviceController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isArabic ? 'إضافة' : 'Add'),
              )),
        ],
      ),
    );
  }

  Widget _buildDeviceTypeSelector(bool isDark, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'نوع الجهاز' : 'Device Type',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DeviceTypes.types.map((type) {
                final isSelected = _deviceController.selectedType.value == type['type'];
                return GestureDetector(
                  onTap: () => _deviceController.setDeviceType(type['type']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryCyan.withOpacity(0.2)
                          : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryCyan : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type['icon'] as IconData,
                          size: 18,
                          color: isSelected ? AppColors.primaryCyan : (isDark ? Colors.white60 : Colors.grey),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isArabic ? type['label'] : type['labelEn'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? AppColors.primaryCyan : (isDark ? Colors.white60 : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  void _showDeviceOptions(DeviceModel device, bool isDark, bool isArabic) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              device.getLocalizedName(isArabic),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(isArabic ? 'تعديل الجهاز' : 'Edit Device'),
              onTap: () {
                Get.back();
                _showEditDeviceDialog(device, isDark, isArabic);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                isArabic ? 'حذف الجهاز' : 'Delete Device',
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Get.back();
                _showDeleteDeviceDialog(device, isDark, isArabic);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDeviceDialog(DeviceModel device, bool isDark, bool isArabic) {
    _deviceController.prepareForEdit(device);
    
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(isArabic ? 'تعديل الجهاز' : 'Edit Device'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _deviceController.nameController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم الجهاز (إنجليزي)' : 'Device Name (English)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deviceController.nameArController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم الجهاز (عربي)' : 'Device Name (Arabic)',
                ),
              ),
              const SizedBox(height: 16),
              _buildDeviceTypeSelector(isDark, isArabic),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: _deviceController.isLoading.value
                    ? null
                    : () async {
                        final success = await _deviceController.updateDevice(device);
                        if (success) {
                          Get.back();
                          _roomController.refreshRoom();
                        }
                      },
                child: _deviceController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isArabic ? 'حفظ' : 'Save'),
              )),
        ],
      ),
    );
  }

  void _showDeleteDeviceDialog(DeviceModel device, bool isDark, bool isArabic) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(isArabic ? 'حذف الجهاز' : 'Delete Device'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف "${device.getLocalizedName(true)}"؟'
              : 'Are you sure you want to delete "${device.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _deviceController.deleteDevice(device.id!);
              if (success) {
                Get.back();
                _roomController.refreshRoom();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              isArabic ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditRoomDialog(room, bool isDark, bool isArabic) {
    _roomController.prepareForEdit(room);
    
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(isArabic ? 'تعديل الغرفة' : 'Edit Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _roomController.nameController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم الغرفة (إنجليزي)' : 'Room Name (English)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roomController.nameArController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم الغرفة (عربي)' : 'Room Name (Arabic)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _roomController.updateRoom(room);
              if (success) {
                Get.back();
              }
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRoomDialog(room, bool isDark, bool isArabic) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(isArabic ? 'حذف الغرفة' : 'Delete Room'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من حذف "${room.getLocalizedName(true)}"؟ سيتم حذف جميع الأجهزة فيها.'
              : 'Are you sure you want to delete "${room.name}"? All devices in it will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _roomController.deleteRoom(room.id!);
              if (success) {
                Get.back();
                Get.back(); // العودة للشاشة الرئيسية
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              isArabic ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}