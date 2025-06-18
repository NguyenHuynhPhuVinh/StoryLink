import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_sizes.dart';

class EmptyLinkPlaceholder extends StatelessWidget {
  const EmptyLinkPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu_book,
          size: AppTextSizes.iconLarge,
          color: AppColors.storyManagement,
        ),
        const SizedBox(height: AppTextSizes.spacingMedium),
        Text(
          AppStrings.noLinksYet,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.storyManagement,
          ),
        ),
        const SizedBox(height: AppTextSizes.spacingTiny),
        Text(
          AppStrings.tapPlusToAddLink,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
