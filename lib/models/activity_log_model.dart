/// نموذج سجل النشاط
/// يحتوي على: id, action, timestamp, device_id, user_id
class ActivityLogModel {
  final int? id;
  final String action;
  final String? actionAr;
  final DateTime timestamp;
  final int? deviceId;
  final int userId;
  final String? deviceName;
  final String? userName;

  ActivityLogModel({
    this.id,
    required this.action,
    this.actionAr,
    required this.timestamp,
    this.deviceId,
    required this.userId,
    this.deviceName,
    this.userName,
  });

  /// تحويل من Map
  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] as int?,
      action: map['action'] as String,
      actionAr: map['action_ar'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      deviceId: map['device_id'] as int?,
      userId: map['user_id'] as int,
      deviceName: map['device_name'] as String?,
      userName: map['user_name'] as String?,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'action': action,
      'action_ar': actionAr,
      'timestamp': timestamp.toIso8601String(),
      'device_id': deviceId,
      'user_id': userId,
      'device_name': deviceName,
      'user_name': userName,
    };
  }

  /// نسخ مع تعديلات
  ActivityLogModel copyWith({
    int? id,
    String? action,
    String? actionAr,
    DateTime? timestamp,
    int? deviceId,
    int? userId,
    String? deviceName,
    String? userName,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      action: action ?? this.action,
      actionAr: actionAr ?? this.actionAr,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      deviceName: deviceName ?? this.deviceName,
      userName: userName ?? this.userName,
    );
  }

  /// الحصول على الوقت المنسق
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// الحصول على التاريخ المنسق
  String get formattedDate {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    return '$day/$month/$year';
  }

  /// الحصول على التاريخ والوقت المنسق
  String get formattedDateTime {
    return '$formattedDate - $formattedTime';
  }

  /// الحصول على الوقت النسبي (منذ...)
  String getRelativeTime(bool isArabic) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return isArabic ? 'الآن' : 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return isArabic
          ? 'منذ $minutes دقيقة'
          : '$minutes minute${minutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return isArabic
          ? 'منذ $hours ساعة'
          : '$hours hour${hours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return isArabic
          ? 'منذ $days يوم'
          : '$days day${days > 1 ? 's' : ''} ago';
    } else {
      return formattedDate;
    }
  }

  /// الحصول على الإجراء المناسب حسب اللغة
  String getLocalizedAction(bool isArabic) {
    if (isArabic && actionAr != null && actionAr!.isNotEmpty) {
      return actionAr!;
    }
    return action;
  }

  /// إنشاء سجل لتشغيل جهاز
  static ActivityLogModel turnOn({
    required int userId,
    required String userName,
    required int deviceId,
    required String deviceName,
    String? deviceNameAr,
  }) {
    return ActivityLogModel(
      action: '$userName turned on $deviceName',
      actionAr: '$userName قام بتشغيل ${deviceNameAr ?? deviceName}',
      timestamp: DateTime.now(),
      deviceId: deviceId,
      userId: userId,
      deviceName: deviceName,
      userName: userName,
    );
  }

  /// إنشاء سجل لإيقاف جهاز
  static ActivityLogModel turnOff({
    required int userId,
    required String userName,
    required int deviceId,
    required String deviceName,
    String? deviceNameAr,
  }) {
    return ActivityLogModel(
      action: '$userName turned off $deviceName',
      actionAr: '$userName قام بإيقاف ${deviceNameAr ?? deviceName}',
      timestamp: DateTime.now(),
      deviceId: deviceId,
      userId: userId,
      deviceName: deviceName,
      userName: userName,
    );
  }

  /// إنشاء سجل لتغيير قيمة جهاز
  static ActivityLogModel changeValue({
    required int userId,
    required String userName,
    required int deviceId,
    required String deviceName,
    required int newValue,
    required String valueType,
    String? deviceNameAr,
    String? valueTypeAr,
  }) {
    return ActivityLogModel(
      action: '$userName changed $deviceName $valueType to $newValue',
      actionAr: '$userName غيّر ${valueTypeAr ?? valueType} ${deviceNameAr ?? deviceName} إلى $newValue',
      timestamp: DateTime.now(),
      deviceId: deviceId,
      userId: userId,
      deviceName: deviceName,
      userName: userName,
    );
  }

  @override
  String toString() {
    return 'ActivityLogModel(id: $id, action: $action, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityLogModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}