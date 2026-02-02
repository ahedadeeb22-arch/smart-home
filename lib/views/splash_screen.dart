import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';
import '../core/services/auth_service.dart';
import '../routes/app_routes.dart';
//"يتم استخدام Splash Screen كنقطة قرار لتوجيه المستخدم للشاشة المناسبة."
/// شاشة البداية - Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
        //"استخدام SingleTickerProvider لتحسين أداء الأنيميشن."
        with
        SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    //مدة الأنيميشن: ثانيتين
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    //ظهور تدريجي
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    //تكبير الأيقونة
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    //تأثير إضاءة
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // الانتقال بعد انتهاء الأنيميشن
    Future.delayed(const Duration(milliseconds: 2500), () {
      _navigateToNextScreen();
    });
  }

    //"تم فصل قرار التوجيه عن الواجهة والاعتماد على AuthService."
  void _navigateToNextScreen() {
    final storage = Get.find<StorageService>();
    final auth = Get.find<AuthService>();


//حذف كل الصفحات السابقة
//يمنع الرجوع إلى Splash
    if (auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //تغيير الخلفية
//  تغيير الألوان
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.cyberpunkGradient : null,
          color: isDark ? null : AppColors.lightBackground,
        ),
        child: Stack(
          children: [
            // خلفية متحركة
            if (isDark) ...[_buildAnimatedBackground()],

            // المحتوى الرئيسي
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // الأيقونة
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryCyan.withOpacity(
                                    0.5 * _glowAnimation.value,
                                  ),
                                  blurRadius: 30 * _glowAnimation.value,
                                  spreadRadius: 5 * _glowAnimation.value,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // اسم التطبيق
                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: Text(
                          'Smart Home',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.darkBackground,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: Text(
                          'HUB',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: AppColors.primaryCyan,
                            letterSpacing: 8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // مؤشر التحميل
                      Opacity(
                        opacity: _glowAnimation.value,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryCyan,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // النص السفلي
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'مركز المنزل الذكي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _BackgroundPainter(animation: _glowAnimation.value),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animation;

  _BackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // رسم خطوط متحركة
    for (int i = 0; i < 5; i++) {
      paint.color = AppColors.primaryCyan.withOpacity(0.1 * animation);
      final y = size.height * (0.2 + i * 0.15);
      canvas.drawLine(Offset(0, y), Offset(size.width * animation, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
