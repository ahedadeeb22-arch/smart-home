import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // للتأثير الزجاجي
import '../core/services/storage_service.dart';
import '../models/room_model.dart';
import '../core/constants/app_colors.dart';
 // تأكد من وجود ملف الألوان

// ==========================================
// 1. الكارد الموحد المتكيف (ModernMatteCard) - النسخة المحسنة
// ==========================================
class ModernMatteCard extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ModernMatteCard({
    super.key,
    required this.child,
    this.isActive = false,
    this.padding,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color unifiedColor = AppColors.primaryBlue;

    // --- إعدادات الألوان المحسنة ---
    Color backgroundColor;
    Color borderColor;
    List<Color>? gradientColors;

    if (isDark) {
      // === الوضع الليلي ===
      if (isActive) {
        // نشط: أزرق عميق وواضح
        backgroundColor = unifiedColor.withOpacity(0.20);
        borderColor = unifiedColor.withOpacity(0.5);
        gradientColors = [
          unifiedColor.withOpacity(0.25),
          unifiedColor.withOpacity(0.10),
        ];
      } else {
        // خامل (أو جديد): رمادي زجاجي (ليس أسود!)
        // تم التفتيح قليلاً لتبرز البطاقة عن الخلفية السوداء
        backgroundColor = const Color(0xFF2C3E50).withOpacity(0.3);
        borderColor = Colors.white.withOpacity(0.12); // حدود واضحة قليلاً
        gradientColors = [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.02),
        ];
      }
    } else {
      // === الوضع النهاري ===
      if (isActive) {
        backgroundColor = Colors.white;
        borderColor = unifiedColor.withOpacity(0.6);
        gradientColors = [unifiedColor.withOpacity(0.1), Colors.white];
      } else {
        backgroundColor = Colors.white;
        borderColor = const Color(0xFFE0E0E0); // رمادي فاتح جداً
      }
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          // تعديل الزوايا لتكون أقل انحناءً (أكثر حدة وعصرية)
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.15),
              offset: const Offset(2, 4), // ظل أقرب للكارد
              blurRadius: 12,
              spreadRadius: -1,
            ),
            // توهج أزرق ناعم عند النشاط
            if (isActive)
              BoxShadow(
                color: unifiedColor.withOpacity(isDark ? 0.25 : 0.3),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
          ],
        ),
        child: ClipRRect(
          // التأكد من تطابق الـ Clip مع الزوايا الجديدة
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                gradient: gradientColors != null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      )
                    : null,
                border: Border.all(
                  color: borderColor,
                  width: 1.2, // سمك حدود أنحف وأكثر أناقة
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
// ==========================================
// 2. بطاقة الغرفة (RoomCard) - الموحدة
// ==========================================
class RoomCard extends StatelessWidget {
  final RoomModel room;
  final int deviceCount;
  final int activeDeviceCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const RoomCard({
    super.key,
    required this.room,
    this.deviceCount = 0,
    this.activeDeviceCount = 0,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveDevices = activeDeviceCount > 0;

    // 🟢 التوحيد: نستخدم الأزرق دائماً ونتجاهل لون الغرفة المخصص
    const Color unifiedColor = AppColors.primaryBlue; // أو Colors.blue

    // ضبط ألوان النصوص والأيقونات حسب الوضع
    final Color mainTextColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white54 : Colors.grey;

    // لون الأيقونة: أزرق عند النشاط، ورمادي/أبيض عند الخمول
    final Color iconColor = hasActiveDevices
        ? unifiedColor
        : (isDark ? Colors.white54 : Colors.black45);

    return ModernMatteCard(
      isActive: hasActiveDevices,
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف العلوي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // حاوية الأيقونة
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: hasActiveDevices
                      ? unifiedColor.withOpacity(0.1) // خلفية زرقاء خافتة جداً
                      : (isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.04)),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: hasActiveDevices
                        ? unifiedColor.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Icon(room.iconData, color: iconColor, size: 26),
              ),

              // مؤشر النشاط (Badge)
              if (hasActiveDevices)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: unifiedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: unifiedColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: unifiedColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$activeDeviceCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: unifiedColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const Spacer(),

          // اسم الغرفة
          Text(
            room.getLocalizedName(isArabic),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: mainTextColor,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 5),

          // عدد الأجهزة
          Text(
            isArabic
                ? '$deviceCount ${deviceCount == 1 ? 'جهاز' : 'أجهزة'}'
                : '$deviceCount ${deviceCount == 1 ? 'device' : 'devices'}',
            style: TextStyle(fontSize: 13, color: subTextColor),
          ),

          const SizedBox(height: 12),

          // شريط التقدم
          if (deviceCount > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: activeDeviceCount / deviceCount,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  hasActiveDevices
                      ? unifiedColor
                      : (isDark ? Colors.white24 : Colors.grey),
                ),
                minHeight: 4,
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. RoomCardCompact - الموحدة للقوائم
// ==========================================
class RoomCardCompact extends StatelessWidget {
  final RoomModel room;
  final int deviceCount;
  final int activeDeviceCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const RoomCardCompact({
    super.key,
    required this.room,
    this.deviceCount = 0,
    this.activeDeviceCount = 0,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveDevices = activeDeviceCount > 0;

    const Color unifiedColor = AppColors.primaryBlue;

    return GestureDetector(
      onTap: onTap,
      child: ModernMatteCard(
        isActive: hasActiveDevices,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasActiveDevices
                    ? unifiedColor.withOpacity(0.1)
                    : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.04)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                room.iconData,
                color: hasActiveDevices
                    ? unifiedColor
                    : (isDark ? Colors.white54 : Colors.black54),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.getLocalizedName(isArabic),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic ? '$deviceCount أجهزة' : '$deviceCount devices',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            if (showActions) ...[
              IconButton(
                icon: Icon(
                  Icons.edit_rounded,
                  color: isDark ? Colors.white60 : Colors.black54,
                  size: 20,
                ),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_rounded,
                  color: AppColors.error.withOpacity(0.8),
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ] else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.5),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. بطاقة الإضافة (AddRoomCard) - إصلاح المشكلة
// ==========================================
class AddRoomCard extends StatelessWidget {
  final VoidCallback? onTap;

  const AddRoomCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;
    // التحقق من الوضع
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent, // شفاف دائماً
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            // في الليل: حدود بيضاء شفافة، في النهار: حدود سوداء شفافة
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.1),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                // خلفية الدائرة تتغير مع الوضع
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                // لون الأيقونة يتغير مع الوضع
                color: isDark ? Colors.white54 : Colors.black45,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isArabic ? 'إضافة غرفة' : 'Add Room',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                // لون النص يتغير مع الوضع
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
