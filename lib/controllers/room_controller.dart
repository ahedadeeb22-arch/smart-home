import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/database/database_helper.dart';
import '../core/services/storage_service.dart';
import '../core/services/auth_service.dart';
import '../models/room_model.dart';
import '../models/device_model.dart';
import '../models/activity_log_model.dart';

/// متحكم الغرف - GetX Controller
class RoomController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _auth = Get.find<AuthService>();

  // الغرفة الحالية
  final Rx<RoomModel?> currentRoom = Rx<RoomModel?>(null);

  // أجهزة الغرفة
  final RxList<DeviceModel> devices = <DeviceModel>[].obs;

  // حالة التحميل
  final RxBool isLoading = false.obs;

  // حقول إضافة/تعديل غرفة
  final nameController = TextEditingController();
  final nameArController = TextEditingController();
  final RxString selectedIcon = 'home'.obs;
  final RxString selectedColor = '#00F5FF'.obs;

  @override
  void onClose() {
    nameController.dispose();
    nameArController.dispose();
    isLoading.value = false;
    super.onClose();
  }

  /// تحميل بيانات غرفة معينة
  Future<void> loadRoom(int roomId) async {
    isLoading.value = true;

    try {
      // تحميل الغرفة
      final room = await _db.getRoomById(roomId);
      currentRoom.value = room;

      // تحميل أجهزة الغرفة
      if (room != null) {
        final devicesList = await _db.getDevicesByRoom(roomId);
        devices.assignAll(devicesList);
      }
    } catch (e) {
      _showErrorSnackbar('Error loading room');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث البيانات
  Future<void> refreshRoom() async {
    if (currentRoom.value != null) {
      await loadRoom(currentRoom.value!.id!);
    }
  }
 /// الدالة المصححة لإضافة غرفة
  Future<bool> addRoom() async {
    // التحقق من إدخال البيانات الأساسية
    if (nameController.text.isEmpty || nameArController.text.isEmpty) {
      Get.snackbar(
        'تنبيه', 
        'يرجى إدخال اسم الغرفة بالعربية والإنجليزية',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading.value = true; // بدء التحميل

      final newRoom = RoomModel(
        name: nameController.text.trim(),
        nameAr: nameArController.text.trim(),
        icon: selectedIcon.value,
        color: selectedColor.value,
        createdAt: DateTime.now(),
      );

      // تنفيذ عملية الحفظ في قاعدة البيانات
      final id = await _db.insertRoom(newRoom);
      
      if (id > 0) {
        return true; // نجاح العملية
      } else {
        throw Exception('Failed to insert room');
      }
    } catch (e) {
      // التعامل مع الخطأ
      Get.snackbar(
        'خطأ', 
        'فشل حفظ الغرفة: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      // الحل السحري هنا:
      // هذا الجزء ينفذ دائماً سواء نجح الـ try أو حدث خطأ في الـ catch
      isLoading.value = false; // إيقاف التحميل مهما كانت النتيجة
    }
  }



  

  /// دالة تحديث بيانات الغرفة
  Future<bool> updateRoom(RoomModel oldRoom) async {
    if (nameController.text.isEmpty || nameArController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى ملء كافة الحقول');
      return false;
    }

    try {
      isLoading.value = true;
      
      // إنشاء كائن الغرفة المحدث بنفس الـ ID القديم
      final updatedRoom = RoomModel(
        id: oldRoom.id, 
        name: nameController.text.trim(),
        nameAr: nameArController.text.trim(),
        icon: selectedIcon.value,
        color: selectedColor.value,
        createdAt: oldRoom.createdAt,
      );

      final result = await _db.updateRoom(updatedRoom);
      return result > 0;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل التعديل: $e');
      return false;
    } finally {
      // التأكد من إيقاف وضع التحميل دائماً
      isLoading.value = false;
    }
  }



  /// حذف غرفة
  Future<bool> deleteRoom(int roomId) async {
    try {
      await _db.deleteRoom(roomId);

      _showSuccessSnackbar(_storage.isArabic ? 'تم حذف الغرفة بنجاح' : 'Room deleted successfully');
      return true;
    } catch (e) {
      _showErrorSnackbar('Error deleting room');
      return false;
    }
  }

  /// تبديل حالة جهاز
  Future<void> toggleDevice(DeviceModel device) async {
    try {
      final newStatus = device.isOn ? 0 : 1;
      await _db.updateDeviceStatus(device.id!, newStatus);

      // تحديث الجهاز في القائمة
      final index = devices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        devices[index] = device.copyWith(status: newStatus);
        devices.refresh();
      }

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
        duration: const Duration(seconds: 1),
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
  Future<void> updateDeviceValue(DeviceModel device, int newValue) async {
    try {
      await _db.updateDeviceValue(device.id!, newValue);

      // تحديث الجهاز في القائمة
      final index = devices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        devices[index] = device.copyWith(value: newValue);
        devices.refresh();
      }

      // إضافة سجل النشاط
      final log = ActivityLogModel.changeValue(
        userId: _auth.currentUserId!,
        userName: _auth.currentUsername!,
        deviceId: device.id!,
        deviceName: device.name,
        newValue: newValue,
        valueType: device.type == 'light' ? 'brightness' : 'value',
        deviceNameAr: device.nameAr,
        valueTypeAr: device.type == 'light' ? 'السطوع' : 'القيمة',
      );

      await _db.insertActivityLog(log);
    } catch (e) {
      _showErrorSnackbar('Error updating device value');
    }
  }

  /// تحضير الحقول للتعديل
  void prepareForEdit(RoomModel room) {
    nameController.text = room.name;
    nameArController.text = room.nameAr ?? '';
    selectedIcon.value = room.icon;
    selectedColor.value = room.color;
    isLoading.value = false;
  }

  /// مسح الحقول
  void clearFields() {
    nameController.clear();
    nameArController.clear();
    selectedIcon.value = 'home';
    selectedColor.value = '#00F5FF';
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
