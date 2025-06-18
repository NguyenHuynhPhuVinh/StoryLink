import 'package:intl/intl.dart';

class StoryModel {
  final String ncode;
  final String title;
  final String author;
  final String authorId;
  final String description;
  final int chapterCount;
  final DateTime? lastUpdated;
  final List<ChapterModel> chapters;

  StoryModel({
    required this.ncode,
    required this.title,
    required this.author,
    required this.authorId,
    required this.description,
    required this.chapterCount,
    this.lastUpdated,
    this.chapters = const [],
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    // Xử lý ngày cập nhật
    DateTime? lastUpdated;
    if (json['general_lastup'] != null) {
      try {
        lastUpdated = DateTime.parse(json['general_lastup']);
      } catch (e) {
        print('Lỗi khi parse ngày: $e');
      }
    }

    return StoryModel(
      ncode: json['ncode'] ?? '',
      title: json['title'] ?? '',
      author: json['writer'] ?? '',
      authorId: json['userid']?.toString() ?? '',
      description: json['story'] ?? '',
      chapterCount: json['general_all_no'] ?? 0,
      lastUpdated: lastUpdated,
    );
  }

  String get formattedLastUpdated {
    if (lastUpdated == null) return 'Không có thông tin';
    return DateFormat('dd/MM/yyyy HH:mm').format(lastUpdated!);
  }

  String get syosetuUrl => 'https://ncode.syosetu.com/$ncode/';
}

class ChapterModel {
  final int index;
  final String title;
  final String url;
  final String? content;

  ChapterModel({
    required this.index,
    required this.title,
    required this.url,
    this.content,
  });
}
