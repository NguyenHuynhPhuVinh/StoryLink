import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/placeholder_widget.dart';

class WebBrowserScreen extends StatelessWidget {
  const WebBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.webBrowser),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: const Center(
        child: PlaceholderWidget(
          icon: Icons.web,
          color: AppColors.webBrowser,
          title: AppStrings.webBrowser,
        ),
      ),
    );
  }
}
