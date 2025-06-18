import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_sizes.dart';

/// Lớp quản lý theme của ứng dụng
/// Cung cấp các theme mặc định và các phương thức để tùy chỉnh theme
class AppTheme {
  // Theme sáng mặc định
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      useMaterial3: true,
      // Thiết lập typography cho toàn bộ ứng dụng
      textTheme: _buildTextTheme(),
      // Thiết lập style cho AppBar
      appBarTheme: _buildAppBarTheme(),
      // Thiết lập style cho Button
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      // Thiết lập style cho Dialog
      dialogTheme: _buildDialogTheme(),
      // Thiết lập style cho Input
      inputDecorationTheme: _buildInputDecorationTheme(),
    );
  }

  // Theme tối (có thể thêm sau)
  static ThemeData get darkTheme {
    // TODO: Implement dark theme
    return lightTheme;
  }

  // Xây dựng text theme với các kích thước font từ AppTextSizes
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: AppTextSizes.headingLarge,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontSize: AppTextSizes.headingMedium,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontSize: AppTextSizes.headingSmall,
        fontWeight: FontWeight.bold,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: AppTextSizes.headingLarge,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: AppTextSizes.headingMedium,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: AppTextSizes.headingSmall,
        fontWeight: FontWeight.w600,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: AppTextSizes.headingSmall,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: AppTextSizes.bodyLarge,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontSize: AppTextSizes.bodyMedium,
        fontWeight: FontWeight.w600,
      ),

      // Body styles
      bodyLarge: TextStyle(fontSize: AppTextSizes.bodyLarge),
      bodyMedium: TextStyle(fontSize: AppTextSizes.bodyMedium),
      bodySmall: TextStyle(fontSize: AppTextSizes.bodySmall),

      // Label styles
      labelLarge: TextStyle(
        fontSize: AppTextSizes.buttonText,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontSize: AppTextSizes.labelText,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: AppTextSizes.captionText,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Xây dựng AppBar theme
  static AppBarTheme _buildAppBarTheme() {
    return const AppBarTheme(
      titleTextStyle: TextStyle(
        fontSize: AppTextSizes.headingSmall,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: true,
    );
  }

  // Xây dựng ElevatedButton theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: AppTextSizes.buttonText,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTextSizes.spacingMedium,
          vertical: AppTextSizes.spacingSmall,
        ),
      ),
    );
  }

  // Xây dựng TextButton theme
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: AppTextSizes.buttonText,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTextSizes.spacingMedium,
          vertical: AppTextSizes.spacingSmall,
        ),
      ),
    );
  }

  // Xây dựng Dialog theme
  static DialogThemeData _buildDialogTheme() {
    return DialogThemeData(
      titleTextStyle: const TextStyle(
        fontSize: AppTextSizes.dialogTitle,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: AppTextSizes.dialogContent,
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTextSizes.spacingSmall),
      ),
    );
  }

  // Xây dựng InputDecoration theme
  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      hintStyle: TextStyle(
        fontSize: AppTextSizes.inputText,
        color: AppColors.textPlaceholder,
      ),
      labelStyle: TextStyle(
        fontSize: AppTextSizes.labelText,
        color: AppColors.textSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTextSizes.spacingMedium,
        vertical: AppTextSizes.spacingSmall,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTextSizes.spacingTiny),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTextSizes.spacingTiny),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
