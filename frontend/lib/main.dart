import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:async';
import 'package:provider/provider.dart';
import 'schedule_page.dart';
import 'main_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'widgets/premium_app_bar.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'services/fcm_service.dart';
import 'services/watch_history_service.dart';
import 'pages/video_player_page.dart';

// 다시보기 모델
class Replay {
  final String clipId;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final int viewCount;
  final DateTime createdAt;

  Replay({
    required this.clipId,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.viewCount,
    required this.createdAt,
  });

  factory Replay.fromJson(Map<String, dynamic> json) {
    DateTime parseCreatedAt() {
      if (json['createdAt'] == null) return DateTime.now();
      final createdAtStr = json['createdAt'].toString();

      // Unix timestamp (밀리초) 형식인 경우
      if (int.tryParse(createdAtStr) != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(createdAtStr));
      }

      // ISO 8601 형식인 경우
      try {
        return DateTime.parse(createdAtStr);
      } catch (e) {
        return DateTime.now();
      }
    }

    return Replay(
      clipId: json['clipId'] ?? '',
      title: json['title'] ?? '제목 없음',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      createdAt: parseCreatedAt(),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR');

  // 릴리즈 모드인지에 따라 프로덕션/개발 환경 설정
  if (kReleaseMode) {
    AppConfig.setEnvironment(Environment.production);
  } else {
    AppConfig.setEnvironment(Environment.development);
  }

  // FCM 초기화
  await FCMService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 빠른 앱 시작을 위해 딜레이 제거
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Yeti 125',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: _isLoading ? const SplashScreen() : const MainWrapper(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppTheme.winterDarkGradient : AppTheme.mountainGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.sakuraPink.withValues(alpha: 0.3),
                          AppTheme.iceBlue.withValues(alpha: 0.3),
                        ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : AppTheme.crystalBlue.withValues(alpha: 0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.sakuraPink.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '❄️',
                        style: TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Yeti 125',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.deepIce,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '이리온의 방송을 기다리는 중...',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String _statusMessage = '확인 중...';
  String? _liveImageUrl;
  bool _isLive = false;
  String? _channelId;
  String? _channelName;
  int? _concurrentUserCount;
  int _imageRefreshKey = 0;
  List<WatchHistory> _recentWatched = [];
  bool _showAllHistory = false;
  List<Replay> _replays = [];
  bool _showAllReplays = false;
  late AnimationController _breathingAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _glowAnimationController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowAnimation;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();

    // Premium animation controllers with sophisticated timing
    _breathingAnimationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Premium curved animations with Apple-grade easing
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _breathingAnimationController,
      curve: Curves.easeInOutSine,
    ));

    _floatingAnimation = Tween<double>(
      begin: -20.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOutSine,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOutSine,
    ));

    // Orchestrated animation sequence for premium feel
    _breathingAnimationController.repeat(reverse: true);
    _floatingAnimationController.repeat(reverse: true);
    _glowAnimationController.repeat(reverse: true);

    _checkServerConnection();
    _loadRecentWatched();
    _fetchReplays();

    // 1분마다 방송 상태만 확인
    _statusCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkServerConnection();
    });
  }

  Future<void> _loadRecentWatched() async {
    try {
      final histories =
          await WatchHistoryService().getRecentWatchedVideos(limit: 20);

      setState(() {
        _recentWatched = histories;
      });
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _fetchReplays() async {
    try {
      final apiUrl = '${AppConfig.baseUrl}/api/stream/replays';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedResponse);

        setState(() {
          _replays = data.map((json) => Replay.fromJson(json)).toList();
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _breathingAnimationController.dispose();
    _floatingAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkServerConnection() async {
    setState(() {
      _statusMessage = '❄️ 확인 중... ❄️';
    });

    try {
      final apiUrl = '${AppConfig.baseUrl}/api/stream/live-status';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedResponse);

        final status = data['status'] ?? 'UNKNOWN';
        final liveImageUrl = data['liveImageUrl'];
        final channelId = data['channelId'];
        final channelName = data['channelName'];
        final concurrentUserCount = data['concurrentUserCount'];

        setState(() {
          _isLive = (status == 'OPEN' || status == 'LIVE');
          _channelId = channelId;
          _channelName = channelName;
          _concurrentUserCount = concurrentUserCount;
          _imageRefreshKey = DateTime.now().millisecondsSinceEpoch;

          if (liveImageUrl != null && liveImageUrl.contains('{type}')) {
            _liveImageUrl = liveImageUrl.replaceAll('{type}', '720');
          } else {
            _liveImageUrl = liveImageUrl;
          }

          if (_isLive) {
            _statusMessage = '🌸 방송 중! 🌸';
          } else if (status == 'CLOSE' || status == 'OFFLINE') {
            _statusMessage = '방송이 꺼져있습니다';
          } else {
            _statusMessage = '✨ 서버 연결됨 (상태: $status) ✨';
          }
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _statusMessage = '🔍 서버에 /api/stream/live-status 엔드포인트가 없어요 (404)';
        });
      } else {
        setState(() {
          _statusMessage = '⚠️ 서버 오류 (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('Connection refused') ||
            e.toString().contains('No route to host')) {
          _statusMessage = '서버 연결 불가';
        } else if (e.toString().contains('TimeoutException')) {
          _statusMessage = '서버 연결 불가 (오프라인)';
        } else {
          _statusMessage = '네트워크 연결 확인 필요';
        }
      });
    }
  }

  Future<void> _launchChzzkUrl() async {
    if (_channelId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채널 정보를 불러올 수 없습니다')),
        );
      }
      return;
    }

    // WebView로 라이브 방송 열기
    final liveUrl = 'https://chzzk.naver.com/live/$_channelId';
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerPage(
            videoUrl: liveUrl,
            videoTitle: _isLive
                ? '🔴 LIVE - ${_channelName ?? '방송'}'
                : (_channelName ?? '방송'),
          ),
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
        actions: [
          PremiumActionButton(
            icon: Icons.calendar_today_rounded,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SchedulePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOutCubic)),
                      ),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 140,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // 이리온 방송 상태 텍스트
                  Text(
                    '❄️ 이리온 방송 상태 🌸',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white : AppTheme.deepIce,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // 방송이 켜져있는지에 대한 텍스트박스
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: _isLive
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.sakuraPink.withValues(alpha: 0.15),
                                    AppTheme.iceBlue.withValues(alpha: 0.12),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    _getStatusColor(isDark)
                                        .withValues(alpha: 0.15),
                                    _getStatusColor(isDark)
                                        .withValues(alpha: 0.15),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isLive
                                ? AppTheme.sakuraPink.withValues(
                                    alpha: 0.25 + (0.15 * _glowAnimation.value))
                                : Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: _isLive
                              ? [
                                  BoxShadow(
                                    color: AppTheme.sakuraPink.withValues(
                                        alpha: 0.2 * _glowAnimation.value),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLive) ...[
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.sakuraPink,
                                      AppTheme.sakuraPink
                                          .withValues(alpha: 0.7),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.sakuraPink.withValues(
                                          alpha: 0.5 * _glowAnimation.value),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                            ],
                            Flexible(
                              child: Text(
                                _statusMessage,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: _isLive
                                      ? (isDark
                                          ? Colors.white
                                          : AppTheme.deepIce)
                                      : (isDark
                                          ? Colors.white
                                          : AppTheme.deepIce),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_isLive) ...[
                              const SizedBox(width: 14),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.sakuraPink,
                                      AppTheme.sakuraPink
                                          .withValues(alpha: 0.7),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.sakuraPink.withValues(
                                          alpha: 0.5 * _glowAnimation.value),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // 방송 썸네일 또는 방송 종료 텍스트
                  if (_isLive &&
                      _liveImageUrl != null &&
                      _liveImageUrl!.isNotEmpty)
                    AnimatedBuilder(
                      animation: _breathingAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale:
                              1.0 + ((_breathingAnimation.value - 1.0) * 0.15),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              _launchChzzkUrl();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.sakuraPink.withValues(alpha: 0.15),
                                    AppTheme.iceBlue.withValues(alpha: 0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : AppTheme.sakuraPink
                                          .withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.sakuraPink.withValues(
                                        alpha: 0.25 *
                                            (_breathingAnimation.value - 0.92)),
                                    blurRadius: 32,
                                    offset: const Offset(0, 12),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: -4,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      '${_liveImageUrl!}?refresh=$_imageRefreshKey',
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 200,
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            color: AppTheme.sakuraPink,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline_rounded,
                                                color: isDark
                                                    ? Colors.white
                                                        .withValues(alpha: 0.5)
                                                    : AppTheme.textSecondary,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                '이미지를 불러올 수 없습니다',
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: isDark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.7)
                                                      : AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    // LIVE 뱃지 (좌측 상단)
                                    Positioned(
                                      left: 16,
                                      top: 16,
                                      child: AnimatedBuilder(
                                        animation: _glowAnimation,
                                        builder: (context, child) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 10, sigmaY: 10),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.black.withValues(
                                                          alpha: 0.7),
                                                      Colors.black.withValues(
                                                          alpha: 0.5),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.2),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme.sakuraPink
                                                          .withValues(
                                                              alpha: 0.3 *
                                                                  _glowAnimation
                                                                      .value),
                                                      blurRadius: 16,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            AppTheme.sakuraPink,
                                                            AppTheme.sakuraPink
                                                                .withValues(
                                                                    alpha: 0.8),
                                                          ],
                                                        ),
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: AppTheme
                                                                .sakuraPink
                                                                .withValues(
                                                                    alpha: 0.6 *
                                                                        _glowAnimation
                                                                            .value),
                                                            blurRadius: 8,
                                                            spreadRadius: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'LIVE',
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 13,
                                                        letterSpacing: 0.8,
                                                      ),
                                                    ),
                                                    if (_concurrentUserCount !=
                                                        null) ...[
                                                      const SizedBox(width: 12),
                                                      Container(
                                                        width: 1,
                                                        height: 14,
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.3),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Icon(
                                                        Icons
                                                            .visibility_rounded,
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.9),
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        '${_concurrentUserCount}',
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // 클릭 유도 오버레이 (우측 하단)
                                    Positioned(
                                      right: 16,
                                      bottom: 16,
                                      child: AnimatedBuilder(
                                        animation: _breathingAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: 1.0 +
                                                ((_breathingAnimation.value -
                                                        1.0) *
                                                    0.4),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 10, sigmaY: 10),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        AppTheme.sakuraPink
                                                            .withValues(
                                                                alpha: 0.9),
                                                        AppTheme.sakuraPink
                                                            .withValues(
                                                                alpha: 0.7),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.3),
                                                      width: 1.5,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppTheme
                                                            .sakuraPink
                                                            .withValues(
                                                                alpha: 0.4 *
                                                                    _breathingAnimation
                                                                        .value),
                                                        blurRadius: 20,
                                                        offset:
                                                            const Offset(0, 6),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .play_arrow_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        '방송 보러가기',
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14,
                                                          letterSpacing: -0.3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // 전체 화면 그라데이션 오버레이 (하단)
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      height: 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black
                                                  .withValues(alpha: 0.3),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  if (!_isLive)
                    AspectRatio(
                      aspectRatio: 16 / 12,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : AppTheme.iceBlue.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.iceBlue.withValues(alpha: 0.15),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          AppTheme.deepIce
                                              .withValues(alpha: 0.15),
                                          AppTheme.iceBlue
                                              .withValues(alpha: 0.08),
                                          AppTheme.deepIce
                                              .withValues(alpha: 0.15),
                                        ]
                                      : [
                                          Colors.white.withValues(alpha: 0.9),
                                          AppTheme.iceBlue
                                              .withValues(alpha: 0.15),
                                          Colors.white.withValues(alpha: 0.9),
                                        ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // 배경 패턴
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter:
                                          _WinterPatternPainter(isDark: isDark),
                                    ),
                                  ),
                                  // 떠다니는 눈송이들
                                  ...List.generate(12, (index) {
                                    final offset = (index * 0.25) % 1.0;
                                    return AnimatedBuilder(
                                      animation: _floatingAnimation,
                                      builder: (context, child) {
                                        final position =
                                            (_floatingAnimation.value +
                                                    offset * 100) %
                                                120;
                                        return Positioned(
                                          left: (index * 40.0) % 380,
                                          top: position - 20,
                                          child: Opacity(
                                            opacity: 0.2,
                                            child: Text(
                                              '❄️',
                                              style: TextStyle(
                                                fontSize: 20 + (index % 3) * 8,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                  // 얼음 결정 효과
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _IceCrystalPainter(
                                        animation: _glowAnimation,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ),
                                  // 중앙 컨텐츠
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 이리온 아이콘
                                        AnimatedBuilder(
                                          animation: _breathingAnimation,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: 0.95 +
                                                  (_breathingAnimation.value -
                                                          1.0) *
                                                      0.5,
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      AppTheme.sakuraPink
                                                          .withValues(
                                                              alpha: 0.3),
                                                      AppTheme.iceBlue
                                                          .withValues(
                                                              alpha: 0.3),
                                                    ],
                                                  ),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? Colors.white
                                                            .withValues(
                                                                alpha: 0.3)
                                                        : AppTheme.crystalBlue
                                                            .withValues(
                                                                alpha: 0.5),
                                                    width: 2.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme.sakuraPink
                                                          .withValues(
                                                              alpha: 0.3),
                                                      blurRadius: 20 *
                                                          _breathingAnimation
                                                              .value,
                                                      spreadRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '❄️',
                                                    style:
                                                        TextStyle(fontSize: 50),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 32),
                                        // 메인 메시지
                                        Text(
                                          '이리온이 곧 돌아옵니다',
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                            color: isDark
                                                ? Colors.white
                                                : AppTheme.deepIce,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 26,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // 서브 메시지
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppTheme.sakuraPink
                                                    .withValues(alpha: 0.15),
                                                AppTheme.petalPink
                                                    .withValues(alpha: 0.08),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppTheme.sakuraPink
                                                  .withValues(alpha: 0.25),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '다음 방송을 기다려주세요 ❄️',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: isDark
                                                  ? AppTheme.sakuraPink
                                                      .withValues(alpha: 0.9)
                                                  : AppTheme.sakuraPink,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // 일정 안내
                                        Text(
                                          '방송 일정은 일정 탭에서 확인하세요',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.5)
                                                : AppTheme.textSecondary
                                                    .withValues(alpha: 0.7),
                                            fontSize: 13,
                                            letterSpacing: -0.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 60),

                  // 구분선
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 다시보기 섹션 헤더
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.sakuraPink.withValues(alpha: 0.2),
                                    AppTheme.petalPink.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.sakuraPink.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.sakuraPink.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.video_library_rounded,
                                color: AppTheme.sakuraPink,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '다시보기',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: isDark ? Colors.white : AppTheme.deepIce,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '지난 방송 영상 모음',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 다시보기 그리드
                  _replays.isEmpty
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam_off_rounded,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : AppTheme.textSecondary.withValues(alpha: 0.6),
                                size: 56,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '다시보기 준비 중',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '곧 멋진 영상들이 업로드됩니다',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : AppTheme.textSecondary.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                                itemCount: _showAllReplays
                                    ? _replays.length
                                    : (_replays.length > 6 ? 6 : _replays.length),
                                itemBuilder: (context, index) {
                                  final replay = _replays[index];
                                  return _buildReplayCard(context, replay, isDark);
                                },
                              ),
                              if (_replays.length > 6 && !_showAllReplays) ...[
                                const SizedBox(height: 24),
                                Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        setState(() {
                                          _showAllReplays = true;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.sakuraPink.withValues(alpha: 0.25),
                                              AppTheme.petalPink.withValues(alpha: 0.15),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppTheme.sakuraPink.withValues(alpha: 0.4),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.sakuraPink.withValues(alpha: 0.2),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.expand_more_rounded,
                                              color: AppTheme.sakuraPink,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '더보기 (${_replays.length - 6}개 더)',
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                color: AppTheme.sakuraPink,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                  const SizedBox(height: 60),

                  // 구분선
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 최근 본 영상 섹션 헤더
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.iceBlue.withValues(alpha: 0.2),
                                    AppTheme.sakuraPink.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppTheme.iceBlue.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.iceBlue
                                        .withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                color: AppTheme.iceBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '최근 본 영상',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.deepIce,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '내가 시청한 영상 목록',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 최근 본 영상 그리드
                  _recentWatched.isEmpty
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 56,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : AppTheme.textSecondary
                                        .withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '시청 기록이 없습니다',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '영상을 시청하면 여기에 표시됩니다',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : AppTheme.textSecondary
                                          .withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                                itemCount: _showAllHistory
                                    ? _recentWatched.length
                                    : (_recentWatched.length > 6
                                        ? 6
                                        : _recentWatched.length),
                                itemBuilder: (context, index) {
                                  final history = _recentWatched[index];
                                  return _buildHistoryGridCard(
                                      context, history, isDark);
                                },
                              ),
                              if (_recentWatched.length > 6 &&
                                  !_showAllHistory) ...[
                                const SizedBox(height: 24),
                                Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        setState(() {
                                          _showAllHistory = true;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.iceBlue
                                                  .withValues(alpha: 0.25),
                                              AppTheme.sakuraPink
                                                  .withValues(alpha: 0.15),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppTheme.iceBlue
                                                .withValues(alpha: 0.4),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.iceBlue
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.expand_more_rounded,
                                              color: AppTheme.iceBlue,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '더보기 (${_recentWatched.length - 6}개 더)',
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                color: AppTheme.iceBlue,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                  const SizedBox(height: 40),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _breathingAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: 0.95 + (_breathingAnimation.value - 1.0) * 0.3,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.sakuraPink,
                    AppTheme.petalPink,
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.sakuraPink
                        .withValues(alpha: 0.4 * _glowAnimation.value),
                    blurRadius: 20 + (_glowAnimation.value * 15),
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(32),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _checkServerConnection();
                  },
                  borderRadius: BorderRadius.circular(32),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(bool isDark) {
    if (_statusMessage.contains('방송 중') || _statusMessage.contains('켜졌다')) {
      return AppTheme.sakuraPink;
    } else if (_statusMessage.contains('종료')) {
      return AppTheme.iceBlue;
    } else {
      return AppTheme.glacierBlue;
    }
  }

  Widget _buildHistoryGridCard(
      BuildContext context, WatchHistory history, bool isDark) {
    final hasThumbnail = history.thumbnailUrl.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();

        // 시청 기록 저장
        await WatchHistoryService().addHistory(
          videoId: history.videoId,
          title: history.title,
          thumbnailUrl: history.thumbnailUrl,
        );

        // WebView로 영상 재생
        final videoUrl = 'https://chzzk.naver.com/video/${history.videoId}';
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerPage(
                videoUrl: videoUrl,
                videoTitle: history.title,
              ),
            ),
          );
        }
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
              color: AppTheme.iceBlue.withValues(alpha: 0.1),
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
              // 썸네일
              Expanded(
                child: Stack(
                  children: [
                    hasThumbnail
                        ? Image.network(
                            history.thumbnailUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      isDark
                                          ? AppTheme.winterDark
                                              .withValues(alpha: 0.8)
                                          : AppTheme.iceBlue
                                              .withValues(alpha: 0.3),
                                      isDark
                                          ? AppTheme.deepIce
                                              .withValues(alpha: 0.3)
                                          : AppTheme.sakuraPink
                                              .withValues(alpha: 0.2),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.history_rounded,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : AppTheme.glacierBlue,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  isDark
                                      ? AppTheme.winterDark
                                          .withValues(alpha: 0.8)
                                      : AppTheme.iceBlue.withValues(alpha: 0.3),
                                  isDark
                                      ? AppTheme.deepIce.withValues(alpha: 0.3)
                                      : AppTheme.sakuraPink
                                          .withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.history_rounded,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : AppTheme.glacierBlue,
                                size: 40,
                              ),
                            ),
                          ),
                    // 재생 아이콘
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 제목 및 정보
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.winterDark.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.deepIce,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : AppTheme.textSecondary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${history.watchCount}회 시청',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplayCard(BuildContext context, Replay replay, bool isDark) {
    final hasThumbnail = replay.thumbnailUrl.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();

        // 시청 기록 저장
        await WatchHistoryService().addHistory(
          videoId: replay.clipId,
          title: replay.title,
          thumbnailUrl: replay.thumbnailUrl,
        );

        // WebView로 영상 재생
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerPage(
                videoUrl: replay.videoUrl,
                videoTitle: replay.title,
              ),
            ),
          );
        }
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
              // 썸네일
              Expanded(
                child: Stack(
                  children: [
                    hasThumbnail
                        ? Image.network(
                            replay.thumbnailUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
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
                                child: Center(
                                  child: Icon(
                                    Icons.video_library_rounded,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : AppTheme.glacierBlue,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
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
                            child: Center(
                              child: Icon(
                                Icons.video_library_rounded,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : AppTheme.glacierBlue,
                                size: 40,
                              ),
                            ),
                          ),
                    // 재생 아이콘
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 제목 및 정보
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.winterDark.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      replay.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.deepIce,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : AppTheme.textSecondary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${replay.viewCount}회',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// 겨울/벚꽃 테마 배경 패턴 페인터
class _WinterPatternPainter extends CustomPainter {
  final bool isDark;

  _WinterPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDark ? Colors.white : AppTheme.deepIce;

    // 부드러운 그리드 패턴
    final gridPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridSize = 50.0;
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        gridPaint,
      );
    }
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        gridPaint,
      );
    }

    // 중앙 원형 파동 패턴
    final wavePaint = Paint()
      ..color = AppTheme.sakuraPink.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(
        center,
        i * 60.0,
        wavePaint,
      );
    }

    // 코너 장식 패턴
    final decorPaint = Paint()
      ..color = AppTheme.iceBlue.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // 좌상단
    canvas.drawCircle(Offset(0, 0), 80, decorPaint);
    // 우하단
    canvas.drawCircle(Offset(size.width, size.height), 80, decorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 얼음 결정 효과 페인터
class _IceCrystalPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  _IceCrystalPainter({
    required this.animation,
    required this.isDark,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppTheme.iceBlue : AppTheme.deepIce)
          .withValues(alpha: 0.1 * animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    // 육각형 얼음 결정 그리기 (6개의 가지)
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0) * 3.14159 / 180.0;
      final length = 60.0;

      // 메인 가지
      final endX = center.dx + length * cos(angle);
      final endY = center.dy + length * sin(angle);
      canvas.drawLine(
        center,
        Offset(endX, endY),
        paint,
      );

      // 작은 가지들
      for (int j = 1; j <= 2; j++) {
        final branchLength = 20.0;
        final branchPos = length * (j / 3.0);
        final branchStartX = center.dx + branchPos * cos(angle);
        final branchStartY = center.dy + branchPos * sin(angle);

        // 왼쪽 작은 가지
        final leftAngle = angle - 0.5;
        canvas.drawLine(
          Offset(branchStartX, branchStartY),
          Offset(
            branchStartX + branchLength * cos(leftAngle),
            branchStartY + branchLength * sin(leftAngle),
          ),
          paint,
        );

        // 오른쪽 작은 가지
        final rightAngle = angle + 0.5;
        canvas.drawLine(
          Offset(branchStartX, branchStartY),
          Offset(
            branchStartX + branchLength * cos(rightAngle),
            branchStartY + branchLength * sin(rightAngle),
          ),
          paint,
        );
      }
    }

    // 중심 육각형
    final hexPaint = Paint()
      ..color = (isDark ? AppTheme.iceBlue : AppTheme.deepIce)
          .withValues(alpha: 0.15 * animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0) * 3.14159 / 180.0;
      final radius = 15.0;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, hexPaint);
  }

  double cos(double angle) => math.cos(angle);
  double sin(double angle) => math.sin(angle);

  @override
  bool shouldRepaint(covariant _IceCrystalPainter oldDelegate) =>
      animation != oldDelegate.animation;
}
