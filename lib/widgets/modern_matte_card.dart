import 'package:flutter/material.dart';
import 'dart:ui';

class ModernMatteCard extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Color? accentColor; // لون التمييز (لون الغرفة المختار)
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ModernMatteCard({
    super.key,
    required this.child,
    this.isActive = false,
    this.accentColor,
    this.padding,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد الثيم الحالي
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // الألوان بناءً على الوضع (ليلي/نهاري)
    final Color backgroundColor = isDark
        ? const Color(0xFF1E1E1E) // خلفية ليلية (رمادي داكن)
        : const Color(0xFFFFFFFF); // خلفية نهارية (أبيض نقي)

    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    // لون التمييز (إذا لم يوجد نستخدم الأزرق الافتراضي)
    final Color activeColor = accentColor ?? Colors.blue;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // الظل يختلف بين الليلي والنهاري
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              offset: const Offset(4, 8),
              blurRadius: 16,
              spreadRadius: -2,
            ),
            // توهج خارجي خفيف جداً بلون الغرفة عند النشاط
            if (isActive)
              BoxShadow(
                color: activeColor.withOpacity(isDark ? 0.15 : 0.25),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 0,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(isDark ? 0.7 : 0.8),
                // التدرج اللوني يعتمد على لون الغرفة المختار
                gradient: isActive
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          activeColor.withOpacity(isDark ? 0.20 : 0.15),
                          activeColor.withOpacity(isDark ? 0.05 : 0.02),
                        ],
                      )
                    : null, // لا يوجد تدرج عند الخمول
                border: Border.all(
                  color: isActive ? activeColor.withOpacity(0.4) : borderColor,
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
