import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_sizes.dart';
import '../../../core/models/story_model.dart';
import '../../../core/providers/story_provider.dart';

class ChapterReadingScreen extends StatefulWidget {
  final StoryModel story;
  final int chapterIndex;
  final StoryProvider storyProvider;

  const ChapterReadingScreen({
    super.key,
    required this.story,
    required this.chapterIndex,
    required this.storyProvider,
  });

  @override
  State<ChapterReadingScreen> createState() => _ChapterReadingScreenState();
}

class _ChapterReadingScreenState extends State<ChapterReadingScreen> {
  bool _isLoading = true;
  String? _error;
  String? _chapterContent;

  @override
  void initState() {
    super.initState();
    _loadChapterContent();
  }

  Future<void> _loadChapterContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await widget.storyProvider.loadChapterContent(
        widget.story.ncode,
        widget.chapterIndex,
      );

      if (content == null) {
        setState(() {
          _error = AppStrings.errorLoadingChapter;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _chapterContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải nội dung chương: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToChapter(int index) {
    if (index < 1 || index > widget.story.chapterCount) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChapterReadingScreen(
          story: widget.story,
          chapterIndex: index,
          storyProvider: widget.storyProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.story.title} - Chương ${widget.chapterIndex}',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.downloadingChapters),
                  duration: Duration(seconds: 2),
                ),
              );

              final result = await widget.storyProvider.downloadAllChapters(
                widget.story.ncode,
              );

              if (result && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.downloadComplete),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: AppStrings.downloadAllChapters,
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
                    onPressed: _loadChapterContent,
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTextSizes.spacingMedium),
                    child: _buildChapterContent(),
                  ),
                ),
                _buildNavigationBar(),
              ],
            ),
    );
  }

  Widget _buildChapterContent() {
    if (_chapterContent == null) return const SizedBox.shrink();

    // Kiểm tra nếu nội dung là thông báo lỗi
    if (_chapterContent!.startsWith('Lỗi khi tải nội dung') ||
        _chapterContent!.startsWith('Không thể tải nội dung chương')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppTextSizes.spacingMedium),
          Text(
            'Không thể tải nội dung chương',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTextSizes.spacingMedium),
          Text(
            _chapterContent!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTextSizes.spacingLarge),
          ElevatedButton(
            onPressed: _loadChapterContent,
            child: const Text('Thử lại'),
          ),
        ],
      );
    }

    // Tách tiêu đề và nội dung
    final parts = _chapterContent!.split('\n\n');
    final title = parts.isNotEmpty ? parts[0] : 'Chương ${widget.chapterIndex}';
    final content = parts.length > 1
        ? parts.sublist(1).join('\n\n')
        : _chapterContent!;

    // Kiểm tra nếu nội dung trống
    if (content.trim().isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề chương
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.storyManagement,
            ),
          ),
          const SizedBox(height: AppTextSizes.spacingLarge),
          // Thông báo nội dung trống
          Center(
            child: Text(
              'Không có nội dung cho chương này',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề chương
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.storyManagement,
          ),
        ),
        const SizedBox(height: AppTextSizes.spacingLarge),
        // Nội dung chương
        Html(
          data: '<div>${content.replaceAll('\n\n', '<br><br>')}</div>',
          style: {
            'div': Style(
              fontSize: FontSize(18.0),
              lineHeight: LineHeight.number(1.5),
            ),
          },
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTextSizes.spacingSmall,
        horizontal: AppTextSizes.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút chương trước
          ElevatedButton.icon(
            onPressed: widget.chapterIndex > 1
                ? () => _navigateToChapter(widget.chapterIndex - 1)
                : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text(AppStrings.previousChapter),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.storyManagement,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          ),
          // Nút chương sau
          ElevatedButton.icon(
            onPressed: widget.chapterIndex < widget.story.chapterCount
                ? () => _navigateToChapter(widget.chapterIndex + 1)
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text(AppStrings.nextChapter),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.storyManagement,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
