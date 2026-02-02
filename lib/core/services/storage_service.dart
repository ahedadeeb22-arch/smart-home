import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة التخزين المحلي - SharedPreferences
/// تحفظ: حالة تسجيل الدخول، الثيم، اللغة
class StorageService extends GetxService {
  late SharedPreferences _prefs;

  // مفاتيح التخزين
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyUserRole = 'user_role';
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyLanguage = 'language';
  static const String _keyIsFirstTime = 'is_first_time';

  /// تهيئة الخدمة
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ============ إدارة تسجيل الدخول ============

  /// حفظ حالة تسجيل الدخول
  Future<void> saveLoginState({
    required int userId,
    required String username,
    required String role,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setInt(_keyUserId, userId);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyUserRole, role);
  }

  /// مسح حالة تسجيل الدخول (تسجيل الخروج)
  Future<void> clearLoginState() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyUserRole);
  }

  /// التحقق من تسجيل الدخول
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  /// الحصول على معرف المستخدم
  int? get userId => _prefs.getInt(_keyUserId);

  /// الحصول على اسم المستخدم
  String? get username => _prefs.getString(_keyUsername);

  /// الحصول على دور المستخدم
  String? get userRole => _prefs.getString(_keyUserRole);

  /// التحقق من كون المستخدم أدمن
  bool get isAdmin => userRole == 'admin';

  // ============ إدارة الثيم ============

  /// حفظ وضع الثيم
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_keyIsDarkMode, isDark);
  }

  /// الحصول على وضع الثيم
  bool get isDarkMode => _prefs.getBool(_keyIsDarkMode) ?? true;

  // ============ إدارة اللغة ============

  /// حفظ اللغة
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_keyLanguage, languageCode);
  }

  /// الحصول على اللغة
  String get language => _prefs.getString(_keyLanguage) ?? 'ar';

  /// التحقق من اللغة العربية
  bool get isArabic => language == 'ar';

  // ============ إدارة المرة الأولى ============

  /// التحقق من المرة الأولى
  bool get isFirstTime => _prefs.getBool(_keyIsFirstTime) ?? true;

  /// تعيين أنها ليست المرة الأولى
  Future<void> setNotFirstTime() async {
    await _prefs.setBool(_keyIsFirstTime, false);
  }

  // ============ مسح جميع البيانات ============

  /// مسح جميع البيانات المخزنة
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}