import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/user_model.dart';
import '../../models/room_model.dart';
import '../../models/device_model.dart';
import '../../models/activity_log_model.dart';

/// مساعد قاعدة البيانات - SQFlite
/// يحتوي على 4 جداول: users, rooms, devices, activity_logs
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // ============ إعداد قاعدة البيانات ============
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_home.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // ============ جدول المستخدمين ============
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'member',
        created_at TEXT NOT NULL
      )
    ''');

    // ============ جدول الغرف ============
    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_ar TEXT,
        icon TEXT NOT NULL DEFAULT 'home',
        color TEXT DEFAULT '#00F5FF',
        created_at TEXT NOT NULL
      )
    ''');

    // ============ جدول الأجهزة ============
    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_ar TEXT,
        type TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        value INTEGER DEFAULT 0,
        room_id INTEGER NOT NULL,
        icon TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE CASCADE
      )
    ''');

    // ============ جدول سجل النشاط ============
    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        action_ar TEXT,
        timestamp TEXT NOT NULL,
        device_id INTEGER,
        user_id INTEGER NOT NULL,
        device_name TEXT,
        user_name TEXT,
        FOREIGN KEY (device_id) REFERENCES devices (id) ON DELETE SET NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // ============ إضافة بيانات افتراضية ============
    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // إضافة مستخدم أدمن افتراضي
    await db.insert('users', {
      'username': 'ahed',
      'password': 'ahed1525',
      'role': 'admin',
      'created_at': now,
    });

    // إضافة مستخدم عادي افتراضي
    await db.insert('users', {
      'username': 'user',
      'password': 'user123',
      'role': 'member',
      'created_at': now,
    });

    // إضافة غرف افتراضية
    final livingRoomId = await db.insert('rooms', {
      'name': 'Living Room',
      'name_ar': 'غرفة المعيشة',
      'icon': 'sofa',
      'color': '#00F5FF',
      'created_at': now,
    });

    final bedroomId = await db.insert('rooms', {
      'name': 'Bedroom',
      'name_ar': 'غرفة النوم',
      'icon': 'bed',
      'color': '#8B5CF6',
      'created_at': now,
    });

    final kitchenId = await db.insert('rooms', {
      'name': 'Kitchen',
      'name_ar': 'المطبخ',
      'icon': 'kitchen',
      'color': '#F59E0B',
      'created_at': now,
    });

    final garageId = await db.insert('rooms', {
      'name': 'Garage',
      'name_ar': 'المرآب',
      'icon': 'garage',
      'color': '#EF4444',
      'created_at': now,
    });

    // إضافة أجهزة افتراضية لغرفة المعيشة
    await db.insert('devices', {
      'name': 'Main Light',
      'name_ar': 'الإضاءة الرئيسية',
      'type': 'light',
      'status': 1,
      'value': 80,
      'room_id': livingRoomId,
      'icon': 'lightbulb',
      'created_at': now,
    });

    await db.insert('devices', {
      'name': 'Air Conditioner',
      'name_ar': 'المكيف',
      'type': 'ac',
      'status': 0,
      'value': 24,
      'room_id': livingRoomId,
      'icon': 'ac_unit',
      'created_at': now,
    });

    await db.insert('devices', {
      'name': 'Smart TV',
      'name_ar': 'التلفاز الذكي',
      'type': 'tv',
      'status': 0,
      'value': 50,
      'room_id': livingRoomId,
      'icon': 'tv',
      'created_at': now,
    });

    // أجهزة غرفة النوم
    await db.insert('devices', {
      'name': 'Bedroom Light',
      'name_ar': 'إضاءة غرفة النوم',
      'type': 'light',
      'status': 0,
      'value': 50,
      'room_id': bedroomId,
      'icon': 'lightbulb',
      'created_at': now,
    });

    await db.insert('devices', {
      'name': 'Ceiling Fan',
      'name_ar': 'المروحة السقفية',
      'type': 'fan',
      'status': 1,
      'value': 3,
      'room_id': bedroomId,
      'icon': 'air',
      'created_at': now,
    });

    // أجهزة المطبخ
    await db.insert('devices', {
      'name': 'Kitchen Light',
      'name_ar': 'إضاءة المطبخ',
      'type': 'light',
      'status': 1,
      'value': 100,
      'room_id': kitchenId,
      'icon': 'lightbulb',
      'created_at': now,
    });

    // أجهزة المرآب
    await db.insert('devices', {
      'name': 'Garage Door',
      'name_ar': 'باب المرآب',
      'type': 'door',
      'status': 0,
      'value': 0,
      'room_id': garageId,
      'icon': 'door_sliding',
      'created_at': now,
    });

    await db.insert('devices', {
      'name': 'Security Camera',
      'name_ar': 'كاميرا المراقبة',
      'type': 'camera',
      'status': 1,
      'value': 0,
      'room_id': garageId,
      'icon': 'videocam',
      'created_at': now,
    });
  }

  // ============ عمليات المستخدمين ============

  /// إضافة مستخدم جديد
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  /// الحصول على مستخدم بواسطة اسم المستخدم وكلمة المرور
  Future<UserModel?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  /// الحصول على مستخدم بواسطة المعرف
  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  /// التحقق من وجود اسم مستخدم
  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<int> deleteUser(int id) async {
    // الحصول على نسخة من قاعدة البيانات
    final db = await instance.database;

    // تنفيذ عملية الحذف
    // نستخدم 'where' لتحديد السجل المطلوب
    // ونستخدم 'whereArgs' لتمرير القيم بشكل آمن لمنع SQL Injection
    return await db.delete(
      'users', // اسم الجدول
      where: 'id = ?', // الشرط
      whereArgs: [id], // قيم المعاملات
    );
  }

  /// الحصول على جميع المستخدمين
  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'created_at DESC');
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  // ============ عمليات الغرف ============

  /// إضافة غرفة جديدة
  Future<int> insertRoom(RoomModel room) async {
    final db = await database;
    return await db.insert('rooms', room.toMap());
  }

  /// تحديث غرفة
  Future<int> updateRoom(RoomModel room) async {
    final db = await database;
    return await db.update(
      'rooms',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  /// حذف غرفة
  Future<int> deleteRoom(int id) async {
    final db = await database;
    return await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
  }

  /// الحصول على جميع الغرف
  Future<List<RoomModel>> getAllRooms() async {
    final db = await database;
    final result = await db.query('rooms', orderBy: 'created_at DESC');
    return result.map((map) => RoomModel.fromMap(map)).toList();
  }

  /// الحصول على غرفة بواسطة المعرف
  Future<RoomModel?> getRoomById(int id) async {
    final db = await database;
    final result = await db.query('rooms', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return RoomModel.fromMap(result.first);
    }
    return null;
  }

  /// الحصول على عدد الأجهزة في غرفة
  Future<int> getDeviceCountInRoom(int roomId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM devices WHERE room_id = ?',
      [roomId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============ عمليات الأجهزة ============

  /// إضافة جهاز جديد
  Future<int> insertDevice(DeviceModel device) async {
    final db = await database;
    return await db.insert('devices', device.toMap());
  }

  /// تحديث جهاز
  Future<int> updateDevice(DeviceModel device) async {
    final db = await database;
    return await db.update(
      'devices',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  /// تحديث حالة جهاز (تشغيل/إيقاف)
  Future<int> updateDeviceStatus(int deviceId, int status) async {
    final db = await database;
    return await db.update(
      'devices',
      {'status': status},
      where: 'id = ?',
      whereArgs: [deviceId],
    );
  }

  /// تحديث قيمة جهاز (مثل شدة الإضاءة)
  Future<int> updateDeviceValue(int deviceId, int value) async {
    final db = await database;
    return await db.update(
      'devices',
      {'value': value},
      where: 'id = ?',
      whereArgs: [deviceId],
    );
  }

  /// حذف جهاز
  Future<int> deleteDevice(int id) async {
    final db = await database;
    return await db.delete('devices', where: 'id = ?', whereArgs: [id]);
  }

  /// الحصول على جميع الأجهزة
  Future<List<DeviceModel>> getAllDevices() async {
    final db = await database;
    final result = await db.query('devices', orderBy: 'created_at DESC');
    return result.map((map) => DeviceModel.fromMap(map)).toList();
  }

  /// الحصول على أجهزة غرفة معينة
  Future<List<DeviceModel>> getDevicesByRoom(int roomId) async {
    final db = await database;
    final result = await db.query(
      'devices',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => DeviceModel.fromMap(map)).toList();
  }

  /// الحصول على جهاز بواسطة المعرف
  Future<DeviceModel?> getDeviceById(int id) async {
    final db = await database;
    final result = await db.query('devices', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return DeviceModel.fromMap(result.first);
    }
    return null;
  }

  /// الحصول على عدد الأجهزة النشطة
  Future<int> getActiveDevicesCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM devices WHERE status = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============ عمليات سجل النشاط ============

  /// إضافة سجل نشاط
  Future<int> insertActivityLog(ActivityLogModel log) async {
    final db = await database;
    return await db.insert('activity_logs', log.toMap());
  }

  /// الحصول على جميع سجلات النشاط
  Future<List<ActivityLogModel>> getAllActivityLogs() async {
    final db = await database;
    final result = await db.query('activity_logs', orderBy: 'timestamp DESC');
    return result.map((map) => ActivityLogModel.fromMap(map)).toList();
  }

  /// الحصول على سجلات نشاط مستخدم معين
  Future<List<ActivityLogModel>> getActivityLogsByUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'activity_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => ActivityLogModel.fromMap(map)).toList();
  }

  /// الحصول على سجلات نشاط جهاز معين
  Future<List<ActivityLogModel>> getActivityLogsByDevice(int deviceId) async {
    final db = await database;
    final result = await db.query(
      'activity_logs',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => ActivityLogModel.fromMap(map)).toList();
  }

  /// الحصول على آخر N سجلات
  Future<List<ActivityLogModel>> getRecentActivityLogs(int limit) async {
    final db = await database;
    final result = await db.query(
      'activity_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => ActivityLogModel.fromMap(map)).toList();
  }

  /// حذف جميع سجلات النشاط
  Future<int> clearActivityLogs() async {
    final db = await database;
    return await db.delete('activity_logs');
  }

  // ============ إحصائيات ============

  /// الحصول على إحصائيات عامة
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    final roomsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM rooms'),
    );

    final devicesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM devices'),
    );

    final activeDevicesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM devices WHERE status = 1'),
    );

    final usersCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );

    final logsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM activity_logs'),
    );

    return {
      'rooms': roomsCount ?? 0,
      'devices': devicesCount ?? 0,
      'activeDevices': activeDevicesCount ?? 0,
      'users': usersCount ?? 0,
      'logs': logsCount ?? 0,
    };
  }

  // ============ إغلاق قاعدة البيانات ============
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
