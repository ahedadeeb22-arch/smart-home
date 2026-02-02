import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../core/constants/app_colors.dart';
import '../core/database/database_helper.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';

/// متحكم لوحة التحكم - المنطق البرمجي
class AdminController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final StorageService _storage = Get.find<StorageService>();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxInt totalUsers = 0.obs;
  final RxInt totalLogs = 0.obs;
  final RxInt totalRooms = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAdminData();
  }

  /// تحميل كافة البيانات من قاعدة البيانات
  Future<void> loadAdminData() async {
    isLoading.value = true;
    try {
      // جلب قائمة المستخدمين
      final usersList = await _db.getAllUsers();
      users.assignAll(usersList);

      // جلب الإحصائيات
      final stats = await _db.getStatistics();
      totalUsers.value = stats['users'] ?? 0;
      totalLogs.value = stats['logs'] ?? 0;
      totalRooms.value = stats['rooms'] ?? 0;
    } catch (e) {
      _showErrorSnackbar('حدث خطأ أثناء تحميل البيانات');
    } finally {
      isLoading.value = false;
    }
  }

  /// حذف مستخدم من النظام
  Future<void> deleteUser(UserModel user) async {
    if (user.role == 'admin') {
      _showErrorSnackbar('لا يمكن حذف حساب المدير الرئيسي');
      return;
    }

    try {
      await _db.deleteUser(user.id!);
      await loadAdminData(); // تحديث القائمة
      Get.snackbar(
        isArabic ? 'تم بنجاح' : 'Success',
        isArabic ? 'تم حذف المستخدم ${user.username}' : 'User ${user.username} deleted',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      _showErrorSnackbar('فشل حذف المستخدم');
    }
  }

  /// مسح كافة سجلات النشاط
  Future<void> clearSystemLogs() async {
    try {
      await _db.clearActivityLogs();
      await loadAdminData();
      Get.snackbar(
        isArabic ? 'تم المسح' : 'Logs Cleared',
        isArabic ? 'تم إفراغ سجل النشاط بالكامل' : 'All activity logs have been removed',
        backgroundColor: AppColors.primaryCyan.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      _showErrorSnackbar('فشل مسح السجلات');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      isArabic ? 'خطأ إداري' : 'Admin Error',
      message,
      backgroundColor: Colors.redAccent.withOpacity(0.7),
      colorText: Colors.white,
    );
  }

  bool get isArabic => _storage.isArabic;
}
