import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ثيمات التطبيق - Cyberpunk / Glassmorphism
class AppTheme {
  AppTheme._();

  // ============ الوضع الليلي (Cyberpunk Theme) ============
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryCyan,
      scaffoldBackgroundColor: AppColors.darkBackground,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCyan,
        secondary: AppColors.primaryPink,
        tertiary: AppColors.primaryPurple,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.darkBackground,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryCyan),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleSmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyLarge: GoogleFonts.cairo(fontSize: 16, color: Colors.white),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, color: Colors.white70),
        bodySmall: GoogleFonts.cairo(fontSize: 12, color: Colors.white60),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryCyan,
        ),
      ),

      // Card Theme
      // cardTheme: CardTheme(
      //   color: AppColors.darkCard.withOpacity(0.6),
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20),
      //     side: BorderSide(
      //       color: AppColors.primaryCyan.withOpacity(0.2),
      //       width: 1,
      //     ),
      //   ),
      // ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.primaryCyan.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryCyan.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryCyan.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.cairo(color: Colors.white70),
        hintStyle: GoogleFonts.cairo(color: Colors.white38),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCyan,
          foregroundColor: AppColors.darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryCyan,
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.primaryCyan, size: 24),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface.withOpacity(0.8),
        selectedItemColor: AppColors.primaryCyan,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryCyan;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryCyan.withOpacity(0.3);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryCyan,
        inactiveTrackColor: AppColors.primaryCyan.withOpacity(0.2),
        thumbColor: AppColors.primaryCyan,
        overlayColor: AppColors.primaryCyan.withOpacity(0.1),
        valueIndicatorColor: AppColors.primaryCyan,
        valueIndicatorTextStyle: GoogleFonts.cairo(
          color: AppColors.darkBackground,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Dialog Theme
      // dialogTheme: DialogTheme(
      //   backgroundColor: AppColors.darkSurface,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20),
      //     side: BorderSide(color: AppColors.primaryCyan.withValues(15)),
      //   ),
      //   titleTextStyle: GoogleFonts.cairo(
      //     fontSize: 20,
      //     fontWeight: FontWeight.bold,
      //     color: Colors.white,
      //   ),
      //   contentTextStyle: GoogleFonts.cairo(
      //     fontSize: 14,
      //     color: Colors.white70,
      //   ),
      // ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: AppColors.darkBackground,
        elevation: 0,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.primaryCyan.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }

  // ============ الوضع النهاري (Light Glassmorphism Theme) ============
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.lightBackground,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryPurple,
        tertiary: AppColors.primaryCyan,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1A1A2E),
        onError: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: const Color(0xFF1A1A2E),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1A2E),
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1A2E),
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1A2E),
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
        headlineSmall: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1A2E),
        ),
        titleSmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF4B5563),
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          color: const Color(0xFF1A1A2E),
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          color: const Color(0xFF4B5563),
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          color: const Color(0xFF6B7280),
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
        ),
      ),

      // Card Theme
      // cardTheme: CardTheme(
      //   color: Colors.white.withOpacity(0.8),
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20),
      //     side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
      //   ),
      // ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.cairo(color: const Color(0xFF4B5563)),
        hintStyle: GoogleFonts.cairo(color: const Color(0xFF9CA3AF)),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.primaryBlue, size: 24),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.9),
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: const Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue.withOpacity(0.3);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryBlue,
        inactiveTrackColor: AppColors.primaryBlue.withOpacity(0.2),
        thumbColor: AppColors.primaryBlue,
        overlayColor: AppColors.primaryBlue.withOpacity(0.1),
        valueIndicatorColor: AppColors.primaryBlue,
        valueIndicatorTextStyle: GoogleFonts.cairo(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Dialog Theme
      // dialogTheme: DialogTheme(
      //   backgroundColor: Colors.white,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //   titleTextStyle: GoogleFonts.cairo(
      //     fontSize: 20,
      //     fontWeight: FontWeight.bold,
      //     color: const Color(0xFF1A1A2E),
      //   ),
      //   contentTextStyle: GoogleFonts.cairo(
      //     fontSize: 14,
      //     color: const Color(0xFF4B5563),
      //   ),
      // ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }
}
