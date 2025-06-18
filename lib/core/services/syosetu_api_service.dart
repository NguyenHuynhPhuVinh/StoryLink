import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:html/dom.dart' as dom;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import '../models/story_model.dart';

class SyosetuApiService {
  static const String _baseUrl = 'https://api.syosetu.com/novelapi/api/';

  // Phương thức để trích xuất ncode từ URL
  static String? extractNcodeFromUrl(String url) {
    // Kiểm tra xem URL có phải từ ncode.syosetu.com không
    if (!url.contains('ncode.syosetu.com')) {
      return null;
    }

    // Regex để trích xuất ncode từ URL
    final regex = RegExp(r'ncode\.syosetu\.com\/(\w+)');
    final match = regex.firstMatch(url);

    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return null;
  }

  // Phương thức để lấy thông tin truyện từ API
  Future<StoryModel?> getStoryInfo(String ncode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?ncode=$ncode&out=json'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'application/json',
          'Accept-Language': 'ja,en-US;q=0.9,en;q=0.8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // API trả về một mảng với phần tử đầu tiên là thông tin về kết quả
        // và phần tử thứ hai là thông tin về truyện (nếu có)
        if (data.length > 1) {
          return StoryModel.fromJson(data[1]);
        }
      }

      return null;
    } catch (e) {
      print('Lỗi khi gọi API: $e');
      return null;
    }
  }

  // Phương thức để lấy danh sách chương của truyện dựa trên số lượng chương
  Future<List<ChapterModel>> getChapters(String ncode, int chapterCount) async {
    List<ChapterModel> chapters = [];

    for (int i = 1; i <= chapterCount; i++) {
      final url = 'https://ncode.syosetu.com/$ncode/$i/';
      chapters.add(ChapterModel(index: i, title: 'Chương $i', url: url));
    }

    return chapters;
  }

  // Phương thức để scrape nội dung chương từ URL sử dụng BeautifulSoup
  Future<String> getChapterContent(String url) async {
    try {
      // Thêm User-Agent vào header để tránh bị chặn
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml',
          'Accept-Language': 'ja,en-US;q=0.9,en;q=0.8',
        },
      );

      if (response.statusCode == 200) {
        // Kiểm tra xem có phải trang chuyển hướng không
        if (response.body.contains('refresh') &&
            response.body.contains('URL=')) {
          // Trích xuất URL chuyển hướng
          final redirectRegex = RegExp(r'URL=\s*([^"\s>]+)');
          final redirectMatch = redirectRegex.firstMatch(response.body);

          if (redirectMatch != null && redirectMatch.groupCount >= 1) {
            final redirectUrl = redirectMatch.group(1)?.trim();

            if (redirectUrl != null) {
              // Gọi đệ quy với URL mới
              return await getChapterContent(redirectUrl);
            }
          }
        }

        // Sử dụng BeautifulSoup để parse HTML
        final soup = BeautifulSoup(response.body);

        // Trích xuất tiêu đề chương
        String title = 'Không có tiêu đề';

        // Thử các selector khác nhau cho tiêu đề
        var novelSubtitle = soup.find('.novel_subtitle');
        if (novelSubtitle != null) {
          title = novelSubtitle.text;
        } else {
          var pNovelTitle = soup.find('.p-novel__title');
          if (pNovelTitle != null) {
            title = pNovelTitle.text;
          } else {
            // Thử tìm kiếm các phần tử khác có thể chứa tiêu đề
            var h1Title = soup.find('h1');
            if (h1Title != null) {
              title = h1Title.text;
            } else {
              var h2Title = soup.find('h2');
              if (h2Title != null) {
                title = h2Title.text;
              }
            }
          }
        }

        // Trích xuất nội dung chương
        String content = '';

        // Thử các selector khác nhau cho nội dung
        var novelHonbun = soup.find('#novel_honbun');
        if (novelHonbun != null) {
          content = _extractContentFromSoup(novelHonbun);
        } else {
          var novelView = soup.find('.novel_view');
          if (novelView != null) {
            content = _extractContentFromSoup(novelView);
          } else {
            var jsNovelText = soup.find('.js-novel-text');
            if (jsNovelText != null) {
              content = _extractContentFromSoup(jsNovelText);
            } else {
              // Thử tìm kiếm các phần tử khác có thể chứa nội dung
              var mainContent = soup.find('main');
              if (mainContent != null) {
                content = _extractContentFromSoup(mainContent);
              } else {
                var articleContent = soup.find('article');
                if (articleContent != null) {
                  content = _extractContentFromSoup(articleContent);
                }
              }
            }
          }
        }

        if (content.isEmpty) {
          // Thử tìm tất cả các thẻ p trong trang
          var allParagraphs = soup.findAll('p');
          if (allParagraphs.isNotEmpty) {
            for (var p in allParagraphs) {
              // Kiểm tra xem thẻ p có id bắt đầu bằng 'L' không (định dạng Syosetu)
              var id = p.attributes['id'] ?? '';
              if (id.startsWith('L')) {
                content += '${p.text}\n';
              }
            }
          }
        }

        if (content.isEmpty) {
          return 'Không thể trích xuất nội dung chương. Tiêu đề: $title';
        }

        return '$title\n\n$content';
      }

      return 'Không thể tải nội dung chương. Mã lỗi: ${response.statusCode}';
    } catch (e) {
      return 'Lỗi khi tải nội dung: $e';
    }
  }

  // Phương thức hỗ trợ để trích xuất nội dung văn bản từ BeautifulSoup
  String _extractContentFromSoup(Bs4Element element) {
    // Loại bỏ các phần tử không mong muốn (nếu có)
    final unwantedSelectors = [
      '.advertisement',
      '.ad',
      'script',
      'style',
      '.c-ad',
      '[data-cptid]',
      '.c-pager',
      '.novel_bn',
      '.koukoku_728x90',
      '.novel_attention',
      '.novellingk',
      '.narou_link',
      '.novel_writername',
    ];

    for (var selector in unwantedSelectors) {
      var unwantedElements = element.findAll(selector);
      for (var unwanted in unwantedElements) {
        // Thay vì sử dụng replaceWith('') với chuỗi rỗng, chúng ta sẽ sử dụng extract()
        // để loại bỏ phần tử khỏi cây DOM mà không cần thay thế
        unwanted.extract();
      }
    }

    // Kiểm tra xem có các phần tử p với id bắt đầu bằng 'L' không (định dạng Syosetu mới)
    var paragraphs = element.findAll('p');
    var syosetuParagraphs = paragraphs.where((p) {
      var id = p.attributes['id'] ?? '';
      return id.startsWith('L');
    }).toList();

    if (syosetuParagraphs.isNotEmpty) {
      String content = '';
      for (var p in syosetuParagraphs) {
        content += p.text + '\n';
      }
      return content.trim();
    }

    // Nếu không tìm thấy định dạng đặc biệt, thử lấy tất cả các thẻ p
    if (paragraphs.isNotEmpty) {
      String content = '';
      for (var p in paragraphs) {
        content += p.text + '\n';
      }
      return content.trim();
    }

    // Nếu không tìm thấy thẻ p nào, lấy toàn bộ nội dung văn bản
    String content = element.text;

    // Xử lý các dòng trống liên tiếp
    content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return content.trim();
  }

  // Giữ lại phương thức cũ để tương thích với code hiện tại
  String _extractTextContent(dom.Element element) {
    // Loại bỏ các phần tử không mong muốn (nếu có)
    final unwantedElements = element.querySelectorAll(
      '.advertisement, .ad, script, style, .c-ad, [data-cptid], .c-pager',
    );
    for (var unwanted in unwantedElements) {
      unwanted.remove();
    }

    // Kiểm tra xem có các phần tử p với id bắt đầu bằng 'L' không (định dạng Syosetu mới)
    final paragraphs = element.querySelectorAll('p[id^="L"]');
    if (paragraphs.isNotEmpty) {
      String content = '';
      for (var p in paragraphs) {
        content += p.text + '\n';
      }
      return content.trim();
    }

    // Nếu không tìm thấy định dạng đặc biệt, lấy toàn bộ nội dung văn bản
    String content = element.text;

    // Xử lý các dòng trống liên tiếp
    content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return content.trim();
  }

  // Phương thức để tải toàn bộ nội dung truyện
  Future<Map<int, String>> getAllChaptersContent(
    String ncode,
    int chapterCount,
  ) async {
    Map<int, String> chaptersContent = {};

    for (int i = 1; i <= chapterCount; i++) {
      final url = 'https://ncode.syosetu.com/$ncode/$i/';
      final content = await getChapterContent(url);
      chaptersContent[i] = content;
    }

    return chaptersContent;
  }
}
