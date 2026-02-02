import 'package:flutter/material.dart';

/// ألوان التطبيق - ثيم Royal Slate Matte
/// (تم الحفاظ على جميع أسماء المتغيرات القديمة لضمان عدم حدوث أخطاء)
class AppColors {
  AppColors._();

  // ----------------------------------------------------------
  // 1. ألوان أساسية
  // (الأسماء كما هي، لكن القيم توحدت لتصبح درجات الأزرق الملكي)
  // ----------------------------------------------------------
  static const Color primaryCyan = Color(0xFF90CAF9); // سماوي فاتح (Light Blue)
  static const Color primaryPink = Color(
    0xFF64B5F6,
  ); // أزرق متوسط (Medium Blue)
  static const Color primaryPurple = Color(0xFF42A5F5); // أزرق غني (Rich Blue)
  static const Color primaryBlue = Color(0xFF1565C0); // أزرق عميق (Deep Blue)

  // ----------------------------------------------------------
  // 2. ألوان الخلفية
  // ----------------------------------------------------------
  static const Color darkBackground = Color(0xFF121212); // أسود مطفي فاخر
  static const Color darkSurface = Color(0xFF1E1E1E); // رمادي داكن
  static const Color darkCard = Color(0xFF252525); // لون البطاقات

  // ----------------------------------------------------------
  // 3. ألوان الوضع الفاتح
  // ----------------------------------------------------------
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ----------------------------------------------------------
  // 4. ألوان الحالة
  // ----------------------------------------------------------
  static const Color success = Color(0xFF81C784); // أخضر هادئ
  static const Color warning = Color(0xFFFFD54F); // ذهبي
  static const Color error = Color(0xFFE57373); // أحمر هادئ
  static const Color info = Color(0xFF29B6F6); // سماوي

  // ----------------------------------------------------------
  // 5. ألوان الأجهزة
  // ----------------------------------------------------------
  static const Color deviceOn = Color(0xFF42A5F5); // (أزرق) الجهاز يعمل
  static const Color deviceOff = Color(0xFF424242); // (رمادي) الجهاز مغلق
  static const Color lightDevice = Color(0xFFFFE082); // لون الإضاءة (استثناء)
  static const Color acDevice = Color(0xFF81D4FA); // لون التكييف
  static const Color securityDevice = Color(0xFFEF9A9A); // لون الأمان

  // ----------------------------------------------------------
  // 6. التدرجات اللونية (تم تحديث القيم مع الحفاظ على الأسماء)
  // ----------------------------------------------------------

  // كان سابقاً (أحمر وأزرق) -> أصبح تدرج أزرق ملكي رئيسي
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // كان (سايبر بانك) -> أصبح تدرج الخلفية الداكنة (Shadow Gradient)
  static const LinearGradient cyberpunkGradient = LinearGradient(
    colors: [Color(0xFF121212), Color(0xFF263238)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // تدرج زجاجي (تم جعله مطفياً وناعماً جداً)
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 255, 255, 0.05),
      Color.fromRGBO(255, 255, 255, 0.02),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // نيون سماوي -> تدرج سماوي هادئ
  static const LinearGradient neonCyanGradient = LinearGradient(
    colors: [Color(0xFF90CAF9), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // نيون وردي -> أصبح تدرج أزرق ليلي (لتوحيد الثيم)
  // حافظنا على الاسم neonPinkGradient لكي لا يحدث Error، لكن اللون أزرق
  static const LinearGradient neonPinkGradient = LinearGradient(
    colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
