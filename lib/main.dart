import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/settings/app_settings_manager.dart';
import 'presentation/screens/story_management/story_management_screen.dart';
import 'presentation/screens/ai_chat/ai_chat_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/app_settings/app_settings_screen.dart';

void main() {
  // Khởi tạo AppSettingsManager trước khi chạy ứng dụng
  final settingsManager = AppSettingsManager();
  runApp(MyApp(settingsManager: settingsManager));
}

class MyApp extends StatefulWidget {
  final AppSettingsManager settingsManager;

  const MyApp({super.key, required this.settingsManager});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeData _theme;

  @override
  void initState() {
    super.initState();
    _updateTheme();

    // Lắng nghe sự thay đổi cài đặt
    widget.settingsManager.addListener(_updateTheme);
  }

  @override
  void dispose() {
    // Hủy lắng nghe khi widget bị hủy
    widget.settingsManager.removeListener(_updateTheme);
    super.dispose();
  }

  // Cập nhật theme khi cài đặt thay đổi
  void _updateTheme() {
    setState(() {
      // Lấy theme cơ bản
      final baseTheme = AppTheme.lightTheme;

      // Áp dụng cài đặt font size
      final textTheme = widget.settingsManager.applyFontSizeToTheme(
        baseTheme.textTheme,
      );

      // Tạo theme mới với textTheme đã điều chỉnh
      _theme = baseTheme.copyWith(textTheme: textTheme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: _theme,
      home: MainScreen(settingsManager: widget.settingsManager),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  final AppSettingsManager settingsManager;

  const MainScreen({super.key, required this.settingsManager});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const StoryManagementScreen(),
      const AiChatScreen(),
      const HistoryScreen(),
      AppSettingsScreen(settingsManager: widget.settingsManager),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: AppColors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.link),
            label: AppStrings.storyManagement,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: AppStrings.aiChat,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: AppStrings.webBrowser,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.appSettings,
          ),
        ],
      ),
    );
  }
}
