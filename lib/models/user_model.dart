/// نموذج المستخدم
/// يحتوي على: id, username, password, role, created_at
class UserModel {
  final int? id;
  final String username;
  final String password;
  final String role; // 'admin' أو 'member'
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    this.role = 'member',
    required this.createdAt,
  });

  /// تحويل من Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String? ?? 'member',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديلات
  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// التحقق من كون المستخدم أدمن
  bool get isAdmin => role == 'admin';

  /// التحقق من كون المستخدم عضو عادي
  bool get isMember => role == 'member';

  /// الحصول على اسم الدور بالعربية
  String get roleAr => isAdmin ? 'مدير' : 'عضو';

  /// الحصول على اسم الدور بالإنجليزية
  String get roleEn => isAdmin ? 'Admin' : 'Member';

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}