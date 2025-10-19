import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/watch_history_service.dart';
import '../theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'video_player_page.dart';

class WatchStatsPage extends StatefulWidget {
  const WatchStatsPage({super.key});

  @override
  State<WatchStatsPage> createState() => _WatchStatsPageState();
}

class _WatchStatsPageState extends State<WatchStatsPage> {
  final WatchHistoryService _historyService = WatchHistoryService();
  int _totalVideos = 0;
  int _totalClicks = 0;
  List<WatchHistory> _topVideos = [];
  List<WatchHistory> _recentVideos = [];
  bool _isLoading = true;

  // 고급 통계
  int _watchStreak = 0;
  Map<String, dynamic> _weekComparison = {};
  Map<DateTime, int> _dailyStats = {};
  Map<int, int> _hourlyDistribution = {};
  List<MapEntry<int, int>> _topActiveHours = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    final totalVideos = await _historyService.getTotalWatchCount();
    final totalClicks = await _historyService.getTotalClickCount();
    final topVideos = await _historyService.getTopWatchedVideos(limit: 5);
    final recentVideos =
        await _historyService.getRecentWatchedVideos(limit: 10);

    // 고급 통계 로드
    final watchStreak = await _historyService.getWatchStreak();
    final weekComparison = await _historyService.getWeekComparison();
    final dailyStats = await _historyService.getDailyStats(days: 7);
    final hourlyDistribution = await _historyService.getHourlyDistribution();
    final topActiveHours = await _historyService.getTopActiveHours();

    setState(() {
      _totalVideos = totalVideos;
      _totalClicks = totalClicks;
      _topVideos = topVideos;
      _recentVideos = recentVideos;
      _watchStreak = watchStreak;
      _weekComparison = weekComparison;
      _dailyStats = dailyStats;
      _hourlyDistribution = hourlyDistribution;
      _topActiveHours = topActiveHours;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('시청 기록 삭제'),
        content: const Text('모든 시청 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('시청 기록이 삭제되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('시청 통계'),
        actions: [
          if (_totalVideos > 0)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearHistory,
              tooltip: '기록 삭제',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _totalVideos == 0
              ? _buildEmptyState(isDark)
              : _buildStatsContent(isDark),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 80,
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            '아직 시청한 영상이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '영상을 시청하면 여기에 통계가 표시됩니다',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 요약 통계
          _buildSummaryCard(isDark),
          const SizedBox(height: 24),

          // 연속 시청일 & 주간 비교
          if (_watchStreak > 0 || _weekComparison.isNotEmpty) ...[
            _buildStreakAndTrendCard(isDark),
            const SizedBox(height: 24),
          ],

          // 일별 시청 그래프
          if (_dailyStats.isNotEmpty) ...[
            _buildSectionHeader('최근 7일 시청 활동', isDark),
            const SizedBox(height: 12),
            _buildDailyChart(isDark),
            const SizedBox(height: 24),
          ],

          // 시간대별 분포
          if (_hourlyDistribution.isNotEmpty) ...[
            _buildSectionHeader('시간대별 시청 분포', isDark),
            const SizedBox(height: 12),
            _buildHourlyChart(isDark),
            const SizedBox(height: 12),
            if (_topActiveHours.isNotEmpty) _buildTopActiveHours(isDark),
            const SizedBox(height: 24),
          ],

          // 가장 많이 본 영상
          if (_topVideos.isNotEmpty) ...[
            _buildSectionHeader('가장 많이 본 영상', isDark),
            const SizedBox(height: 12),
            ..._topVideos.map(
                (video) => _buildVideoCard(video, isDark, showCount: true)),
            const SizedBox(height: 24),
          ],

          // 최근 본 영상
          if (_recentVideos.isNotEmpty) ...[
            _buildSectionHeader('최근 본 영상', isDark),
            const SizedBox(height: 12),
            ..._recentVideos.map(
                (video) => _buildVideoCard(video, isDark, showCount: false)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.sakuraPink.withValues(alpha: 0.15),
                  AppTheme.iceBlue.withValues(alpha: 0.15),
                ]
              : [
                  AppTheme.sakuraPink.withValues(alpha: 0.1),
                  AppTheme.iceBlue.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.play_circle_outline,
                  label: '총 시청 영상',
                  value: '$_totalVideos개',
                  color: AppTheme.sakuraPink,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.touch_app_rounded,
                  label: '총 클릭 횟수',
                  value: '$_totalClicks회',
                  color: AppTheme.iceBlue,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppTheme.deepIce,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.sakuraPink, AppTheme.iceBlue],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppTheme.deepIce,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(WatchHistory video, bool isDark,
      {required bool showCount}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();

            // WebView로 영상 재생
            final videoUrl = 'https://chzzk.naver.com/video/${video.videoId}';
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(
                    videoUrl: videoUrl,
                    videoTitle: video.title,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                // 썸네일
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: video.thumbnailUrl.isNotEmpty
                      ? Image.network(
                          video.thumbnailUrl,
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(60),
                        )
                      : _buildPlaceholder(60),
                ),
                const SizedBox(width: 12),
                // 제목 및 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.deepIce,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (showCount)
                        Text(
                          '${video.watchCount}회 시청',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.sakuraPink,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          _formatDate(video.watchedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_arrow_rounded,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double height) {
    return Container(
      width: 80,
      height: height,
      color: Colors.grey.withValues(alpha: 0.2),
      child: const Icon(Icons.videocam_off_rounded, color: Colors.grey),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';

    return '${date.month}월 ${date.day}일';
  }

  // 연속 시청일 & 주간 트렌드 카드
  Widget _buildStreakAndTrendCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.iceBlue.withValues(alpha: 0.15),
                  AppTheme.sakuraPink.withValues(alpha: 0.15),
                ]
              : [
                  AppTheme.iceBlue.withValues(alpha: 0.1),
                  AppTheme.sakuraPink.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // 연속 시청일
          if (_watchStreak > 0) ...[
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: AppTheme.sakuraPink,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_watchStreak일',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.deepIce,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '연속 시청',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // 구분선
          if (_watchStreak > 0 && _weekComparison.isNotEmpty)
            Container(
              width: 1,
              height: 60,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          // 주간 트렌드
          if (_weekComparison.isNotEmpty) ...[
            Expanded(
              child: Column(
                children: [
                  Icon(
                    _weekComparison['isIncreased']
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: _weekComparison['isIncreased']
                        ? AppTheme.iceBlue
                        : AppTheme.sakuraPink,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_weekComparison['difference'] > 0 ? '+' : ''}${_weekComparison['difference']}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.deepIce,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_weekComparison['percentChange']}%)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppTheme.deepIce.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '지난주 대비',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 일별 시청 그래프
  Widget _buildDailyChart(bool isDark) {
    final sortedEntries = _dailyStats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (sortedEntries
                      .map((e) => e.value)
                      .reduce((a, b) => a > b ? a : b) +
                  2)
              .toDouble(),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < sortedEntries.length) {
                    final date = sortedEntries[value.toInt()].key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${date.month}/${date.day}',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(sortedEntries.length, (index) {
            final value = sortedEntries[index].value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value.toDouble(),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.sakuraPink,
                      AppTheme.iceBlue,
                    ],
                  ),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // 시간대별 분포 그래프
  Widget _buildHourlyChart(bool isDark) {
    final maxValue = _hourlyDistribution.values.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${value.toInt()}시',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 23,
          minY: 0,
          maxY: (maxValue + 2).toDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(24, (hour) {
                return FlSpot(
                  hour.toDouble(),
                  _hourlyDistribution[hour]!.toDouble(),
                );
              }),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.iceBlue,
                  AppTheme.sakuraPink,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.iceBlue.withValues(alpha: 0.3),
                    AppTheme.sakuraPink.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 가장 활발한 시간대 표시
  Widget _buildTopActiveHours(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가장 활발한 시간대',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.deepIce,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _topActiveHours.map((entry) {
              final hour = entry.key;
              final count = entry.value;
              return Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.iceBlue.withValues(alpha: 0.2),
                          AppTheme.sakuraPink.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.iceBlue.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '$hour시',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.deepIce,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$count회',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
