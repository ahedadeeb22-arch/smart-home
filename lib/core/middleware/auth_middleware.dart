import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../../routes/app_routes.dart';

/// Middleware للتحقق من تسجيل الدخول
/// يمنع الوصول للصفحات المحمية بدون تسجيل دخول
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();

    // إذا لم يكن المستخدم مسجلاً، أعد توجيهه لصفحة تسجيل الدخول
    if (!storage.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}

/// Middleware للتحقق من صلاحيات الأدمن
/// يمنع المستخدمين العاديين من الوصول لصفحات الإدارة
class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();

    // إذا لم يكن المستخدم مسجلاً، أعد توجيهه لصفحة تسجيل الدخول
    if (!storage.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // إذا لم يكن المستخدم أدمن، أعد توجيهه للصفحة الرئيسية مع رسالة خطأ
    if (!storage.isAdmin) {
      // عرض رسالة تنبيه
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'الوصول مرفوض',
          'هذه الصفحة للمدير فقط',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.lock, color: Colors.white),
        );
      });

      return const RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
}

/// Middleware للمستخدمين المسجلين
/// يمنع المستخدمين المسجلين من الوصول لصفحات تسجيل الدخول
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();

    // إذا كان المستخدم مسجلاً، أعد توجيهه للصفحة الرئيسية
    if (storage.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
}