import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/story_provider.dart';
import '../../widgets/empty_link_placeholder.dart';
import '../../widgets/add_link_dialog.dart';
import '../../widgets/story_item.dart';
import 'story_detail_screen.dart';

class StoryManagementScreen extends StatefulWidget {
  const StoryManagementScreen({super.key});

  @override
  State<StoryManagementScreen> createState() => _StoryManagementScreenState();
}

class _StoryManagementScreenState extends State<StoryManagementScreen> {
  late StoryProvider _storyProvider;

  @override
  void initState() {
    super.initState();
    // Khởi tạo StoryProvider
    _storyProvider = StoryProvider();
  }

  void _showAddLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddLinkDialog(),
    ).then((value) async {
      if (value != null && value.toString().isNotEmpty) {
        // Thêm truyện từ URL
        final result = await _storyProvider.addStoryFromUrl(value.toString());

        if (!result && mounted && _storyProvider.error != null) {
          // Hiển thị thông báo lỗi nếu có
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_storyProvider.error!)));
        }
      }
    });
  }

  void _navigateToStoryDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailScreen(
          story: _storyProvider.stories[index],
          storyProvider: _storyProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _storyProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.storyManagement),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
        ),
        body: Consumer<StoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.stories.isEmpty) {
              return const Center(child: EmptyLinkPlaceholder());
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.stories.length,
              itemBuilder: (context, index) {
                final story = provider.stories[index];
                return Dismissible(
                  key: Key(story.ncode),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    provider.removeStory(story.ncode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xóa "${story.title}"')),
                    );
                  },
                  child: StoryItem(
                    story: story,
                    onTap: () => _navigateToStoryDetail(index),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddLinkDialog,
          backgroundColor: AppColors.storyManagement,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }
}
