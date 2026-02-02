import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';
import '../models/device_model.dart';
import 'class_card.dart';

/// بلاطة الجهاز - Device Tile
class DeviceTile extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback? onToggle;
  final Function(int)? onValueChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showSlider;

  const DeviceTile({
    super.key,
    required this.device,
    this.onToggle,
    this.onValueChanged,
    this.onTap,
    this.onLongPress,
    this.showSlider = true,
  });

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: NeonGlassCard(
        isActive: device.isOn,
        neonColor: device.deviceColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصف العلوي: الأيقونة والتبديل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // أيقونة الجهاز
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: device.isOn
                        ? device.deviceColor.withOpacity(0.2)
                        : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    device.iconData,
                    color: device.isOn
                        ? device.deviceColor
                        : (isDark ? Colors.white38 : Colors.grey),
                    size: 28,
                  ),
                ),

                // زر التبديل
                _DeviceSwitch(
                  isOn: device.isOn,
                  onToggle: onToggle,
                  activeColor: device.deviceColor,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // اسم الجهاز
            Text(
              device.getLocalizedName(isArabic),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // نوع الجهاز وحالته
            Row(
              children: [
                Text(
                  isArabic ? device.typeAr : device.typeEn,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: device.isOn
                        ? AppColors.success.withOpacity(0.2)
                        : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    device.isOn
                        ? (isArabic ? 'مشغل' : 'ON')
                        : (isArabic ? 'مطفأ' : 'OFF'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: device.isOn
                          ? AppColors.success
                          : (isDark ? Colors.white38 : Colors.grey),
                    ),
                  ),
                ),
              ],
            ),

            // شريط التمرير (إذا كان الجهاز يدعمه وهو مشغل)
            if (showSlider && device.hasSlider && device.isOn) ...[
              const SizedBox(height: 12),
              _DeviceSlider(
                device: device,
                onChanged: onValueChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// زر تبديل الجهاز
class _DeviceSwitch extends StatelessWidget {
  final bool isOn;
  final VoidCallback? onToggle;
  final Color activeColor;

  const _DeviceSwitch({
    required this.isOn,
    this.onToggle,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 56,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isOn ? activeColor.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          border: Border.all(
            color: isOn ? activeColor : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isOn ? 28 : 2,
              top: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOn ? activeColor : Colors.grey,
                  boxShadow: isOn
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isOn ? Icons.power : Icons.power_off,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شريط تمرير الجهاز
class _DeviceSlider extends StatelessWidget {
  final DeviceModel device;
  final Function(int)? onChanged;

  const _DeviceSlider({
    required this.device,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              device.getValueDescription(isArabic),
              style: TextStyle(
                fontSize: 11,
                color: device.deviceColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              _getSliderIcon(),
              size: 16,
              color: device.deviceColor,
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: device.deviceColor,
            inactiveTrackColor: device.deviceColor.withOpacity(0.2),
            thumbColor: device.deviceColor,
            overlayColor: device.deviceColor.withOpacity(0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: device.value.roundToDouble(),
            min: device.minValue.toDouble(),
            max: device.maxValue.toDouble(),
            onChanged: (value) {
              onChanged?.call(value.round());
            },
          ),
        ),
      ],
    );
  }

  IconData _getSliderIcon() {
    switch (device.type) {
      case 'light':
        return Icons.brightness_6;
      case 'ac':
        return Icons.thermostat;
      case 'fan':
        return Icons.speed;
      case 'tv':
        return Icons.volume_up;
      default:
        return Icons.tune;
    }
  }
}

/// بلاطة جهاز صغيرة
class DeviceTileCompact extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const DeviceTileCompact({
    super.key,
    required this.device,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderColor: device.isOn
            ? device.deviceColor.withOpacity(0.5)
            : null,
        child: Row(
          children: [
            // أيقونة الجهاز
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: device.isOn
                    ? device.deviceColor.withOpacity(0.2)
                    : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                device.iconData,
                color: device.isOn
                    ? device.deviceColor
                    : (isDark ? Colors.white38 : Colors.grey),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            // معلومات الجهاز
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.getLocalizedName(isArabic),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isArabic ? device.typeAr : device.typeEn,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // زر التبديل
            _DeviceSwitch(
              isOn: device.isOn,
              onToggle: onToggle,
              activeColor: device.deviceColor,
            ),
          ],
        ),
      ),
    );
  }
}