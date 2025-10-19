import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/watch_history_service.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_app_bar.dart';
import 'video_player_page.dart';
import 'package:intl/intl.dart';

class MyActivityPage extends StatefulWidget {
  const MyActivityPage({super.key});

  @override
  State<MyActivityPage> createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Stats data
  int _totalVideos = 0;
  int _totalClicks = 0;
  int _watchStreak = 0;
  List<WatchHistory> _topWatched = [];

  // Bookmarks data
  List<Bookmark> _bookmarks = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load stats
      final service = WatchHistoryService();
      final totalVideos = await service.getTotalWatchCount();
      final totalClicks = await service.getTotalClickCount();
      final watchStreak = await service.getWatchStreak();
      final topWatched = await service.getTopWatchedVideos(limit: 10);

      // Load bookmarks
      final bookmarks = await BookmarkService().getBookmarks();

      setState(() {
        _totalVideos = totalVideos;
        _totalClicks = totalClicks;
        _watchStreak = watchStreak;
        _topWatched = topWatched;
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeBookmark(Bookmark bookmark) async {
    await BookmarkService().removeBookmark(bookmark.videoId);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('북마크가 삭제되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
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
        title: '내 활동',
        actions: [
          PremiumActionButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              _loadData();
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
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.winterDark.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.sakuraPink,
                        AppTheme.petalPink,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppTheme.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: '시청 통계'),
                    Tab(text: '북마크'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Views
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildStatsView(isDark, theme),
                          _buildBookmarksView(isDark, theme),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsView(bool isDark, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '총 시청',
                    '$_totalVideos개',
                    Icons.play_circle_outline_rounded,
                    [AppTheme.sakuraPink, AppTheme.petalPink],
                    isDark,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '총 클릭',
                    '$_totalClicks회',
                    Icons.touch_app_rounded,
                    [AppTheme.iceBlue, AppTheme.crystalBlue],
                    isDark,
                    theme,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildStatCard(
              '연속 시청',
              '$_watchStreak일',
              Icons.local_fire_department_rounded,
              [Colors.orange, Colors.deepOrange],
              isDark,
              theme,
              fullWidth: true,
            ),

            const SizedBox(height: 24),

            // Top Watched Videos
            Text(
              '자주 본 영상',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDark ? Colors.white : AppTheme.deepIce,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 12),

            if (_topWatched.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    '시청 기록이 없습니다',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _topWatched.length,
                itemBuilder: (context, index) {
                  final video = _topWatched[index];
                  return _buildTopVideoCard(video, index + 1, isDark, theme);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksView(bool isDark, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '북마크한 영상이 없습니다',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = _bookmarks[index];
                return _buildBookmarkCard(bookmark, isDark, theme);
              },
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    List<Color> gradientColors,
    bool isDark,
    ThemeData theme, {
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withValues(alpha: isDark ? 0.2 : 0.15),
            gradientColors[1].withValues(alpha: isDark ? 0.1 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors[0].withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : AppTheme.deepIce,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopVideoCard(
      WatchHistory video, int rank, bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.winterDark.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.sakuraPink.withValues(alpha: 0.3),
                  AppTheme.iceBlue.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : AppTheme.deepIce,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white : AppTheme.deepIce,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${video.watchCount}회 시청',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
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
  }

  Widget _buildBookmarkCard(Bookmark bookmark, bool isDark, ThemeData theme) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final videoUrl = 'https://chzzk.naver.com/video/${bookmark.videoId}';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(
              videoUrl: videoUrl,
              videoTitle: bookmark.title,
            ),
          ),
        );
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _removeBookmark(bookmark);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.sakuraPink.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                child: Stack(
                  children: [
                    bookmark.thumbnailUrl.isNotEmpty
                        ? Image.network(
                            bookmark.thumbnailUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.sakuraPink
                                          .withValues(alpha: 0.2),
                                      AppTheme.iceBlue.withValues(alpha: 0.2),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.bookmark_rounded,
                                    color: AppTheme.sakuraPink,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.sakuraPink.withValues(alpha: 0.2),
                                  AppTheme.iceBlue.withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.bookmark_rounded,
                                color: AppTheme.sakuraPink,
                                size: 40,
                              ),
                            ),
                          ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.sakuraPink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bookmark_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Title
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.winterDark.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.9),
                ),
                child: Text(
                  bookmark.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.deepIce,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
