import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WatchHistory {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final DateTime watchedAt;
  int watchCount;

  WatchHistory({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.watchedAt,
    this.watchCount = 1,
  });

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'watchedAt': watchedAt.toIso8601String(),
        'watchCount': watchCount,
      };

  factory WatchHistory.fromJson(Map<String, dynamic> json) => WatchHistory(
        videoId: json['videoId'],
        title: json['title'],
        thumbnailUrl: json['thumbnailUrl'],
        watchedAt: DateTime.parse(json['watchedAt']),
        watchCount: json['watchCount'] ?? 1,
      );
}

class WatchHistoryService {
  static const String _key = 'watch_history';
  static final WatchHistoryService _instance = WatchHistoryService._internal();
  factory WatchHistoryService() => _instance;
  WatchHistoryService._internal();

  // 시청 기록 추가
  Future<void> addHistory({
    required String videoId,
    required String title,
    required String thumbnailUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<WatchHistory> histories = await getHistories();

      // 이미 존재하는 영상인지 확인
      final existingIndex =
          histories.indexWhere((h) => h.videoId == videoId);

      if (existingIndex != -1) {
        // 존재하면 시청 횟수 증가
        histories[existingIndex].watchCount++;
        histories[existingIndex] = WatchHistory(
          videoId: histories[existingIndex].videoId,
          title: histories[existingIndex].title,
          thumbnailUrl: histories[existingIndex].thumbnailUrl,
          watchedAt: DateTime.now(), // 마지막 시청 시간 업데이트
          watchCount: histories[existingIndex].watchCount,
        );
      } else {
        // 새로운 영상 추가
        histories.insert(
          0,
          WatchHistory(
            videoId: videoId,
            title: title,
            thumbnailUrl: thumbnailUrl,
            watchedAt: DateTime.now(),
          ),
        );
      }

      // 최대 100개까지만 저장
      if (histories.length > 100) {
        histories.removeRange(100, histories.length);
      }

      // 저장
      final jsonList = histories.map((h) => h.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));

    } catch (e) {
    }
  }

  // 전체 시청 기록 가져오기
  Future<List<WatchHistory>> getHistories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => WatchHistory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 총 시청 영상 수
  Future<int> getTotalWatchCount() async {
    final histories = await getHistories();
    return histories.length;
  }

  // 총 클릭 횟수 (중복 포함)
  Future<int> getTotalClickCount() async {
    final histories = await getHistories();
    return histories.fold<int>(0, (sum, h) => sum + h.watchCount);
  }

  // 가장 많이 본 영상 (상위 N개)
  Future<List<WatchHistory>> getTopWatchedVideos({int limit = 5}) async {
    final histories = await getHistories();
    histories.sort((a, b) => b.watchCount.compareTo(a.watchCount));
    return histories.take(limit).toList();
  }

  // 최근 본 영상 (상위 N개)
  Future<List<WatchHistory>> getRecentWatchedVideos({int limit = 10}) async {
    final histories = await getHistories();
    return histories.take(limit).toList();
  }

  // 시청 기록 전체 삭제
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
    }
  }

  // 최근 7일간 일별 시청 통계
  Future<Map<DateTime, int>> getDailyStats({int days = 7}) async {
    final histories = await getHistories();
    final now = DateTime.now();
    final stats = <DateTime, int>{};

    // 최근 N일 날짜 초기화
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      stats[date] = 0;
    }

    // 각 날짜별 시청 횟수 집계
    for (final history in histories) {
      final watchDate = DateTime(
        history.watchedAt.year,
        history.watchedAt.month,
        history.watchedAt.day,
      );
      if (stats.containsKey(watchDate)) {
        stats[watchDate] = stats[watchDate]! + 1;
      }
    }

    return stats;
  }

  // 시간대별 시청 분포 (0-23시)
  Future<Map<int, int>> getHourlyDistribution() async {
    final histories = await getHistories();
    final distribution = <int, int>{};

    // 0-23시 초기화
    for (int hour = 0; hour < 24; hour++) {
      distribution[hour] = 0;
    }

    // 각 시간대별 시청 횟수 집계
    for (final history in histories) {
      final hour = history.watchedAt.hour;
      distribution[hour] = distribution[hour]! + 1;
    }

    return distribution;
  }

  // 연속 시청일 계산
  Future<int> getWatchStreak() async {
    final histories = await getHistories();
    if (histories.isEmpty) return 0;

    // 날짜별로 시청 여부 확인
    final watchDates = <DateTime>{};
    for (final history in histories) {
      final date = DateTime(
        history.watchedAt.year,
        history.watchedAt.month,
        history.watchedAt.day,
      );
      watchDates.add(date);
    }

    // 연속일 계산
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    // 오늘부터 역순으로 확인
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      if (watchDates.contains(checkDate)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // 이번 주 통계
  Future<Map<String, int>> getThisWeekStats() async {
    final histories = await getHistories();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    int thisWeekCount = 0;
    int thisWeekClicks = 0;

    for (final history in histories) {
      if (history.watchedAt.isAfter(weekStartDate)) {
        thisWeekCount++;
        thisWeekClicks += history.watchCount;
      }
    }

    return {
      'videos': thisWeekCount,
      'clicks': thisWeekClicks,
    };
  }

  // 지난 주와 비교
  Future<Map<String, dynamic>> getWeekComparison() async {
    final histories = await getHistories();
    final now = DateTime.now();

    // 이번 주
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekStartDate = DateTime(thisWeekStart.year, thisWeekStart.month, thisWeekStart.day);

    // 지난 주
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekStartDate = DateTime(lastWeekStart.year, lastWeekStart.month, lastWeekStart.day);

    int thisWeekCount = 0;
    int lastWeekCount = 0;

    for (final history in histories) {
      if (history.watchedAt.isAfter(thisWeekStartDate)) {
        thisWeekCount++;
      } else if (history.watchedAt.isAfter(lastWeekStartDate) &&
                 history.watchedAt.isBefore(thisWeekStartDate)) {
        lastWeekCount++;
      }
    }

    final difference = thisWeekCount - lastWeekCount;
    final percentChange = lastWeekCount > 0
        ? ((difference / lastWeekCount) * 100).round()
        : (thisWeekCount > 0 ? 100 : 0);

    return {
      'thisWeek': thisWeekCount,
      'lastWeek': lastWeekCount,
      'difference': difference,
      'percentChange': percentChange,
      'isIncreased': difference > 0,
    };
  }

  // 가장 활발한 시간대 (Top 3)
  Future<List<MapEntry<int, int>>> getTopActiveHours() async {
    final distribution = await getHourlyDistribution();
    final sorted = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }
}
