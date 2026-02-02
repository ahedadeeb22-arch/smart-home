import 'package:get/get.dart';
import '../database/database_helper.dart';
import '../../models/user_model.dart';
import 'storage_service.dart';

/// خدمة المصادقة - إدارة تسجيل الدخول والخروج
class AuthService extends GetxService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final StorageService _storage = Get.find<StorageService>();

  // حالة المستخدم الحالي
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  /// تهيئة الخدمة
  Future<AuthService> init() async {
    // التحقق من حالة تسجيل الدخول المحفوظة
    if (_storage.isLoggedIn && _storage.userId != null) {
      final user = await _db.getUserById(_storage.userId!);
      if (user != null) {
        currentUser.value = user;
      } else {
        // المستخدم غير موجود، مسح حالة تسجيل الدخول
        await _storage.clearLoginState();
      }
    }
    return this;
  }

  /// تسجيل الدخول
  Future<AuthResult> login(String username, String password) async {
    try {
      // التحقق من الحقول الفارغة
      if (username.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          message: 'يرجى إدخال اسم المستخدم وكلمة المرور',
          messageEn: 'Please enter username and password',
        );
      }

      // البحث عن المستخدم
      final user = await _db.getUser(username, password);

      if (user == null) {
        return AuthResult(
          success: false,
          message: 'اسم المستخدم أو كلمة المرور غير صحيحة',
          messageEn: 'Invalid username or password',
        );
      }

      // حفظ حالة تسجيل الدخول
      await _storage.saveLoginState(
        userId: user.id!,
        username: user.username,
        role: user.role,
      );

      currentUser.value = user;

      return AuthResult(
        success: true,
        message: 'تم تسجيل الدخول بنجاح',
        messageEn: 'Login successful',
        user: user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ أثناء تسجيل الدخول',
        messageEn: 'An error occurred during login',
      );
    }
  }

  /// تسجيل مستخدم جديد
  Future<AuthResult> register({
    required String username,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    try {
      // التحقق من الحقول الفارغة
      if (username.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          message: 'يرجى ملء جميع الحقول',
          messageEn: 'Please fill all fields',
        );
      }

      // التحقق من تطابق كلمات المرور
      if (password != confirmPassword) {
        return AuthResult(
          success: false,
          message: 'كلمات المرور غير متطابقة',
          messageEn: 'Passwords do not match',
        );
      }

      // التحقق من طول كلمة المرور
      if (password.length < 4) {
        return AuthResult(
          success: false,
          message: 'كلمة المرور يجب أن تكون 4 أحرف على الأقل',
          messageEn: 'Password must be at least 4 characters',
        );
      }

      // التحقق من وجود اسم المستخدم
      final exists = await _db.usernameExists(username);
      if (exists) {
        return AuthResult(
          success: false,
          message: 'اسم المستخدم موجود مسبقاً',
          messageEn: 'Username already exists',
        );
      }

      // إنشاء المستخدم الجديد
      final user = UserModel(
        username: username,
        password: password,
        role: role,
        createdAt: DateTime.now(),
      );

      final userId = await _db.insertUser(user);
      final newUser = user.copyWith(id: userId);

      // حفظ حالة تسجيل الدخول
      await _storage.saveLoginState(
        userId: userId,
        username: username,
        role: role,
      );

      currentUser.value = newUser;

      return AuthResult(
        success: true,
        message: 'تم إنشاء الحساب بنجاح',
        messageEn: 'Account created successfully',
        user: newUser,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ أثناء إنشاء الحساب',
        messageEn: 'An error occurred during registration',
      );
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _storage.clearLoginState();
    currentUser.value = null;
  }

  /// التحقق من تسجيل الدخول
  bool get isLoggedIn => currentUser.value != null;

  /// التحقق من كون المستخدم أدمن
  bool get isAdmin => currentUser.value?.role == 'admin';

  /// الحصول على اسم المستخدم الحالي
  String? get currentUsername => currentUser.value?.username;

  /// الحصول على معرف المستخدم الحالي
  int? get currentUserId => currentUser.value?.id;
}

/// نتيجة عملية المصادقة
class AuthResult {
  final bool success;
  final String message;
  final String messageEn;
  final UserModel? user;

  AuthResult({
    required this.success,
    required this.message,
    required this.messageEn,
    this.user,
  });
}