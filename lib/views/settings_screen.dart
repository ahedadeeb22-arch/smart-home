import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/room_controller.dart';
import '../controllers/device_controller.dart';
import '../core/constants/app_colors.dart';
import '../models/room_model.dart';
import '../models/device_model.dart';
import '../widgets/class_card.dart';
import '../widgets/room_card.dart';
import '../widgets/device_tile.dart';
import '../core/services/storage_service.dart';

/// شاشة الإعدادات وإدارة النظام
/// تتيح للأدمن التحكم في كامل خصائص التطبيق والغرف والأجهزة
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب المتحكمات اللازمة لإدارة الحالة
    final controller = Get.find<SettingsController>();
    final homeController = Get.find<HomeController>();

    final deviceController = Get.find<DeviceController>();
  
  final roomController = Get.isRegistered<RoomController>() 
      ? Get.find<RoomController>() 
      : Get.put(RoomController());

  final storage = Get.find<StorageService>();
  final isArabic = storage.isArabic;
  final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // استخدام التدرج اللوني للثيم المظلم أو خلفية فاتحة للثيم النهاري
          gradient: isDark ? AppColors.cyberpunkGradient : null,
          color: isDark ? null : AppColors.lightBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // الهيدر العلوي مع زر الرجوع
              _buildHeader(isArabic, isDark),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // قسم معلومات المستخدم (الأدمن)
                      _buildProfileSection(controller, isDark, isArabic),

                      const SizedBox(height: 24),

                      // إعدادات المظهر واللغة الأساسية
                      _buildSectionTitle(
                          isArabic ? 'إعدادات التطبيق' : 'App Settings',
                          isDark),
                      const SizedBox(height: 12),
                      _buildGeneralSettings(controller, isDark, isArabic),

                      const SizedBox(height: 32),

                      // أدوات الإدارة المتقدمة - تظهر فقط للأدمن
                      if (controller.isAdmin) ...[
                        _buildAdminManagementHeader(
                          title: isArabic ? 'إدارة الغرف' : 'Room Management',
                          onAdd: () => _showAddRoomDialog(context,
                              roomController, isDark, isArabic, homeController),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildRoomList(context,
                            homeController, roomController, isDark, isArabic),
                        const SizedBox(height: 32),
                        _buildAdminManagementHeader(
                          title:
                              isArabic ? 'إدارة الأجهزة' : 'Device Management',
                          onAdd: () => _showAddDeviceDialog(
                              context,
                              deviceController,
                              homeController,
                              isDark,
                              isArabic),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildDeviceList(
                            homeController, deviceController, isDark, isArabic),
                      ],

                      const SizedBox(height: 40),

                      // زر تسجيل الخروج بتصميم بارز
                      _buildLogoutButton(controller, isArabic),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArabic, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                color: isDark ? Colors.white70 : Colors.black87,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            isArabic ? 'إعدادات النظام' : 'System Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
      SettingsController controller, bool isDark, bool isArabic) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(Icons.admin_panel_settings,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.username.value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    )),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.roleDisplayName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings(
      SettingsController controller, bool isDark, bool isArabic) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Obx(() => ListTile(
                leading: Icon(
                  controller.isDarkMode.value
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: AppColors.primaryCyan,
                ),
                title: Text(
                  isArabic ? 'الوضع الليلي' : 'Dark Mode',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                trailing: Switch(
                  value: controller.isDarkMode.value,
                  onChanged: (_) => controller.toggleDarkMode(),
                  activeColor: AppColors.primaryCyan,
                ),
              )),
          Divider(
              color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1),
              height: 1),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primaryPurple),
            title: Text(
              isArabic ? 'لغة التطبيق' : 'App Language',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            trailing: Obx(() => Text(
                  controller.language.value == 'ar' ? 'العربية' : 'English',
                  style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.bold),
                )),
            onTap: () => controller.toggleLanguage(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminManagementHeader(
      {required String title,
      required VoidCallback onAdd,
      required bool isDark}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title, isDark),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.add, size: 16, color: AppColors.primaryCyan),
                const SizedBox(width: 4),
                Text(
                  Get.find<SettingsController>().isArabic ? 'إضافة' : 'Add',
                  style: const TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomList(BuildContext context,HomeController home, RoomController roomCtrl,
      bool isDark, bool isArabic) {
    return Obx(() => Column(
          children: home.rooms
              .map((room) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RoomCardCompact(
                      room: room,
                      deviceCount: home.getDeviceCountForRoom(room.id!),
                      showActions: true,
                      onEdit: () => _showEditRoomDialog(context,
                          room, roomCtrl, isDark, isArabic, home),
                      onDelete: () => _showDeleteConfirmation(
                        title: isArabic ? 'حذف الغرفة' : 'Delete Room',
                        message: isArabic
                            ? 'هل أنت متأكد من حذف هذه الغرفة وكل أجهزتها؟'
                            : 'Delete this room and all its devices?',
                        onConfirm: () async {
                          await roomCtrl.deleteRoom(room.id!);
                          home.refreshData();
                        },
                        isDark: isDark,
                        isArabic: isArabic,
                      ),
                    ),
                  ))
              .toList(),
        ));
  }

  Widget _buildDeviceList(HomeController home, DeviceController devCtrl,
      bool isDark, bool isArabic) {
    return Obx(() => Column(
          children: home.allDevices
              .map((device) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DeviceTileCompact(
                      device: device,
                      onToggle: () => home.toggleDevice(device),
                      onTap: () => _showEditDeviceOptions(
                          device, devCtrl, isDark, isArabic, home),
                    ),
                  ))
              .toList(),
        ));
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget _buildLogoutButton(SettingsController controller, bool isArabic) {
    return GlassButton(
      color: Colors.redAccent,
      onPressed: () => controller.logout(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            isArabic ? 'تسجيل الخروج' : 'Logout',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- الحوارات المنبثقة (Dialogs) لإدارة البيانات ---
void _showAddRoomDialog(BuildContext context, RoomController ctrl,
      bool isDark, bool isArabic, HomeController home) {
    
    // 1. تفريغ الحقول واختيار القيم الافتراضية قبل فتح النافذة
    ctrl.clearFields();

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isArabic ? 'إضافة غرفة جديدة' : 'Add New Room'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // تحديد عرض مناسب
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // حقل الاسم بالإنجليزية
                TextField(
                  controller: ctrl.nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: isArabic ? 'اسم الغرفة (EN)' : 'Room Name (EN)',
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 12),
                // حقل الاسم بالعربية
                TextField(
                  controller: ctrl.nameArController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: isArabic ? 'اسم الغرفة (AR)' : 'Room Name (AR)',
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 20),

                // قسم اختيار الأيقونة
                Text(
                  isArabic ? 'اختر أيقونة' : 'Select Icon',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: Obx(() {
                    // الوصول لـ .value هنا يضمن أن Obx يراقب التغيير
                    final currentIcon = ctrl.selectedIcon.value;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: RoomIcons.icons.length,
                      itemBuilder: (context, index) {
                        final iconData = RoomIcons.icons[index];
                        final isSelected = currentIcon == iconData['name'];
                        
                        return GestureDetector(
                          onTap: () => ctrl.selectedIcon.value = iconData['name'],
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10, bottom: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryCyan.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryCyan
                                    : Colors.grey.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              iconData['icon'],
                              color: isSelected ? AppColors.primaryCyan : Colors.grey,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // قسم اختيار اللون
                Text(
                  isArabic ? 'اختر لوناً' : 'Select Color',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: Obx(() {
                    // الوصول لـ .value هنا ضروري لمنع خطأ GetX
                    final currentColor = ctrl.selectedColor.value;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: RoomColors.colors.length,
                      itemBuilder: (context, index) {
                        final colorHex = RoomColors.colors[index];
                        final displayColor = RoomColors.hexToColor(colorHex);
                        final isSelected = currentColor == colorHex;

                        return GestureDetector(
                          onTap: () => ctrl.selectedColor.value = colorHex,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12, bottom: 5),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: displayColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? Colors.white : Colors.black)
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: displayColor.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCyan.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: ctrl.isLoading.value 
              ? null 
              : () async {
                  if (await ctrl.addRoom()) {
                    Get.back();
                    home.refreshData(); // تحديث القائمة الرئيسية
                  }
                },
            child: ctrl.isLoading.value
              ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  isArabic ? 'إضافة' : 'Add',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
          )),
        ],
      ),
      barrierDismissible: false, // منع الإغلاق عند الضغط خارج النافذة أثناء المعالجة
    );
  }

void _showEditRoomDialog(BuildContext context, RoomModel room, 
      RoomController ctrl, bool isDark, bool isArabic, HomeController home) {
    
    // 1. تعبئة البيانات الحالية للغرفة في الحقول
    ctrl.prepareForEdit(room);

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isArabic ? 'تعديل الغرفة' : 'Edit Room'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: ctrl.nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الاسم (EN)' : 'Name (EN)',
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl.nameArController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الاسم (AR)' : 'Name (AR)',
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 20),

                // قسم اختيار الأيقونة المحدث
                _buildSectionLabel(isArabic ? 'الأيقونة' : 'Icon', isDark),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: Obx(() {
                    final currentIcon = ctrl.selectedIcon.value;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: RoomIcons.icons.length,
                      itemBuilder: (context, index) {
                        final iconData = RoomIcons.icons[index];
                        final isSelected = currentIcon == iconData['name'];
                        return _buildSelectableItem(
                          icon: iconData['icon'],
                          isSelected: isSelected,
                          onTap: () => ctrl.selectedIcon.value = iconData['name'],
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // قسم اختيار اللون باستخدام RoomColors
                _buildSectionLabel(isArabic ? 'اللون' : 'Color', isDark),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: Obx(() {
                    final currentColor = ctrl.selectedColor.value;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: RoomColors.colors.length,
                      itemBuilder: (context, index) {
                        final colorHex = RoomColors.colors[index];
                        final isSelected = currentColor == colorHex;
                        return _buildColorCircle(
                          colorHex: colorHex,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () => ctrl.selectedColor.value = colorHex,
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCyan),
            onPressed: ctrl.isLoading.value 
              ? null 
              : () async {
                  if (await ctrl.updateRoom(room)) {
                    Get.back();
                    home.refreshData(); // تحديث الواجهة الرئيسية فوراً
                    Get.snackbar(isArabic ? 'تم' : 'Success', isArabic ? 'تم تحديث الغرفة' : 'Room updated');
                  }
                },
            child: ctrl.isLoading.value
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isArabic ? 'حفظ التعديلات' : 'Save Changes', style: const TextStyle(color: Colors.white)),
          )),
        ],
      ),
    );
  }

  // --- دوال بناء صغيرة لتجنب تكرار الكود ---

  Widget _buildSectionLabel(String text, bool isDark) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54));
  }

  Widget _buildSelectableItem({required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCyan.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? AppColors.primaryCyan : Colors.grey.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isSelected ? AppColors.primaryCyan : Colors.grey),
      ),
    );
  }

  Widget _buildColorCircle({required String colorHex, required bool isSelected, required bool isDark, required VoidCallback onTap}) {
    final Color displayColor = RoomColors.hexToColor(colorHex);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.transparent, width: 3),
          boxShadow: [if (isSelected) BoxShadow(color: displayColor.withOpacity(0.6), blurRadius: 10, spreadRadius: 2)],
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
      ),
    );
  }
  // void _showEditRoomDialog(RoomModel room, RoomController ctrl, bool isDark,
  //     bool isArabic, HomeController home) {
  //   ctrl.prepareForEdit(room);
  //   Get.dialog(
  //     AlertDialog(
  //       backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
  //       title: Text(isArabic ? 'تعديل الغرفة' : 'Edit Room'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(
  //               controller: ctrl.nameController,
  //               decoration: const InputDecoration(labelText: 'Name (EN)')),
  //           const SizedBox(height: 12),
  //           TextField(
  //               controller: ctrl.nameArController,
  //               decoration: const InputDecoration(labelText: 'Name (AR)')),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //             onPressed: () => Get.back(),
  //             child: Text(isArabic ? 'إلغاء' : 'Cancel')),
  //         ElevatedButton(
  //           onPressed: () async {
  //             if (await ctrl.updateRoom(room)) {
  //               Get.back();
  //               home.refreshData();
  //             }
  //           },
  //           child: Text(isArabic ? 'حفظ' : 'Save'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showAddDeviceDialog(BuildContext context, DeviceController ctrl,
      HomeController home, bool isDark, bool isArabic) {
    ctrl.clearFields();
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(isArabic ? 'إضافة جهاز جديد' : 'Add Device'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                        labelText: isArabic ? 'اختر الغرفة' : 'Select Room'),
                    items: home.rooms
                        .map((r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(r.getLocalizedName(isArabic))))
                        .toList(),
                    onChanged: (val) => ctrl.selectedRoomId.value = val ?? 0,
                  )),
              const SizedBox(height: 12),
              TextField(
                  controller: ctrl.nameController,
                  decoration:
                      const InputDecoration(labelText: 'Device Name (EN)')),
              const SizedBox(height: 12),
              TextField(
                  controller: ctrl.nameArController,
                  decoration:
                      const InputDecoration(labelText: 'Device Name (AR)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (await ctrl.addDevice(ctrl.selectedRoomId.value)) {
                Get.back();
                home.refreshData();
              }
            },
            child: Text(isArabic ? 'إضافة' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDeviceOptions(DeviceModel device, DeviceController ctrl,
      bool isDark, bool isArabic, HomeController home) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(isArabic ? 'حذف الجهاز' : 'Delete Device',
                  style: const TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(
                  title: isArabic ? 'حذف الجهاز' : 'Delete Device',
                  message: isArabic
                      ? 'هل أنت متأكد من حذف هذا الجهاز؟'
                      : 'Are you sure?',
                  onConfirm: () async {
                    await ctrl.deleteDevice(device.id!);
                    home.refreshData();
                  },
                  isDark: isDark,
                  isArabic: isArabic,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      {required String title,
      required String message,
      required VoidCallback onConfirm,
      required bool isDark,
      required bool isArabic}) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onConfirm();
              Get.back();
            },
            child: Text(isArabic ? 'حذف' : 'Delete',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
