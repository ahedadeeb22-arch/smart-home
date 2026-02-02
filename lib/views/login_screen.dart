import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';
import '../routes/app_routes.dart';
import '../widgets/class_card.dart';

/// شاشة تسجيل الدخول
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.cyberpunkGradient : null,
          color: isDark ? null : AppColors.lightBackground,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.08),

                  // الأيقونة والعنوان
                  _buildHeader(isDark, isArabic),

                  const SizedBox(height: 50),

                  // حقول الإدخال
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // حقل اسم المستخدم
                        _buildTextField(
                          controller: controller.usernameController,
                          label: isArabic ? 'اسم المستخدم' : 'Username',
                          icon: Icons.person_outline,
                          validator: controller.validateUsername,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 20),

                        // حقل كلمة المرور
                        Obx(() => _buildTextField(
                              controller: controller.passwordController,
                              label: isArabic ? 'كلمة المرور' : 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              showPassword: controller.showPassword.value,
                              onTogglePassword: controller.toggleShowPassword,
                              validator: controller.validatePassword,
                              isDark: isDark,
                            )),

                        const SizedBox(height: 30),

                        // زر تسجيل الدخول
                        Obx(() => GlassButton(
                              width: double.infinity,
                              isLoading: controller.isLoading.value,
                              onPressed: controller.login,
                              child: Text(
                                isArabic ? 'تسجيل الدخول' : 'Login',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // رابط التسجيل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isArabic ? 'ليس لديك حساب؟' : "Don't have an account?",
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.clearFields();
                          Get.toNamed(AppRoutes.register);
                        },
                        child: Text(
                          isArabic ? 'إنشاء حساب' : 'Register',
                          style: TextStyle(
                            color: AppColors.primaryCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // معلومات الدخول الافتراضية
                  _buildDefaultCredentials(isDark, isArabic),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isArabic) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCyan.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.home_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isArabic ? 'مرحباً بعودتك!' : 'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.darkBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isArabic
              ? 'سجل دخولك للتحكم بمنزلك الذكي'
              : 'Login to control your smart home',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !showPassword,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryCyan,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
                onPressed: onTogglePassword,
              )
            : null,
      ),
    );
  }

  Widget _buildDefaultCredentials(bool isDark, bool isArabic) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark
          ? AppColors.primaryCyan.withOpacity(0.1)
          : Colors.blue.withOpacity(0.1),
      borderColor: AppColors.primaryCyan.withOpacity(0.3),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.primaryCyan,
              ),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'بيانات الدخول الافتراضية:' : 'Default credentials:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCredentialBox(
                isArabic ? 'مدير' : 'Admin',
                'admin / admin123',
                isDark,
              ),
              _buildCredentialBox(
                isArabic ? 'مستخدم' : 'User',
                'user / user123',
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialBox(String title, String credentials, bool isDark) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          credentials,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white38 : Colors.grey,
          ),
        ),
      ],
    );
  }
}
