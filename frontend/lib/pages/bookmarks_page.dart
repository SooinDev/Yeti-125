import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_app_bar.dart';
import 'video_player_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);

    try {
      final bookmarks = await BookmarkService().getBookmarks();
      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchBookmarks(String query) async {
    try {
      final results = await BookmarkService().searchBookmarks(query);
      setState(() {
        _bookmarks = results;
      });
    } catch (e) {
    }
  }

  Future<void> _removeBookmark(Bookmark bookmark) async {
    await BookmarkService().removeBookmark(bookmark.videoId);
    _loadBookmarks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('북마크가 삭제되었습니다'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: '확인',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> _showMemoDialog(Bookmark bookmark) async {
    final controller = TextEditingController(text: bookmark.memo);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark
              ? AppTheme.winterDark.withValues(alpha: 0.95)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '메모 편집',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.deepIce,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 10,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: '이 영상에 대한 자세한 메모를 작성하세요... (최대 2000자)',
              hintStyle: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppTheme.textSecondary.withValues(alpha: 0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.sakuraPink.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.sakuraPink,
                  width: 2,
                ),
              ),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.deepIce,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppTheme.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(
                '저장',
                style: TextStyle(
                  color: AppTheme.sakuraPink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await BookmarkService().updateMemo(bookmark.videoId, result);
      _loadBookmarks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('메모가 저장되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
        title: '북마크',
        actions: [
          PremiumActionButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              _loadBookmarks();
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

              // 검색바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchBookmarks,
                  decoration: InputDecoration(
                    hintText: '제목이나 메모로 검색...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppTheme.textSecondary.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppTheme.sakuraPink,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : AppTheme.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _loadBookmarks();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? AppTheme.winterDark.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.sakuraPink,
                        width: 2,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.deepIce,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 북마크 카운트
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      color: AppTheme.sakuraPink,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '총 ${_bookmarks.length}개',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 북마크 목록
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _bookmarks.isEmpty
                        ? _buildEmptyState(isDark)
                        : RefreshIndicator(
                            onRefresh: _loadBookmarks,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _bookmarks.length,
                              itemBuilder: (context, index) {
                                final bookmark = _bookmarks[index];
                                return _buildBookmarkCard(
                                    context, bookmark, isDark);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          Text(
            '북마크한 영상이 없습니다',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : AppTheme.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '마음에 드는 영상을 북마크해보세요',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : AppTheme.textSecondary.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(
      BuildContext context, Bookmark bookmark, bool isDark) {
    final hasThumbnail = bookmark.thumbnailUrl.isNotEmpty;
    final hasMemo = bookmark.memo.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(bookmark.videoId),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.8),
                Colors.red,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: isDark
                  ? AppTheme.winterDark.withValues(alpha: 0.95)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                '북마크 삭제',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.deepIce,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Text(
                '이 북마크를 삭제하시겠습니까?',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppTheme.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    '삭제',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          _removeBookmark(bookmark);
        },
        child: GestureDetector(
          onTap: () {
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
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.winterDark.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.9),
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
            child: Row(
              children: [
                // 썸네일
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: hasThumbnail
                      ? Image.network(
                          bookmark.thumbnailUrl,
                          width: 120,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildThumbnailPlaceholder(isDark);
                          },
                        )
                      : _buildThumbnailPlaceholder(isDark),
                ),

                // 정보
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookmark.title,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppTheme.deepIce,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasMemo) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.sakuraPink.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.note_rounded,
                                  color: AppTheme.sakuraPink,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    bookmark.memo,
                                    style: TextStyle(
                                      color: AppTheme.sakuraPink,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.bookmark_rounded,
                              color: AppTheme.sakuraPink,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(bookmark.bookmarkedAt),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 메모 버튼
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(
                      hasMemo ? Icons.edit_note_rounded : Icons.add_comment_rounded,
                      color: AppTheme.sakuraPink,
                      size: 24,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showMemoDialog(bookmark);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(bool isDark) {
    return Container(
      width: 120,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? AppTheme.winterDark.withValues(alpha: 0.8)
                : AppTheme.iceBlue.withValues(alpha: 0.3),
            isDark
                ? AppTheme.deepIce.withValues(alpha: 0.3)
                : AppTheme.sakuraPink.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Icon(
        Icons.bookmark_rounded,
        color: isDark
            ? Colors.white.withValues(alpha: 0.6)
            : AppTheme.glacierBlue,
        size: 40,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else {
      return '${date.year}.${date.month}.${date.day}';
    }
  }
}
