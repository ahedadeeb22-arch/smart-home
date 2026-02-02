import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';
import '../widgets/class_card.dart';

/// شاشة التسجيل
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final storage = Get.find<StorageService>();
    final isArabic = storage.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              key: controller.registerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // زر الرجوع
                  Align(
                    alignment: isArabic ? Alignment.topRight : Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // العنوان
                  _buildHeader(isDark, isArabic),

                  const SizedBox(height: 40),

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

                        const SizedBox(height: 20),

                        // حقل تأكيد كلمة المرور
                        Obx(() => _buildTextField(
                              controller: controller.confirmPasswordController,
                              label: isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              showPassword: controller.showConfirmPassword.value,
                              onTogglePassword: controller.toggleShowConfirmPassword,
                              validator: controller.validateConfirmPassword,
                              isDark: isDark,
                            )),

                        const SizedBox(height: 24),

                        // اختيار الدور
                        _buildRoleSelector(controller, isDark, isArabic),

                        const SizedBox(height: 30),

                        // زر التسجيل
                        Obx(() => GlassButton(
                              width: double.infinity,
                              isLoading: controller.isLoading.value,
                              onPressed: controller.register,
                              child: Text(
                                isArabic ? 'إنشاء حساب' : 'Register',
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

                  // رابط تسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isArabic ? 'لديك حساب بالفعل؟' : 'Already have an account?',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.clearFields();
                          Get.back();
                        },
                        child: Text(
                          isArabic ? 'تسجيل الدخول' : 'Login',
                          style: TextStyle(
                            color: AppColors.primaryCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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
          width: 80,
          height: 80,
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
            Icons.person_add_outlined,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isArabic ? 'إنشاء حساب جديد' : 'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.darkBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isArabic ? 'انضم إلينا للتحكم بمنزلك الذكي' : 'Join us to control your smart home',
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

  Widget _buildRoleSelector(AuthController controller, bool isDark, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'اختر الدور' : 'Select Role',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: [
                Expanded(
                  child: _buildRoleOption(
                    role: 'member',
                    label: isArabic ? 'عضو' : 'Member',
                    icon: Icons.person_outline,
                    isSelected: controller.selectedRole.value == 'member',
                    onTap: () => controller.setRole('member'),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRoleOption(
                    role: 'admin',
                    label: isArabic ? 'مدير' : 'Admin',
                    icon: Icons.admin_panel_settings_outlined,
                    isSelected: controller.selectedRole.value == 'admin',
                    onTap: () => controller.setRole('admin'),
                    isDark: isDark,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildRoleOption({
    required String role,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryCyan.withOpacity(0.2)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryCyan
                : (isDark ? Colors.white24 : Colors.grey.withOpacity(0.3)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primaryCyan
                  : (isDark ? Colors.white60 : Colors.grey),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryCyan
                    : (isDark ? Colors.white60 : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}