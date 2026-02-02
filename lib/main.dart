import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/constants/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/auth_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تعيين اتجاه الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة الخدمات
//   لضمان أن:
// التخزين جاهز
// المستخدم معروف (مسجل أم لا)
// قبل عرض أي شاشة
  await initServices();

  runApp(const SmartHomeApp());
}

/// تهيئة الخدمات
Future<void> initServices() async {

  // تهيئة خدمة التخزين
  final storage = await Get.putAsync(() => StorageService().init());
  
  // تهيئة خدمة المصادقة

  final authService = AuthService();
  await authService.init();
  Get.put(authService);
}

/// التطبيق الرئيسي
class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();

    return GetMaterialApp(
      title: 'Smart Home Hub',
      debugShowCheckedModeBanner: false,

      // الثيم
      //"التطبيق يدعم تغيير الثيم بناءً على إعدادات المستخدم المخزنة محليًا."
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // اللغة
      locale: Locale(storage.language),
      fallbackLocale: const Locale('en'),

      // الاتجاه
      builder: (context, child) {
        return Directionality(
          textDirection:
              storage.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },

      // المسارات
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,

      // تخصيص الانتقالات
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
//ملف main.dart هو نقطة تشغيل التطبيق،
// يتم فيه تهيئة الخدمات الأساسية مثل التخزين والمصادقة باستخدام GetX،
// ثم تشغيل التطبيق مع دعم الثيم الداكن، تعدد اللغات،
// واتجاه النص، مع نظام تنقل مركزي
