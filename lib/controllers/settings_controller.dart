import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/storage_service.dart';
import '../core/services/auth_service.dart';
import '../core/constants/app_theme.dart';
import '../routes/app_routes.dart';

/// متحكم الإعدادات - GetX Controller
class SettingsController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _auth = Get.find<AuthService>();

  // الإعدادات
  final RxBool isDarkMode = false.obs;
  final RxString language = 'ar'.obs;

  // معلومات المستخدم
  final RxString username = ''.obs;
  final RxString userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  
  }

  /// تحميل الإعدادات
  void loadSettings() {
    isDarkMode.value = _storage.isDarkMode;
    language.value = _storage.language;
    username.value = _auth.currentUsername ?? '';
    userRole.value = _auth.currentUser.value?.role ?? '';
  }

  /// تبديل الوضع الليلي/النهاري
  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    await _storage.setDarkMode(isDarkMode.value);

    // تحديث الثيم
    Get.changeTheme(
        isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme);

    _showSuccessSnackbar(
      isArabic
          ? (isDarkMode.value
              ? 'تم تفعيل الوضع الليلي'
              : 'تم تفعيل الوضع النهاري')
          : (isDarkMode.value ? 'Dark mode enabled' : 'Light mode enabled'),
    );
  }

  /// تغيير اللغة
  Future<void> changeLanguage(String langCode) async {
    language.value = langCode;
    await _storage.setLanguage(langCode);

    // تحديث اتجاه النص
    Get.updateLocale(Locale(langCode));

    _showSuccessSnackbar(
      langCode == 'ar'
          ? 'تم تغيير اللغة إلى العربية'
          : 'Language changed to English',
    );
  }

  /// تبديل اللغة
  Future<void> toggleLanguage() async {
    final newLang = language.value == 'ar' ? 'en' : 'ar';
    await changeLanguage(newLang);
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    // عرض مربع حوار تأكيد
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          isArabic ? 'تسجيل الخروج' : 'Logout',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من تسجيل الخروج؟'
              : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              isArabic ? 'خروج' : 'Logout',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _auth.logout();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// التحقق من كون المستخدم أدمن
  bool get isAdmin => _auth.isAdmin;

  /// التحقق من اللغة العربية
  bool get isArabic => language.value == 'ar';

  /// الحصول على اسم الدور
  String get roleDisplayName {
    if (userRole.value == 'admin') {
      return isArabic ? 'مدير النظام' : 'System Admin';
    }
    return isArabic ? 'عضو' : 'Member';
  }

  /// عرض رسالة نجاح
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      isArabic ? 'تم' : 'Done',
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
}
