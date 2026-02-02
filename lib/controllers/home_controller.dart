
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/database/database_helper.dart';
import '../core/services/storage_service.dart';
import '../core/services/auth_service.dart';
import '../models/room_model.dart';
import '../models/device_model.dart';
import '../models/activity_log_model.dart';

/// متحكم الشاشة الرئيسية - GetX Controller
class HomeController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _auth = Get.find<AuthService>();

  // قوائم البيانات
  final RxList<RoomModel> rooms = <RoomModel>[].obs;
  final RxList<DeviceModel> allDevices = <DeviceModel>[].obs;
  final RxList<ActivityLogModel> recentLogs = <ActivityLogModel>[].obs;

  // إحصائيات
  final RxInt totalRooms = 0.obs;
  final RxInt totalDevices = 0.obs;
  final RxInt activeDevices = 0.obs;

  // حالة التحميل
  final RxBool isLoading = true.obs;

  // فهرس التنقل السفلي
  final RxInt currentNavIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// تحميل جميع البيانات
  Future<void> loadData() async {
    isLoading.value = true;

    try {
      // تحميل الغرف
      final roomsList = await _db.getAllRooms();
      rooms.assignAll(roomsList);
      totalRooms.value = roomsList.length;

      // تحميل الأجهزة
      final devicesList = await _db.getAllDevices();
      allDevices.assignAll(devicesList);
      totalDevices.value = devicesList.length;
      activeDevices.value = devicesList.where((d) => d.isOn).length;

      // تحميل آخر السجلات
      final logsList = await _db.getRecentActivityLogs(10);
      recentLogs.assignAll(logsList);
    } catch (e) {
      _showErrorSnackbar('Error loading data');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث البيانات
  Future<void> refreshData() async {
    await loadData();
  }

  /// الحصول على أجهزة غرفة معينة
  List<DeviceModel> getDevicesForRoom(int roomId) {
    return allDevices.where((d) => d.roomId == roomId).toList();
  }

  /// الحصول على عدد الأجهزة في غرفة
  int getDeviceCountForRoom(int roomId) {
    return allDevices.where((d) => d.roomId == roomId).length;
  }

  /// الحصول على عدد الأجهزة النشطة في غرفة
  int getActiveDeviceCountForRoom(int roomId) {
    return allDevices.where((d) => d.roomId == roomId && d.isOn).length;
  }

  /// تبديل حالة جهاز (تشغيل/إيقاف)
  Future<void> toggleDevice(DeviceModel device) async {
    try {
      final newStatus = device.isOn ? 0 : 1;
      await _db.updateDeviceStatus(device.id!, newStatus);

      // تحديث الجهاز في القائمة
      final index = allDevices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        allDevices[index] = device.copyWith(status: newStatus);
        allDevices.refresh();
      }

      // تحديث عدد الأجهزة النشطة
      activeDevices.value = allDevices.where((d) => d.isOn).length;

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

      // تحديث السجلات الأخيرة
      recentLogs.insert(0, log);
      if (recentLogs.length > 10) {
        recentLogs.removeLast();
      }

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

  /// تحديث قيمة جهاز (مثل شدة الإضاءة)
  Future<void> updateDeviceValue(DeviceModel device, int newValue) async {
    try {
      await _db.updateDeviceValue(device.id!, newValue);

      // تحديث الجهاز في القائمة
      final index = allDevices.indexWhere((d) => d.id == device.id);
      if (index != -1) {
        allDevices[index] = device.copyWith(value: newValue);
        allDevices.refresh();
      }
    } catch (e) {
      _showErrorSnackbar('Error updating device value');
    }
  }

  /// تغيير فهرس التنقل السفلي
  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  /// التحقق من كون المستخدم أدمن
  bool get isAdmin => _auth.isAdmin;

  /// الحصول على اسم المستخدم
  String? get currentUsername => _auth.currentUsername;

  /// التحقق من اللغة العربية
  bool get isArabic => _storage.isArabic;

  /// عرض رسالة خطأ
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      _storage.isArabic ? 'خطأ' : 'Error',
      _storage.isArabic ? 'حدث خطأ أثناء تحميل البيانات' : message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
}