import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/database/database_helper.dart';
import '../core/services/storage_service.dart';
import '../models/activity_log_model.dart';
import '../widgets/class_card.dart';

/// شاشة سجل النشاط
class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<ActivityLogModel> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _db.getAllActivityLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.cyberpunkGradient : null,
          color: isDark ? null : AppColors.lightBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // الهيدر
              _buildHeader(isDark, isArabic),

              // قائمة السجلات
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryCyan,
                        ),
                      )
                    : _logs.isEmpty
                        ? _buildEmptyState(isDark, isArabic)
                        : RefreshIndicator(
                            onRefresh: _loadLogs,
                            color: AppColors.primaryCyan,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                final showDateHeader = index == 0 ||
                                    !_isSameDay(_logs[index - 1].timestamp, log.timestamp);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showDateHeader) _buildDateHeader(log.timestamp, isDark, isArabic),
                                    _buildLogTile(log, isDark, isArabic),
                                  ],
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isArabic) {
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
          Expanded(
            child: Text(
              isArabic ? 'سجل النشاط' : 'Activity Log',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (_logs.isNotEmpty && storage.isAdmin)
            IconButton(
              onPressed: () => _showClearConfirmation(isDark, isArabic),
              icon: Icon(
                Icons.delete_sweep,
                color: isDark ? Colors.white60 : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  StorageService get storage => Get.find<StorageService>();

  Widget _buildEmptyState(bool isDark, bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا يوجد سجلات بعد' : 'No activity logs yet',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'ستظهر هنا جميع أنشطة التحكم بالأجهزة'
                : 'All device control activities will appear here',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, bool isDark, bool isArabic) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (logDate == today) {
      dateText = isArabic ? 'اليوم' : 'Today';
    } else if (logDate == yesterday) {
      dateText = isArabic ? 'أمس' : 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryCyan,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTile(ActivityLogModel log, bool isDark, bool isArabic) {
    final isOn = log.action.contains('turned on') || (log.actionAr?.contains('تشغيل') ?? false);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // أيقونة النشاط
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isOn ? AppColors.success : AppColors.warning).withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isOn ? Icons.power : Icons.power_off,
                color: isOn ? AppColors.success : AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // تفاصيل النشاط
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.getLocalizedAction(isArabic),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        log.formattedTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        log.getRelativeTime(isArabic),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showClearConfirmation(bool isDark, bool isArabic) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(isArabic ? 'مسح السجلات' : 'Clear Logs'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من مسح جميع السجلات؟ لا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to clear all logs? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _db.clearActivityLogs();
              Get.back();
              _loadLogs();
              Get.snackbar(
                isArabic ? 'تم' : 'Done',
                isArabic ? 'تم مسح جميع السجلات' : 'All logs have been cleared',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withOpacity(0.8),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              isArabic ? 'مسح' : 'Clear',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}