import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/settings/app_settings_manager.dart';

class AppSettingsScreen extends StatefulWidget {
  final AppSettingsManager settingsManager;

  const AppSettingsScreen({super.key, required this.settingsManager});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appSettings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(AppStrings.appearance),
          _buildFontSizeSettings(),
          const Divider(height: 32),
          _buildSectionTitle(AppStrings.appInfo),
          _buildInfoTile(AppStrings.version, '1.0.0'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.appSettings,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFontSizeSettings() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.format_size, color: AppColors.appSettings),
                const SizedBox(width: 8),
                Text(
                  AppStrings.fontSize,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFontSizeOption(FontSizeOption.small),
                _buildFontSizeOption(FontSizeOption.medium),
                _buildFontSizeOption(FontSizeOption.large),
                _buildFontSizeOption(FontSizeOption.extraLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(FontSizeOption option) {
    final isSelected = widget.settingsManager.fontSizeOption == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.settingsManager.fontSizeOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.appSettings.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.appSettings : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'A',
              style: TextStyle(
                fontSize: 16 * option.scale,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.appSettings
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.appSettings
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
