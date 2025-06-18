import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/story_model.dart';
import '../services/syosetu_api_service.dart';

class StoryProvider extends ChangeNotifier {
  final SyosetuApiService _apiService = SyosetuApiService();
  final List<StoryModel> _stories = [];
  bool _isLoading = false;
  String? _error;
  bool _isDownloadingChapters = false;
  double _downloadProgress = 0.0;

  List<StoryModel> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDownloadingChapters => _isDownloadingChapters;
  double get downloadProgress => _downloadProgress;

  StoryProvider() {
    _loadStoriesFromPrefs();
  }

  // Phương thức để thêm truyện mới từ URL
  Future<bool> addStoryFromUrl(String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Trích xuất ncode từ URL
      final ncode = SyosetuApiService.extractNcodeFromUrl(url);

      if (ncode == null) {
        _error = 'URL không hợp lệ. Vui lòng nhập URL từ ncode.syosetu.com';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Kiểm tra xem truyện đã tồn tại trong danh sách chưa
      if (_stories.any((story) => story.ncode == ncode)) {
        _error = 'Truyện này đã có trong danh sách';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Gọi API để lấy thông tin truyện
      final story = await _apiService.getStoryInfo(ncode);

      if (story == null) {
        _error = 'Không thể tải thông tin truyện. Vui lòng kiểm tra lại URL';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Thêm truyện vào danh sách
      _stories.add(story);

      // Lưu danh sách truyện vào SharedPreferences
      await _saveStoriesToPrefs();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Đã xảy ra lỗi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Phương thức để xóa truyện khỏi danh sách
  Future<void> removeStory(String ncode) async {
    _stories.removeWhere((story) => story.ncode == ncode);
    await _saveStoriesToPrefs();
    notifyListeners();
  }

  // Phương thức để lưu danh sách truyện vào SharedPreferences
  Future<void> _saveStoriesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Chuyển đổi danh sách truyện thành JSON
      final List<Map<String, dynamic>> storiesJson = _stories
          .map(
            (story) => {
              'ncode': story.ncode,
              'title': story.title,
              'author': story.author,
              'authorId': story.authorId,
              'description': story.description,
              'chapterCount': story.chapterCount,
              'lastUpdated': story.lastUpdated?.toIso8601String(),
              'chapters': story.chapters
                  .map(
                    (chapter) => {
                      'index': chapter.index,
                      'title': chapter.title,
                      'url': chapter.url,
                      'content': chapter.content,
                    },
                  )
                  .toList(),
            },
          )
          .toList();

      // Lưu vào SharedPreferences
      await prefs.setString('stories', json.encode(storiesJson));
    } catch (e) {
      print('Lỗi khi lưu danh sách truyện: $e');
    }
  }

  // Phương thức để tải danh sách truyện từ SharedPreferences
  Future<void> _loadStoriesFromPrefs() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final storiesJson = prefs.getString('stories');

      if (storiesJson != null) {
        final List<dynamic> decoded = json.decode(storiesJson);

        _stories.clear();
        for (var storyJson in decoded) {
          // Tải danh sách chương (nếu có)
          List<ChapterModel> chapters = [];
          if (storyJson['chapters'] != null) {
            for (var chapterJson in storyJson['chapters']) {
              chapters.add(
                ChapterModel(
                  index: chapterJson['index'],
                  title: chapterJson['title'],
                  url: chapterJson['url'],
                  content: chapterJson['content'],
                ),
              );
            }
          }

          final story = StoryModel(
            ncode: storyJson['ncode'],
            title: storyJson['title'],
            author: storyJson['author'],
            authorId: storyJson['authorId'],
            description: storyJson['description'],
            chapterCount: storyJson['chapterCount'],
            lastUpdated: storyJson['lastUpdated'] != null
                ? DateTime.parse(storyJson['lastUpdated'])
                : null,
            chapters: chapters,
          );

          _stories.add(story);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải danh sách truyện: $e');
      _isLoading = false;
      _error = 'Không thể tải danh sách truyện';
      notifyListeners();
    }
  }

  // Phương thức để làm mới thông tin truyện
  Future<void> refreshStory(String ncode) async {
    try {
      _isLoading = true;
      notifyListeners();

      final index = _stories.indexWhere((story) => story.ncode == ncode);
      if (index == -1) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final updatedStory = await _apiService.getStoryInfo(ncode);
      if (updatedStory != null) {
        // Giữ lại danh sách chương đã tải (nếu có)
        final existingChapters = _stories[index].chapters;
        if (existingChapters.isNotEmpty) {
          final List<ChapterModel> updatedChapters = [];

          // Tạo danh sách chương mới dựa trên số lượng chương đã cập nhật
          final chapters = await _apiService.getChapters(
            ncode,
            updatedStory.chapterCount,
          );

          // Giữ lại nội dung của các chương đã tải trước đó
          for (var chapter in chapters) {
            final existingChapter = existingChapters.firstWhere(
              (ch) => ch.index == chapter.index,
              orElse: () => chapter,
            );
            updatedChapters.add(
              ChapterModel(
                index: chapter.index,
                title: chapter.title,
                url: chapter.url,
                content: existingChapter.content,
              ),
            );
          }

          // Cập nhật story với danh sách chương mới
          _stories[index] = StoryModel(
            ncode: updatedStory.ncode,
            title: updatedStory.title,
            author: updatedStory.author,
            authorId: updatedStory.authorId,
            description: updatedStory.description,
            chapterCount: updatedStory.chapterCount,
            lastUpdated: updatedStory.lastUpdated,
            chapters: updatedChapters,
          );
        } else {
          _stories[index] = updatedStory;
        }

        await _saveStoriesToPrefs();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Không thể cập nhật thông tin truyện';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phương thức để tải nội dung của một chương cụ thể
  Future<String?> loadChapterContent(String ncode, int chapterIndex) async {
    try {
      print('Đang tải nội dung chương $chapterIndex của truyện $ncode');
      final storyIndex = _stories.indexWhere((story) => story.ncode == ncode);
      if (storyIndex == -1) {
        print('Không tìm thấy truyện với ncode: $ncode');
        return null;
      }

      final story = _stories[storyIndex];
      final chapterList = story.chapters;

      // Tìm chương theo index
      final chapterModelIndex = chapterList.indexWhere(
        (chapter) => chapter.index == chapterIndex,
      );

      // Nếu chương không tồn tại trong danh sách, tải danh sách chương
      if (chapterModelIndex == -1) {
        print(
          'Chương $chapterIndex không tồn tại trong danh sách, đang tải danh sách chương...',
        );
        // Tạo danh sách chương nếu chưa có
        if (chapterList.isEmpty) {
          final chapters = await _apiService.getChapters(
            ncode,
            story.chapterCount,
          );

          if (chapters.isEmpty) {
            print('Không thể tải danh sách chương');
            return null;
          }

          _stories[storyIndex] = StoryModel(
            ncode: story.ncode,
            title: story.title,
            author: story.author,
            authorId: story.authorId,
            description: story.description,
            chapterCount: story.chapterCount,
            lastUpdated: story.lastUpdated,
            chapters: chapters,
          );
          await _saveStoriesToPrefs();
        }

        // Tìm lại chương sau khi đã tạo danh sách
        final updatedChapterList = _stories[storyIndex].chapters;
        final updatedChapterIndex = updatedChapterList.indexWhere(
          (ch) => ch.index == chapterIndex,
        );

        if (updatedChapterIndex == -1) {
          print('Không tìm thấy chương $chapterIndex trong danh sách mới');
          return null;
        }

        // Nếu chương chưa có nội dung, tải nội dung
        if (updatedChapterList[updatedChapterIndex].content == null) {
          final chapterUrl = updatedChapterList[updatedChapterIndex].url;
          print('Đang tải nội dung từ URL: $chapterUrl');
          final content = await _apiService.getChapterContent(chapterUrl);

          if (content.startsWith('Lỗi khi tải nội dung') ||
              content.startsWith('Không thể tải nội dung chương')) {
            print('Lỗi khi tải nội dung chương: $content');
            // Vẫn lưu lại thông báo lỗi để hiển thị cho người dùng
          }

          // Cập nhật nội dung chương
          final updatedChapters = List<ChapterModel>.from(updatedChapterList);
          updatedChapters[updatedChapterIndex] = ChapterModel(
            index: updatedChapterList[updatedChapterIndex].index,
            title: updatedChapterList[updatedChapterIndex].title,
            url: updatedChapterList[updatedChapterIndex].url,
            content: content,
          );

          _stories[storyIndex] = StoryModel(
            ncode: story.ncode,
            title: story.title,
            author: story.author,
            authorId: story.authorId,
            description: story.description,
            chapterCount: story.chapterCount,
            lastUpdated: story.lastUpdated,
            chapters: updatedChapters,
          );

          await _saveStoriesToPrefs();
          print('Đã lưu nội dung chương $chapterIndex');
          return content;
        }

        return updatedChapterList[updatedChapterIndex].content;
      }

      // Nếu chương đã tồn tại nhưng chưa có nội dung, tải nội dung
      if (chapterList[chapterModelIndex].content == null) {
        print(
          'Chương $chapterIndex đã tồn tại nhưng chưa có nội dung, đang tải nội dung...',
        );
        final chapterUrl = chapterList[chapterModelIndex].url;
        print('Đang tải nội dung từ URL: $chapterUrl');
        final content = await _apiService.getChapterContent(chapterUrl);

        if (content.startsWith('Lỗi khi tải nội dung') ||
            content.startsWith('Không thể tải nội dung chương')) {
          print('Lỗi khi tải nội dung chương: $content');
          // Vẫn lưu lại thông báo lỗi để hiển thị cho người dùng
        }

        // Cập nhật nội dung chương
        final updatedChapters = List<ChapterModel>.from(chapterList);
        updatedChapters[chapterModelIndex] = ChapterModel(
          index: chapterList[chapterModelIndex].index,
          title: chapterList[chapterModelIndex].title,
          url: chapterList[chapterModelIndex].url,
          content: content,
        );

        _stories[storyIndex] = StoryModel(
          ncode: story.ncode,
          title: story.title,
          author: story.author,
          authorId: story.authorId,
          description: story.description,
          chapterCount: story.chapterCount,
          lastUpdated: story.lastUpdated,
          chapters: updatedChapters,
        );

        await _saveStoriesToPrefs();
        print('Đã lưu nội dung chương $chapterIndex');
        return content;
      }

      // Trả về nội dung chương đã có
      print('Trả về nội dung chương $chapterIndex đã có');
      return chapterList[chapterModelIndex].content;
    } catch (e) {
      print('Lỗi khi tải nội dung chương: $e');
      return 'Lỗi khi tải nội dung chương: $e';
    }
  }

  // Phương thức để tải tất cả các chương của một truyện
  Future<bool> downloadAllChapters(String ncode) async {
    try {
      _isDownloadingChapters = true;
      _downloadProgress = 0.0;
      notifyListeners();

      final storyIndex = _stories.indexWhere((story) => story.ncode == ncode);
      if (storyIndex == -1) {
        _isDownloadingChapters = false;
        notifyListeners();
        return false;
      }

      final story = _stories[storyIndex];

      // Tạo danh sách chương nếu chưa có
      List<ChapterModel> chapters;
      if (story.chapters.isEmpty) {
        chapters = await _apiService.getChapters(ncode, story.chapterCount);
      } else {
        chapters = List<ChapterModel>.from(story.chapters);
      }

      // Tải nội dung cho từng chương
      final totalChapters = chapters.length;
      for (int i = 0; i < totalChapters; i++) {
        if (chapters[i].content == null) {
          final content = await _apiService.getChapterContent(chapters[i].url);
          chapters[i] = ChapterModel(
            index: chapters[i].index,
            title: chapters[i].title,
            url: chapters[i].url,
            content: content,
          );
        }

        // Cập nhật tiến trình
        _downloadProgress = (i + 1) / totalChapters;
        notifyListeners();
      }

      // Cập nhật truyện với danh sách chương đã tải
      _stories[storyIndex] = StoryModel(
        ncode: story.ncode,
        title: story.title,
        author: story.author,
        authorId: story.authorId,
        description: story.description,
        chapterCount: story.chapterCount,
        lastUpdated: story.lastUpdated,
        chapters: chapters,
      );

      await _saveStoriesToPrefs();

      _isDownloadingChapters = false;
      _downloadProgress = 1.0;
      notifyListeners();

      return true;
    } catch (e) {
      print('Lỗi khi tải tất cả các chương: $e');
      _isDownloadingChapters = false;
      notifyListeners();
      return false;
    }
  }
}
