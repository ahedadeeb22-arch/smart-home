import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../models/user_model.dart';
import '../widgets/class_card.dart'; // تأكد أن هذا الملف موجود
import '../controllers/admin_controller.dart'; // تأكد أن هذا الملف موجود

/// واجهة لوحة تحكم المدير
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // حقن المتحكم في الشاشة
    final controller = Get.put(AdminController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = controller.isArabic;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.cyberpunkGradient : null,
          color: isDark ? null : AppColors.lightBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // الهيدر العلوي
              _buildHeader(isArabic, isDark),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryCyan,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.loadAdminData,
                    color: AppColors.primaryCyan,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // القسم الأول: إحصائيات سريعة
                          _buildSectionTitle(
                            isArabic ? 'نظرة عامة' : 'Overview',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          // تم تمرير isDark هنا لإصلاح الألوان
                          _buildStatsGrid(controller, isArabic, isDark),

                          const SizedBox(height: 32),

                          // القسم الثاني: إدارة المستخدمين
                          _buildSectionTitle(
                            isArabic ? 'إدارة الحسابات' : 'User Management',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildUsersList(controller, isDark, isArabic),

                          const SizedBox(height: 32),

                          // القسم الثالث: إجراءات النظام المتقدمة
                          _buildSectionTitle(
                            isArabic ? 'أدوات النظام' : 'System Tools',
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          // تم تمرير isDark هنا لإصلاح الألوان
                          _buildAdvancedActions(controller, isDark, isArabic),

                          const SizedBox(height: 100), // مساحة للسكرول
                        ],
                      ),
                    ),
                  );
                }),
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
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2),
                ),
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
            isArabic ? 'لوحة تحكم المدير' : 'Admin Panel',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          const Icon(Icons.admin_panel_settings, color: AppColors.primaryCyan),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    AdminController controller,
    bool isArabic,
    bool isDark,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
          isArabic ? 'المستخدمين' : 'Users',
          '${controller.totalUsers.value}',
          Icons.people_rounded,
          AppColors.primaryBlue,
          isDark,
        ),
        _buildStatCard(
          isArabic ? 'السجلات' : 'Logs',
          '${controller.totalLogs.value}',
          Icons.history_edu_rounded,
          AppColors.primaryPurple,
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              // إصلاح اللون: أبيض في الليل، أسود في النهار
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              // إصلاح اللون: رمادي فاتح في الليل، رمادي غامق في النهار
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(
    AdminController controller,
    bool isDark,
    bool isArabic,
  ) {
    return Column(
      children: controller.users
          .map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              // إصلاح اللون
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            isArabic ? user.roleAr : user.roleEn,
                            style: TextStyle(
                              fontSize: 12,
                              // إصلاح اللون
                              color: isDark ? Colors.white38 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user.role != 'admin')
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _confirmDeleteUser(controller, user),
                      ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAdvancedActions(
    AdminController controller,
    bool isDark,
    bool isArabic,
  ) {
    return Column(
      children: [
        _buildActionTile(
          title: isArabic ? 'تفريغ السجلات' : 'Clear System Logs',
          subtitle: isArabic
              ? 'حذف كافة سجلات نشاط المستخدمين'
              : 'Permanently delete all activity history',
          icon: Icons.cleaning_services_rounded,
          color: Colors.orangeAccent,
          onTap: () => _confirmClearLogs(controller),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          title: isArabic ? 'تصدير البيانات' : 'Export System Data',
          subtitle: isArabic
              ? 'حفظ نسخة احتياطية من الإعدادات'
              : 'Create a backup of system settings',
          icon: Icons.cloud_download_rounded,
          color: AppColors.primaryCyan,
          onTap: () {}, // ميزة إضافية مستقبلية
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            // إصلاح اللون
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            // إصلاح اللون
            color: isDark ? Colors.white38 : Colors.black54,
            fontSize: 10,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          // إصلاح اللون
          color: isDark ? Colors.white24 : Colors.black26,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.primaryCyan : Colors.black87,
      ),
    );
  }

  // --- حوارات التأكيد (Confirmation Dialogs) ---

  void _confirmDeleteUser(AdminController controller, UserModel user) {
    Get.dialog(
      AlertDialog(
        backgroundColor:
            AppColors.darkSurface, // يمكنك تعديل لون الخلفية هنا إذا أردت
        title: Text(
          controller.isArabic ? 'تأكيد الحذف' : 'Confirm Delete',
          style: const TextStyle(
            color: Colors.white,
          ), // تأكد أن نصوص التنبيه مقروءة
        ),
        content: Text(
          controller.isArabic
              ? 'هل أنت متأكد من حذف حساب "${user.username}"؟'
              : 'Are you sure you want to delete user "${user.username}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(controller.isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteUser(user);
              Get.back();
            },
            child: Text(controller.isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearLogs(AdminController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          controller.isArabic ? 'مسح السجلات' : 'Clear Logs',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          controller.isArabic
              ? 'سيتم حذف كافة السجلات ولا يمكن استرجاعها. هل توافق؟'
              : 'All activity history will be lost. Proceed?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(controller.isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              controller.clearSystemLogs();
              Get.back();
            },
            child: Text(controller.isArabic ? 'تأكيد المسح' : 'Clear All'),
          ),
        ],
      ),
    );
  }
}
