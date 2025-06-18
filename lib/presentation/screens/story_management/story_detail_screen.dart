import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_sizes.dart';
import '../../../core/models/story_model.dart';
import '../../../core/providers/story_provider.dart';
import 'chapter_reading_screen.dart';

class StoryDetailScreen extends StatefulWidget {
  final StoryModel story;
  final StoryProvider storyProvider;

  const StoryDetailScreen({
    super.key,
    required this.story,
    required this.storyProvider,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshStoryData();
  }

  Future<void> _refreshStoryData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.storyProvider.refreshStory(widget.story.ncode);
    } catch (e) {
      setState(() {
        _error = 'Không thể cập nhật thông tin truyện: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openSyosetuLink() async {
    final url = Uri.parse(widget.story.syosetuUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể mở liên kết')));
      }
    }
  }

  void _openChapter(int chapterIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChapterReadingScreen(
          story: widget.story,
          chapterIndex: chapterIndex,
          storyProvider: widget.storyProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title, overflow: TextOverflow.ellipsis),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openSyosetuLink,
            tooltip: 'Mở trong trình duyệt',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTextSizes.spacingMedium),
                  ElevatedButton(
                    onPressed: _refreshStoryData,
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTextSizes.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin truyện
                  _buildInfoSection(context),
                  const SizedBox(height: AppTextSizes.spacingLarge),
                  // Mô tả truyện
                  _buildDescriptionSection(context),
                  const SizedBox(height: AppTextSizes.spacingLarge),
                  // Danh sách chương
                  _buildChaptersSection(context),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(AppTextSizes.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              AppStrings.storyTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.storyManagement,
              ),
            ),
            const SizedBox(height: AppTextSizes.spacingTiny),
            Text(
              widget.story.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: AppTextSizes.spacingLarge),

            // Tác giả
            Text(
              AppStrings.storyAuthor,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.storyManagement,
              ),
            ),
            const SizedBox(height: AppTextSizes.spacingTiny),
            Text(
              widget.story.author,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: AppTextSizes.spacingLarge),

            // Cập nhật lần cuối
            Text(
              AppStrings.lastUpdated,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.storyManagement,
              ),
            ),
            const SizedBox(height: AppTextSizes.spacingTiny),
            Text(
              widget.story.formattedLastUpdated,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(AppTextSizes.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.storyDescription,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.storyManagement,
              ),
            ),
            const SizedBox(height: AppTextSizes.spacingMedium),
            Text(
              widget.story.description.isNotEmpty
                  ? widget.story.description
                  : 'Không có mô tả',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChaptersSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(AppTextSizes.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.storyChapters,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.storyManagement,
              ),
            ),
            const SizedBox(height: AppTextSizes.spacingMedium),
            Text(
              'Tổng số chương: ${widget.story.chapterCount}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppTextSizes.spacingMedium),
            if (widget.story.chapterCount > 0)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.story.chapterCount > 10
                    ? 10
                    : widget.story.chapterCount,
                itemBuilder: (context, index) {
                  final chapterIndex = index + 1;
                  return ListTile(
                    title: Text('Chương $chapterIndex'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openChapter(chapterIndex),
                  );
                },
              ),
            if (widget.story.chapterCount > 10)
              Padding(
                padding: const EdgeInsets.only(top: AppTextSizes.spacingSmall),
                child: Center(
                  child: TextButton(
                    onPressed: () => _openChapter(1),
                    child: const Text('Xem tất cả chương'),
                  ),
                ),
              ),
            if (widget.story.chapterCount == 0)
              const Text(
                'Không có chương nào.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
