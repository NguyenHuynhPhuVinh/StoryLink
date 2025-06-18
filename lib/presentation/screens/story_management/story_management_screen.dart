import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/empty_link_placeholder.dart';
import '../../widgets/add_link_dialog.dart';

class StoryManagementScreen extends StatefulWidget {
  const StoryManagementScreen({super.key});

  @override
  State<StoryManagementScreen> createState() => _StoryManagementScreenState();
}

class _StoryManagementScreenState extends State<StoryManagementScreen> {
  // Danh sách link sẽ được thêm sau
  final List<String> _links = [];

  void _showAddLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddLinkDialog(),
    ).then((value) {
      // Xử lý khi người dùng nhập link (sẽ được thêm sau)
      if (value != null && value.toString().isNotEmpty) {
        // Thêm logic xử lý link ở đây
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.storyManagement),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: const Center(child: EmptyLinkPlaceholder()),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLinkDialog,
        backgroundColor: AppColors.storyManagement,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
