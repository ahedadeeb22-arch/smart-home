import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../routes/app_routes.dart';
//أي أنه المسؤول عن كل ما يتعلق بتسجيل الدخول، إنشاء الحساب، وتسجيل الخروج.
/// متحكم المصادقة - GetX Controller
class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storage = Get.find<StorageService>();

  // حقول النموذج
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // حالة التحميل
  final RxBool isLoading = false.obs;

  // إظهار كلمة المرور
  final RxBool showPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;

  // الدور المختار (للتسجيل)
  final RxString selectedRole = 'member'.obs;

  // رسالة الخطأ
  final RxString errorMessage = ''.obs;


  // مفتاح خاص بشاشة تسجيل الدخول
  final loginFormKey = GlobalKey<FormState>();
  
  // مفتاح خاص بشاشة إنشاء الحساب
  final registerFormKey = GlobalKey<FormState>();



  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// تبديل إظهار كلمة المرور
  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  /// تبديل إظهار تأكيد كلمة المرور
  void toggleShowConfirmPassword() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  /// تغيير الدور
  void setRole(String role) {
    selectedRole.value = role;
  }

  /// مسح الحقول
  void clearFields() {
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    errorMessage.value = '';
    selectedRole.value = 'member';
  }

  /// تسجيل الدخول
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _authService.login(
        usernameController.text.trim(),
        passwordController.text,
      );

      if (result.success) {
        // عرض رسالة نجاح
        Get.snackbar(
          _storage.isArabic ? 'نجاح' : 'Success',
          _storage.isArabic ? result.message : result.messageEn,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // الانتقال للصفحة الرئيسية
        Get.offAllNamed(AppRoutes.home);
      } else {
        errorMessage.value = _storage.isArabic ? result.message : result.messageEn;
        _showErrorSnackbar();
      }
    } catch (e) {
      errorMessage.value = _storage.isArabic
          ? 'حدث خطأ غير متوقع'
          : 'An unexpected error occurred';
      _showErrorSnackbar();
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل مستخدم جديد
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _authService.register(
        username: usernameController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        role: selectedRole.value,
      );

      if (result.success) {
        // عرض رسالة نجاح
        Get.snackbar(
          _storage.isArabic ? 'نجاح' : 'Success',
          _storage.isArabic ? result.message : result.messageEn,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // الانتقال للصفحة الرئيسية
        Get.offAllNamed(AppRoutes.home);
      } else {
        errorMessage.value = _storage.isArabic ? result.message : result.messageEn;
        _showErrorSnackbar();
      }
    } catch (e) {
      errorMessage.value = _storage.isArabic
          ? 'حدث خطأ غير متوقع'
          : 'An unexpected error occurred';
      _showErrorSnackbar();
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  /// عرض رسالة خطأ
  void _showErrorSnackbar() {
    Get.snackbar(
      _storage.isArabic ? 'خطأ' : 'Error',
      errorMessage.value,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// التحقق من صحة اسم المستخدم
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return _storage.isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
    }
    if (value.length < 3) {
      return _storage.isArabic
          ? 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل'
          : 'Username must be at least 3 characters';
    }
    return null;
  }

  /// التحقق من صحة كلمة المرور
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _storage.isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
    }
    if (value.length < 4) {
      return _storage.isArabic
          ? 'كلمة المرور يجب أن تكون 4 أحرف على الأقل'
          : 'Password must be at least 4 characters';
    }
    return null;
  }

  /// التحقق من تأكيد كلمة المرور
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return _storage.isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
    }
    if (value != passwordController.text) {
      return _storage.isArabic
          ? 'كلمات المرور غير متطابقة'
          : 'Passwords do not match';
    }
    return null;
  }
}