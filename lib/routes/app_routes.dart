import 'package:get/get.dart';
import '../core/middleware/auth_middleware.dart';
import '../views/splash_screen.dart';
import '../views/login_screen.dart';
import '../views/register_screen.dart';
import '../views/home_screen.dart';
import '../views/room_details_screen.dart';
import '../views/activity_logs_screen.dart';
import '../views/settings_screen.dart';
import '../views/admin_panel_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/room_controller.dart';
import '../controllers/device_controller.dart';
import '../controllers/settings_controller.dart';

/// مسارات التطبيق
class AppRoutes {
  AppRoutes._();

  // أسماء المسارات
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String roomDetails = '/room/:id';
  static const String activityLogs = '/logs';
  static const String settings = '/settings';
  static const String adminPanel = '/admin';

  // قائمة الصفحات
  static final List<GetPage> pages = [
    // شاشة البداية
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    // شاشة تسجيل الدخول
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
      middlewares: [GuestMiddleware()],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // شاشة التسجيل
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
      middlewares: [GuestMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // الشاشة الرئيسية
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => RoomController());
        Get.lazyPut(() => DeviceController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // شاشة تفاصيل الغرفة
    GetPage(
      name: roomDetails,
      page: () => const RoomDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => RoomController());
        Get.lazyPut(() => DeviceController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // شاشة سجل النشاط
    GetPage(
      name: activityLogs,
      page: () => const ActivityLogsScreen(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // شاشة الإعدادات
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      binding: BindingsBuilder(() {
        //   Get.lazyPut(() => SettingsController());
        // }),
        Get.lazyPut(() => SettingsController());
        // نتحقق من وجود المتحكمات الأخرى، وإذا لم توجد نقوم بإضافتها
        if (!Get.isRegistered<HomeController>())
          Get.lazyPut(() => HomeController());
        if (!Get.isRegistered<RoomController>())
          Get.lazyPut(() => RoomController());
        if (!Get.isRegistered<DeviceController>())
          Get.lazyPut(() => DeviceController());
      }),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // لوحة تحكم الأدمن
    GetPage(
      name: adminPanel,
      page: () => const AdminPanelScreen(),
      middlewares: [AdminMiddleware()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  // التنقل إلى غرفة معينة
  static String getRoomRoute(int roomId) => '/room/$roomId';
}
