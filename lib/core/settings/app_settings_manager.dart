import 'package:flutter/material.dart';
import '../constants/app_strings.dart';

/// Enum định nghĩa các kích thước font chữ có thể chọn
enum FontSizeOption {
  small(0.85, AppStrings.fontSizeSmall),
  medium(1.0, AppStrings.fontSizeMedium),
  large(1.15, AppStrings.fontSizeLarge),
  extraLarge(1.3, AppStrings.fontSizeExtraLarge);

  final double scale;
  final String label;

  const FontSizeOption(this.scale, this.label);
}

/// Lớp quản lý cài đặt ứng dụng
/// Sử dụng ChangeNotifier để thông báo khi cài đặt thay đổi
class AppSettingsManager extends ChangeNotifier {
  // Singleton pattern
  static final AppSettingsManager _instance = AppSettingsManager._internal();

  factory AppSettingsManager() {
    return _instance;
  }

  AppSettingsManager._internal();

  // Cài đặt kích thước font chữ
  FontSizeOption _fontSizeOption = FontSizeOption.medium;

  // Getter cho kích thước font chữ hiện tại
  FontSizeOption get fontSizeOption => _fontSizeOption;

  // Getter cho hệ số tỷ lệ font chữ
  double get fontSizeScale => _fontSizeOption.scale;

  // Setter cho kích thước font chữ
  set fontSizeOption(FontSizeOption option) {
    if (_fontSizeOption != option) {
      _fontSizeOption = option;
      notifyListeners();
    }
  }

  // Phương thức để áp dụng cài đặt font size vào TextTheme
  TextTheme applyFontSizeToTheme(TextTheme baseTheme) {
    if (_fontSizeOption == FontSizeOption.medium) {
      return baseTheme; // Không cần điều chỉnh nếu là kích thước mặc định
    }

    return baseTheme.copyWith(
      displayLarge: _scaledTextStyle(baseTheme.displayLarge),
      displayMedium: _scaledTextStyle(baseTheme.displayMedium),
      displaySmall: _scaledTextStyle(baseTheme.displaySmall),
      headlineLarge: _scaledTextStyle(baseTheme.headlineLarge),
      headlineMedium: _scaledTextStyle(baseTheme.headlineMedium),
      headlineSmall: _scaledTextStyle(baseTheme.headlineSmall),
      titleLarge: _scaledTextStyle(baseTheme.titleLarge),
      titleMedium: _scaledTextStyle(baseTheme.titleMedium),
      titleSmall: _scaledTextStyle(baseTheme.titleSmall),
      bodyLarge: _scaledTextStyle(baseTheme.bodyLarge),
      bodyMedium: _scaledTextStyle(baseTheme.bodyMedium),
      bodySmall: _scaledTextStyle(baseTheme.bodySmall),
      labelLarge: _scaledTextStyle(baseTheme.labelLarge),
      labelMedium: _scaledTextStyle(baseTheme.labelMedium),
      labelSmall: _scaledTextStyle(baseTheme.labelSmall),
    );
  }

  // Phương thức hỗ trợ để điều chỉnh kích thước của một TextStyle
  TextStyle? _scaledTextStyle(TextStyle? style) {
    if (style == null) return null;
    return style.copyWith(
      fontSize: style.fontSize != null
          ? style.fontSize! * _fontSizeOption.scale
          : null,
    );
  }
}
