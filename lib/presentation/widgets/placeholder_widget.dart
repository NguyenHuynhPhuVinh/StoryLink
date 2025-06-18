import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_sizes.dart';

class PlaceholderWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const PlaceholderWidget({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: AppTextSizes.iconLarge, color: color),
        const SizedBox(height: AppTextSizes.spacingMedium),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTextSizes.spacingTiny),
        Text(
          AppStrings.developmentInProgress,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
