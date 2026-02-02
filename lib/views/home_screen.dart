import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';
import '../routes/app_routes.dart';
import '../widgets/room_card.dart';
import '../widgets/class_card.dart';
import '../controllers/room_controller.dart';
import '../models/room_model.dart';

/// الشاشة الرئيسية - Dashboard
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final storage = Get.find<StorageService>();

    final roomController = Get.find<RoomController>();
    final isArabic = storage.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.cyberpunkGradient : null,
          color: isDark ? null : AppColors.lightBackground,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshData,
            color: AppColors.primaryCyan,
            child: CustomScrollView(
              slivers: [
                // الهيدر
                SliverToBoxAdapter(
                  child: _buildHeader(controller, isDark, isArabic),
                ),

                // الإحصائيات
                SliverToBoxAdapter(
                  child: _buildStatistics(controller, isDark, isArabic),
                ),

                // عنوان الغرف
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  ),
                ),

                // شبكة الغرف
                Obx(() => controller.isLoading.value
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryCyan,
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // بطاقة إضافة غرفة (للأدمن فقط)
                              if (controller.isAdmin &&
                                  index == controller.rooms.length) {
                                return AddRoomCard(
                                  onTap: () => _showAddRoomDialog(
                                      context,
                                      roomController,
                                      isDark,
                                      isArabic,
                                      controller),
                                );
                              }

                              final room = controller.rooms[index];
                              final deviceCount =
                                  controller.getDeviceCountForRoom(room.id!);
                              final activeCount = controller
                                  .getActiveDeviceCountForRoom(room.id!);

                              return RoomCard(
                                  room: room,
                                  deviceCount: deviceCount,
                                  activeDeviceCount: activeCount,
                                  onTap: () {
                                    final route =
                                        AppRoutes.getRoomRoute(room.id!);
                                    Get.toNamed(route);
                                  });
                            },
                            childCount: controller.rooms.length +
                                (controller.isAdmin ? 1 : 0),
                          ),
                        ),
                      )),

                // السجلات الأخيرة
                SliverToBoxAdapter(
                  child: _buildRecentLogs(controller, isDark, isArabic),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),

      // شريط التنقل السفلي
      bottomNavigationBar: _buildBottomNav(controller, isDark, isArabic),
    );
  }

  Widget _buildHeader(HomeController controller, bool isDark, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // زر السجلات
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.activityLogs),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Icon(
                Icons.history,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // زر الإعدادات
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.settings),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Icon(
                Icons.settings,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(
      HomeController controller, bool isDark, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.meeting_room,
                  value: '${controller.totalRooms}',
                  label: isArabic ? 'غرف' : 'Rooms',
                  color: AppColors.primaryCyan,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.devices,
                  value: '${controller.totalDevices}',
                  label: isArabic ? 'أجهزة' : 'Devices',
                  color: AppColors.primaryPurple,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.power,
                  value: '${controller.activeDevices}',
                  label: isArabic ? 'نشط' : 'Active',
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogs(
      HomeController controller, bool isDark, bool isArabic) {
    return Obx(() {
      if (controller.recentLogs.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'النشاط الأخير' : 'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.activityLogs),
                  child: Text(
                    isArabic ? 'عرض الكل' : 'View All',
                    style: TextStyle(
                      color: AppColors.primaryCyan,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: controller.recentLogs.take(5).map((log) {
                  final isFirst = controller.recentLogs.first == log;
                  return Column(
                    children: [
                      if (!isFirst)
                        Divider(
                          color: isDark
                              ? Colors.white12
                              : Colors.grey.withOpacity(0.2),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryCyan.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.history,
                                size: 18,
                                color: AppColors.primaryCyan,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.getLocalizedAction(isArabic),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    log.getRelativeTime(isArabic),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          isDark ? Colors.white38 : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomNav(
      HomeController controller, bool isDark, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withOpacity(0.9) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: isArabic ? 'الرئيسية' : 'Home',
                    isSelected: controller.currentNavIndex.value == 0,
                    onTap: () {
                      controller.changeNavIndex(0);
                      Get.toNamed(AppRoutes.home);
                    },
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: Icons.admin_panel_settings,
                    label: isArabic ? 'لوحة التحكم' : 'Admin Panel',
                    isSelected: controller.currentNavIndex.value == 1,
                    onTap: () {
                      controller.changeNavIndex(1);
                      Get.toNamed(AppRoutes.adminPanel);
                    },
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: Icons.settings,
                    label: isArabic ? 'الإعدادات' : 'Settings',
                    isSelected: controller.currentNavIndex.value == 2,
                    onTap: () {
                      controller.changeNavIndex(2);
                      Get.toNamed(AppRoutes.settings);
                    },
                    isDark: isDark,
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryCyan.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryCyan
                  : (isDark ? Colors.white38 : Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryCyan
                    : (isDark ? Colors.white38 : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: isArabic ? 'اسم الغرفة (EN)' : 'Room Name (EN)',
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 12),
                // حقل الاسم بالعربية
                TextField(
                  controller: ctrl.nameArController,
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87),
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
                          onTap: () =>
                              ctrl.selectedIcon.value = iconData['name'],
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
                              color: isSelected
                                  ? AppColors.primaryCyan
                                  : Colors.grey,
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
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isArabic ? 'إضافة' : 'Add',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              )),
        ],
      ),
      barrierDismissible:
          false, // منع الإغلاق عند الضغط خارج النافذة أثناء المعالجة
    );
  }
}
