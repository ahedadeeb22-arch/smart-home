import 'package:flutter/material.dart';

/// نموذج الغرفة
/// يحتوي على: id, name, name_ar, icon, color, created_at
class RoomModel {
  final int? id;
  final String name;
  final String? nameAr;
  final String icon;
  final String color;
  final DateTime createdAt;

  RoomModel({
    this.id,
    required this.name,
    this.nameAr,
    this.icon = 'home',
    this.color = '#00F5FF',
    required this.createdAt,
  });

  /// تحويل من Map
  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      nameAr: map['name_ar'] as String?,
      icon: map['icon'] as String? ?? 'home',
      color: map['color'] as String? ?? '#00F5FF',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'name_ar': nameAr,
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديلات
  RoomModel copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// الحصول على اللون كـ Color
  Color get colorValue {
    try {
      String hex = color.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF00F5FF);
    }
  }

  /// الحصول على الأيقونة كـ IconData
  IconData get iconData {
    switch (icon.toLowerCase()) {
      case 'sofa':
      case 'living_room':
        return Icons.weekend;
      case 'bed':
      case 'bedroom':
        return Icons.bed;
      case 'kitchen':
        return Icons.kitchen;
      case 'bathroom':
        return Icons.bathtub;
      case 'garage':
        return Icons.garage;
      case 'garden':
        return Icons.grass;
      case 'office':
        return Icons.computer;
      case 'dining':
        return Icons.dining;
      case 'balcony':
        return Icons.balcony;
      case 'pool':
        return Icons.pool;
      default:
        return Icons.home;
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
    return 'RoomModel(id: $id, name: $name, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// قائمة الأيقونات المتاحة للغرف
class RoomIcons {
  static const List<Map<String, dynamic>> icons = [
    {'name': 'sofa', 'icon': Icons.weekend, 'label': 'غرفة معيشة'},
    {'name': 'bed', 'icon': Icons.bed, 'label': 'غرفة نوم'},
    {'name': 'kitchen', 'icon': Icons.kitchen, 'label': 'مطبخ'},
    {'name': 'bathroom', 'icon': Icons.bathtub, 'label': 'حمام'},
    {'name': 'garage', 'icon': Icons.garage, 'label': 'مرآب'},
    {'name': 'garden', 'icon': Icons.grass, 'label': 'حديقة'},
    {'name': 'office', 'icon': Icons.computer, 'label': 'مكتب'},
    {'name': 'dining', 'icon': Icons.dining, 'label': 'غرفة طعام'},
    {'name': 'balcony', 'icon': Icons.balcony, 'label': 'شرفة'},
    {'name': 'pool', 'icon': Icons.pool, 'label': 'مسبح'},
    {'name': 'home', 'icon': Icons.home, 'label': 'عام'},
  ];
}

/// قائمة الألوان المتاحة للغرف
class RoomColors {
  static const List<String> colors = [
    '#00F5FF', // سماوي
    '#8B5CF6', // بنفسجي
    '#F59E0B', // برتقالي
    '#EF4444', // أحمر
    '#10B981', // أخضر
    '#3B82F6', // أزرق
    '#EC4899', // وردي
    '#6366F1', // نيلي
    '#14B8A6', // تركواز
    '#F97316', // برتقالي غامق
    // Blue
  ];
  // دالة لتحويل كود الـ Hex إلى كائن Color
static Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
}
 