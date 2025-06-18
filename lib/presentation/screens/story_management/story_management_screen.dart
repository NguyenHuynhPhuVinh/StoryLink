import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/placeholder_widget.dart';

class StoryManagementScreen extends StatelessWidget {
  const StoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.storyManagement),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: const Center(
        child: PlaceholderWidget(
          icon: Icons.book,
          color: AppColors.storyManagement,
          title: AppStrings.storyManagement,
        ),
      ),
    );
  }
}
