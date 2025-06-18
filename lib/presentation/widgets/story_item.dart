import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_sizes.dart';
import '../../core/models/story_model.dart';

class StoryItem extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;

  const StoryItem({super.key, required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTextSizes.spacingMedium,
        vertical: AppTextSizes.spacingTiny,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppTextSizes.spacingMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon truyện
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.storyManagement.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: AppColors.storyManagement,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppTextSizes.spacingMedium),
              // Thông tin truyện
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTextSizes.spacingTiny),
                    Text(
                      'Tác giả: ${story.author}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTextSizes.spacingTiny),
                    Text(
                      '${story.chapterCount} chương',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
