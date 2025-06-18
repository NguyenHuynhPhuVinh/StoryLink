import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'presentation/screens/story_management/story_management_screen.dart';
import 'presentation/screens/ai_chat/ai_chat_screen.dart';
import 'presentation/screens/web_browser/web_browser_screen.dart';
import 'presentation/screens/app_settings/app_settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StoryManagementScreen(),
    AiChatScreen(),
    WebBrowserScreen(),
    AppSettingsScreen(),
  ];

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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book)),
          BottomNavigationBarItem(icon: Icon(Icons.chat)),
          BottomNavigationBarItem(icon: Icon(Icons.web)),
          BottomNavigationBarItem(icon: Icon(Icons.settings)),
        ],
      ),
    );
  }
}
