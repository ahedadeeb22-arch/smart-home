import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// نموذج الجهاز
/// يحتوي على: id, name, type, status, value, room_id, icon
class DeviceModel {
  final int? id;
  final String name;
  final String? nameAr;
  final String type; // 'light', 'ac', 'door', 'fan', 'tv', 'camera'
  final int status; // 0 = مطفأ, 1 = مشغل
  final int value; // قيمة إضافية (مثل: شدة الإضاءة، درجة الحرارة)
  final int roomId;
  final String? icon;
  final DateTime createdAt;

  DeviceModel({
    this.id,
    required this.name,
    this.nameAr,
    required this.type,
    this.status = 0,
    this.value = 0,
    required this.roomId,
    this.icon,
    required this.createdAt,
  });

  /// تحويل من Map
  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      nameAr: map['name_ar'] as String?,
      type: map['type'] as String,
      status: map['status'] as int? ?? 0,
      value: map['value'] as int? ?? 0,
      roomId: map['room_id'] as int,
      icon: map['icon'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'name_ar': nameAr,
      'type': type,
      'status': status,
      'value': value,
      'room_id': roomId,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديلات
  DeviceModel copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? type,
    int? status,
    int? value,
    int? roomId,
    String? icon,
    DateTime? createdAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      type: type ?? this.type,
      status: status ?? this.status,
      value: value ?? this.value,
      roomId: roomId ?? this.roomId,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// التحقق من كون الجهاز مشغل
  bool get isOn => status == 1;

  /// التحقق من كون الجهاز مطفأ
  bool get isOff => status == 0;

  /// الحصول على الأيقونة كـ IconData
  IconData get iconData {
    switch (type.toLowerCase()) {
      case 'light':
        return isOn ? Icons.lightbulb : Icons.lightbulb_outline;
      case 'ac':
        return Icons.ac_unit;
      case 'door':
        return isOn ? Icons.door_front_door : Icons.door_sliding;
      case 'fan':
        return Icons.air;
      case 'tv':
        return isOn ? Icons.tv : Icons.tv_off;
      case 'camera':
        return isOn ? Icons.videocam : Icons.videocam_off;
      case 'speaker':
        return isOn ? Icons.speaker : Icons.speaker_outlined;
      case 'thermostat':
        return Icons.thermostat;
      case 'lock':
        return isOn ? Icons.lock_open : Icons.lock;
      default:
        return Icons.devices;
    }
  }

  /// الحصول على لون الجهاز حسب النوع والحالة
  Color get deviceColor {
    if (!isOn) return AppColors.deviceOff;

    switch (type.toLowerCase()) {
      case 'light':
        return AppColors.lightDevice;
      case 'ac':
        return AppColors.acDevice;
      case 'door':
      case 'camera':
      case 'lock':
        return AppColors.securityDevice;
      case 'fan':
        return const Color(0xFF00E5FF);
      case 'tv':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.deviceOn;
    }
  }

  /// الحصول على اسم النوع بالعربية
  String get typeAr {
    switch (type.toLowerCase()) {
      case 'light':
        return 'إضاءة';
      case 'ac':
        return 'تكييف';
      case 'door':
        return 'باب';
      case 'fan':
        return 'مروحة';
      case 'tv':
        return 'تلفاز';
      case 'camera':
        return 'كاميرا';
      case 'speaker':
        return 'مكبر صوت';
      case 'thermostat':
        return 'منظم حرارة';
      case 'lock':
        return 'قفل';
      default:
        return 'جهاز';
    }
  }

  /// الحصول على اسم النوع بالإنجليزية
  String get typeEn {
    switch (type.toLowerCase()) {
      case 'light':
        return 'Light';
      case 'ac':
        return 'Air Conditioner';
      case 'door':
        return 'Door';
      case 'fan':
        return 'Fan';
      case 'tv':
        return 'TV';
      case 'camera':
        return 'Camera';
      case 'speaker':
        return 'Speaker';
      case 'thermostat':
        return 'Thermostat';
      case 'lock':
        return 'Lock';
      default:
        return 'Device';
    }
  }

  /// الحصول على وصف القيمة حسب نوع الجهاز
  String getValueDescription(bool isArabic) {
    switch (type.toLowerCase()) {
      case 'light':
        return isArabic ? 'السطوع: $value%' : 'Brightness: $value%';
      case 'ac':
        return isArabic ? 'درجة الحرارة: $value°C' : 'Temperature: $value°C';
      case 'fan':
        return isArabic ? 'السرعة: $value' : 'Speed: $value';
      case 'tv':
        return isArabic ? 'الصوت: $value%' : 'Volume: $value%';
      default:
        return '';
    }
  }

  /// التحقق مما إذا كان الجهاز يدعم شريط التمرير
  bool get hasSlider {
    return ['light', 'ac', 'fan', 'tv'].contains(type.toLowerCase());
  }

  /// الحصول على القيمة القصوى للشريط
  int get maxValue {
    switch (type.toLowerCase()) {
      case 'light':
      case 'tv':
        return 100;
      case 'ac':
        return 30;
      case 'fan':
        return 5;
      default:
        return 100;
    }
  }

  /// الحصول على القيمة الدنيا للشريط
  int get minValue {
    switch (type.toLowerCase()) {
      case 'ac':
        return 16;
      case 'fan':
        return 1;
      default:
        return 0;
    }
  }

  /// الحصول على الاسم المناسب حسب اللغة
  String getLocalizedName(bool isArabic) {
    if (isArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  @override
  String toString() {
    return 'DeviceModel(id: $id, name: $name, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// قائمة أنواع الأجهزة المتاحة
class DeviceTypes {
  static const List<Map<String, dynamic>> types = [
    {'type': 'light', 'icon': Icons.lightbulb, 'label': 'إضاءة', 'labelEn': 'Light'},
    {'type': 'ac', 'icon': Icons.ac_unit, 'label': 'مكيف', 'labelEn': 'AC'},
    {'type': 'door', 'icon': Icons.door_sliding, 'label': 'باب', 'labelEn': 'Door'},
    {'type': 'fan', 'icon': Icons.air, 'label': 'مروحة', 'labelEn': 'Fan'},
    {'type': 'tv', 'icon': Icons.tv, 'label': 'تلفاز', 'labelEn': 'TV'},
    {'type': 'camera', 'icon': Icons.videocam, 'label': 'كاميرا', 'labelEn': 'Camera'},
    {'type': 'speaker', 'icon': Icons.speaker, 'label': 'مكبر صوت', 'labelEn': 'Speaker'},
    {'type': 'lock', 'icon': Icons.lock, 'label': 'قفل', 'labelEn': 'Lock'},
  ];
}