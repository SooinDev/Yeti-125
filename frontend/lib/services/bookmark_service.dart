import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Bookmark {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final DateTime bookmarkedAt;
  String memo;

  Bookmark({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.bookmarkedAt,
    this.memo = '',
  });

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'bookmarkedAt': bookmarkedAt.toIso8601String(),
        'memo': memo,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        videoId: json['videoId'],
        title: json['title'],
        thumbnailUrl: json['thumbnailUrl'],
        bookmarkedAt: DateTime.parse(json['bookmarkedAt']),
        memo: json['memo'] ?? '',
      );
}

class BookmarkService {
  static const String _key = 'bookmarks';
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  // 북마크 추가
  Future<void> addBookmark({
    required String videoId,
    required String title,
    required String thumbnailUrl,
    String memo = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Bookmark> bookmarks = await getBookmarks();

      // 이미 북마크되어 있는지 확인
      final existingIndex =
          bookmarks.indexWhere((b) => b.videoId == videoId);

      if (existingIndex == -1) {
        // 새로운 북마크 추가
        bookmarks.insert(
          0,
          Bookmark(
            videoId: videoId,
            title: title,
            thumbnailUrl: thumbnailUrl,
            bookmarkedAt: DateTime.now(),
            memo: memo,
          ),
        );

        // 저장
        final jsonList = bookmarks.map((b) => b.toJson()).toList();
        await prefs.setString(_key, jsonEncode(jsonList));

      } else {
      }
    } catch (e) {
    }
  }

  // 북마크 삭제
  Future<void> removeBookmark(String videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Bookmark> bookmarks = await getBookmarks();

      bookmarks.removeWhere((b) => b.videoId == videoId);

      final jsonList = bookmarks.map((b) => b.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));

    } catch (e) {
    }
  }

  // 북마크 여부 확인
  Future<bool> isBookmarked(String videoId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b.videoId == videoId);
  }

  // 전체 북마크 가져오기
  Future<List<Bookmark>> getBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Bookmark.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 메모 업데이트
  Future<void> updateMemo(String videoId, String memo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Bookmark> bookmarks = await getBookmarks();

      final index = bookmarks.indexWhere((b) => b.videoId == videoId);
      if (index != -1) {
        bookmarks[index].memo = memo;

        final jsonList = bookmarks.map((b) => b.toJson()).toList();
        await prefs.setString(_key, jsonEncode(jsonList));

      }
    } catch (e) {
    }
  }

  // 북마크 전체 삭제
  Future<void> clearBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
    }
  }

  // 총 북마크 개수
  Future<int> getBookmarkCount() async {
    final bookmarks = await getBookmarks();
    return bookmarks.length;
  }

  // 메모가 있는 북마크만 가져오기
  Future<List<Bookmark>> getBookmarksWithMemo() async {
    final bookmarks = await getBookmarks();
    return bookmarks.where((b) => b.memo.isNotEmpty).toList();
  }

  // 검색
  Future<List<Bookmark>> searchBookmarks(String query) async {
    if (query.isEmpty) return getBookmarks();

    final bookmarks = await getBookmarks();
    final lowerQuery = query.toLowerCase();

    return bookmarks.where((b) {
      return b.title.toLowerCase().contains(lowerQuery) ||
          b.memo.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
