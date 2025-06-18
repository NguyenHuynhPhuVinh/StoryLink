import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_sizes.dart';

class AddLinkDialog extends StatefulWidget {
  const AddLinkDialog({super.key});

  @override
  State<AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<AddLinkDialog> {
  final TextEditingController _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppStrings.addNewLink,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.storyManagement,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        AppTextSizes.spacingMedium,
        AppTextSizes.spacingSmall,
        AppTextSizes.spacingMedium,
        AppTextSizes.spacingMedium,
      ),
      content: SizedBox(
        width: 280, // Giới hạn chiều rộng của dialog
        child: TextField(
          controller: _linkController,
          decoration: InputDecoration(
            hintText: AppStrings.enterLink,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textPlaceholder),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.storyManagement,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTextSizes.spacingMedium,
              vertical: AppTextSizes.spacingSmall,
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          autofocus: true,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppTextSizes.spacingSmall,
        0,
        AppTextSizes.spacingSmall,
        AppTextSizes.spacingSmall,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTextSizes.spacingMedium,
              vertical: AppTextSizes.spacingTiny,
            ),
          ),
          child: Text(
            AppStrings.cancel,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Xử lý lưu link ở đây (sẽ được thêm sau)
            Navigator.pop(context, _linkController.text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.storyManagement,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTextSizes.spacingMedium,
              vertical: AppTextSizes.spacingTiny,
            ),
          ),
          child: Text(
            AppStrings.save,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
