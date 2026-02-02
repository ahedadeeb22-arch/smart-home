import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/database/database_helper.dart';
import '../core/services/storage_service.dart';
import '../core/services/auth_service.dart';
import '../models/device_model.dart';
import '../models/activity_log_model.dart';

/// متحكم الأجهزة - GetX Controller
class DeviceController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _auth = Get.find<AuthService>();

  // حقول إضافة/تعديل جهاز
  final nameController = TextEditingController();
  final nameArController = TextEditingController();
  final RxString selectedType = 'light'.obs;
  final RxInt selectedRoomId = 0.obs;
  final RxInt deviceValue = 50.obs;
  final RxBool deviceStatus = false.obs;

  // حالة التحميل
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    nameArController.dispose();
    super.onClose();
  }

  /// إضافة جهاز جديد
  Future<bool> addDevice(int roomId) async {
    if (nameController.text.isEmpty) {
      _showErrorSnackbar(_storage.isArabic ? 'يرجى إدخال اسم الجهاز' : 'Please enter device name');
      return false;
    }

    isLoading.value = true;

    try {
      final device = DeviceModel(
        name: nameController.text.trim(),
        nameAr: nameArController.text.trim().isNotEmpty ? nameArController.text.trim() : null,
        type: selectedType.value,
        status: deviceStatus.value ? 1 : 0,
        value: deviceValue.value,
        roomId: roomId,
        createdAt: DateTime.now(),
      );

      await _db.insertDevice(device);

      _showSuccessSnackbar(_storage.isArabic ? 'تم إضافة الجهاز بنجاح' : 'Device added successfully');
      clearFields();
      return true;
    } catch (e) {
      _showErrorSnackbar('Error adding device');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تعديل جهاز
  Future<bool> updateDevice(DeviceModel device) async {
    if (nameController.text.isEmpty) {
      _showErrorSnackbar(_storage.isArabic ? 'يرجى إدخال اسم الجهاز' : 'Please enter device name');
      return false;
    }

    isLoading.value = true;

    try {
      final updatedDevice = device.copyWith(
        name: nameController.text.trim(),
        nameAr: nameArController.text.trim().isNotEmpty ? nameArController.text.trim() : null,
        type: selectedType.value,
        status: deviceStatus.value ? 1 : 0,
        value: deviceValue.value,
      );

      await _db.updateDevice(updatedDevice);

      _showSuccessSnackbar(_storage.isArabic ? 'تم تعديل الجهاز بنجاح' : 'Device updated successfully');
      return true;
    } catch (e) {
      _showErrorSnackbar('Error updating device');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// حذف جهاز
  Future<bool> deleteDevice(int deviceId) async {
    try {
      await _db.deleteDevice(deviceId);

      _showSuccessSnackbar(_storage.isArabic ? 'تم حذف الجهاز بنجاح' : 'Device deleted successfully');
      return true;
    } catch (e) {
      _showErrorSnackbar('Error deleting device');
      return false;
    }
  }

  /// تبديل حالة جهاز
  Future<void> toggleDevice(DeviceModel device, {Function(DeviceModel)? onUpdate}) async {
    try {
      final newStatus = device.isOn ? 0 : 1;
      await _db.updateDeviceStatus(device.id!, newStatus);

      final updatedDevice = device.copyWith(status: newStatus);

      // إضافة سجل النشاط
      final log = newStatus == 1
          ? ActivityLogModel.turnOn(
              userId: _auth.currentUserId!,
              userName: _auth.currentUsername!,
              deviceId: device.id!,
              deviceName: device.name,
              deviceNameAr: device.nameAr,
            )
          : ActivityLogModel.turnOff(
              userId: _auth.currentUserId!,
              userName: _auth.currentUsername!,
              deviceId: device.id!,
              deviceName: device.name,
              deviceNameAr: device.nameAr,
            );

      await _db.insertActivityLog(log);

      // استدعاء callback إذا موجود
      onUpdate?.call(updatedDevice);

      // عرض رسالة نجاح
      final isArabic = _storage.isArabic;
      final deviceName = device.getLocalizedName(isArabic);
      final action = newStatus == 1
          ? (isArabic ? 'تم تشغيل' : 'Turned on')
          : (isArabic ? 'تم إيقاف' : 'Turned off');

      Get.snackbar(
        isArabic ? 'تم' : 'Done',
        '$action $deviceName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: (newStatus == 1 ? Colors.green : Colors.orange).withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(
          newStatus == 1 ? Icons.power : Icons.power_off,
          color: Colors.white,
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Error toggling device');
    }
  }

  /// تحديث قيمة جهاز
  Future<void> updateDeviceValue(DeviceModel device, int newValue, {Function(DeviceModel)? onUpdate}) async {
    try {
      await _db.updateDeviceValue(device.id!, newValue);

      final updatedDevice = device.copyWith(value: newValue);

      // استدعاء callback إذا موجود
      onUpdate?.call(updatedDevice);
    } catch (e) {
      _showErrorSnackbar('Error updating device value');
    }
  }

  /// تحضير الحقول للتعديل
  void prepareForEdit(DeviceModel device) {
    nameController.text = device.name;
    nameArController.text = device.nameAr ?? '';
    selectedType.value = device.type;
    deviceValue.value = device.value;
    deviceStatus.value = device.isOn;
  }

  /// مسح الحقول
  void clearFields() {
    nameController.clear();
    nameArController.clear();
    selectedType.value = 'light';
    deviceValue.value = 50;
    deviceStatus.value = false;
    selectedRoomId.value = 0;
  }

  /// تغيير نوع الجهاز
  void setDeviceType(String type) {
    selectedType.value = type;
    // تعيين قيمة افتراضية حسب النوع
    switch (type) {
      case 'light':
        deviceValue.value = 50;
        break;
      case 'ac':
        deviceValue.value = 24;
        break;
      case 'fan':
        deviceValue.value = 3;
        break;
      case 'tv':
        deviceValue.value = 50;
        break;
      default:
        deviceValue.value = 0;
    }
  }

  /// التحقق من كون المستخدم أدمن
  bool get isAdmin => _auth.isAdmin;

  /// التحقق من اللغة العربية
  bool get isArabic => _storage.isArabic;

  /// عرض رسالة نجاح
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      _storage.isArabic ? 'نجاح' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// عرض رسالة خطأ
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      _storage.isArabic ? 'خطأ' : 'Error',
      _storage.isArabic ? 'حدث خطأ' : message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
}