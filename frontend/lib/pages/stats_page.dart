import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/watch_history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_app_bar.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _totalVideos = 0;
  int _totalClicks = 0;
  int _watchStreak = 0;
  List<WatchHistory> _topWatched = [];
  Map<DateTime, int> _dailyStats = {};
  List<MapEntry<int, int>> _topActiveHours = [];
  Map<String, dynamic> _weekComparison = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final service = WatchHistoryService();

      final totalVideos = await service.getTotalWatchCount();
      final totalClicks = await service.getTotalClickCount();
      final watchStreak = await service.getWatchStreak();
      final topWatched = await service.getTopWatchedVideos(limit: 5);
      final dailyStats = await service.getDailyStats(days: 7);
      final topActiveHours = await service.getTopActiveHours();
      final weekComparison = await service.getWeekComparison();

      setState(() {
        _totalVideos = totalVideos;
        _totalClicks = totalClicks;
        _watchStreak = watchStreak;
        _topWatched = topWatched;
        _dailyStats = dailyStats;
        _topActiveHours = topActiveHours;
        _weekComparison = weekComparison;
        _isLoading = false;
      });
    } catch (e) {
      print('[통계] 로드 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PremiumAppBar(
        title: '시청 통계',
        actions: [
          PremiumActionButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              _loadStats();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppTheme.winterDarkGradient : AppTheme.mountainGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // 전체 통계 요약 카드
                        _buildSummaryCards(isDark),

                        const SizedBox(height: 24),

                        // 주간 비교
                        if (_weekComparison.isNotEmpty) ...[
                          _buildWeekComparison(isDark),
                          const SizedBox(height: 24),
                        ],

                        // 연속 시청일
                        _buildStreakCard(isDark),

                        const SizedBox(height: 24),

                        // 최근 7일 그래프
                        _buildDailyChart(isDark),

                        const SizedBox(height: 24),

                        // 시간대별 분포
                        _buildHourlyChart(isDark),

                        const SizedBox(height: 24),

                        // 최다 시청 영상 TOP 5
                        _buildTopWatchedList(isDark),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            isDark: isDark,
            title: '총 시청 영상',
            value: '$_totalVideos',
            subtitle: '개',
            icon: Icons.video_library_rounded,
            color: AppTheme.sakuraPink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark: isDark,
            title: '총 재생 횟수',
            value: '$_totalClicks',
            subtitle: '회',
            icon: Icons.play_circle_rounded,
            color: AppTheme.iceBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.deepIce,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekComparison(bool isDark) {
    final thisWeek = _weekComparison['thisWeek'] ?? 0;
    final lastWeek = _weekComparison['lastWeek'] ?? 0;
    final percentChange = _weekComparison['percentChange'] ?? 0;
    final isIncreased = _weekComparison['isIncreased'] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.petalPink.withValues(alpha: 0.15),
            AppTheme.iceBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : AppTheme.petalPink.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded,
                  color: AppTheme.petalPink, size: 24),
              const SizedBox(width: 12),
              Text(
                '이번 주 vs 지난 주',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.deepIce,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이번 주',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$thisWeek개',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.deepIce,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isIncreased ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isIncreased ? Colors.green : Colors.orange)
                        .withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isIncreased
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: isIncreased ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percentChange.abs()}%',
                      style: TextStyle(
                        color: isIncreased ? Colors.green : Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '지난 주: $lastWeek개',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.glacierBlue.withValues(alpha: 0.15),
            AppTheme.sakuraPink.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.glacierBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.glacierBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppTheme.sakuraPink,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '연속 시청일',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_watchStreak',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.deepIce,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '일 연속',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : AppTheme.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChart(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.winterDark.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  color: AppTheme.iceBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                '최근 7일 시청 기록',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.deepIce,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: _buildBarChart(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    if (_dailyStats.isEmpty) {
      return Center(
        child: Text(
          '데이터가 없습니다',
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppTheme.textSecondary,
          ),
        ),
      );
    }

    final sortedEntries = _dailyStats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxValue =
        sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final normalizedMax = maxValue > 0 ? maxValue : 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: sortedEntries.map((entry) {
        final date = entry.key;
        final count = entry.value;
        final heightRatio = count / normalizedMax;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (count > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppTheme.deepIce,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Container(
                  height: 120 * heightRatio,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.sakuraPink,
                        AppTheme.petalPink,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('E', 'ko').format(date),
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHourlyChart(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.winterDark.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  color: AppTheme.glacierBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                '가장 활발한 시간대',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.deepIce,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_topActiveHours.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '데이터가 없습니다',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            ..._topActiveHours.asMap().entries.map((entry) {
              final index = entry.key;
              final hour = entry.value.key;
              final count = entry.value.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.glacierBlue.withValues(alpha: 0.3),
                            AppTheme.iceBlue.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppTheme.glacierBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${hour}시',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.deepIce,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$count회 시청',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopWatchedList(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.winterDark.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded,
                  color: AppTheme.sakuraPink, size: 24),
              const SizedBox(width: 12),
              Text(
                '최다 시청 영상 TOP 5',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.deepIce,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_topWatched.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '데이터가 없습니다',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            ..._topWatched.asMap().entries.map((entry) {
              final index = entry.key;
              final video = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.sakuraPink.withValues(alpha: 0.3),
                            AppTheme.petalPink.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppTheme.sakuraPink,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.deepIce,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${video.watchCount}회 시청',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
