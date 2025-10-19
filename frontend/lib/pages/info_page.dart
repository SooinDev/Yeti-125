import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../widgets/premium_app_bar.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const PremiumAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppTheme.winterDarkGradient : AppTheme.mountainGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 프로필 카드 with animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.winterDark.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.4)
                                  : Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.white.withValues(alpha: 0.6),
                                    isDark
                                        ? Colors.white.withValues(alpha: 0.02)
                                        : Colors.white.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                              child: Column(
                                children: [
                                  // 프로필 이미지 영역
                                  _AnimatedProfileImage(
                                    controller: _controller,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 16),

                                  // 이름
                                  _AnimatedText(
                                    controller: _controller,
                                    delay: 0.1,
                                    child: Text(
                                      '이리온',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        color: isDark
                                            ? Colors.white
                                            : AppTheme.deepIce,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 26,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // 서브 타이틀
                                  _AnimatedText(
                                    controller: _controller,
                                    delay: 0.15,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.sakuraPink
                                                .withValues(alpha: 0.15),
                                            AppTheme.petalPink
                                                .withValues(alpha: 0.08),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppTheme.sakuraPink
                                              .withValues(alpha: 0.25),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '스트리머 · 크리에이터',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: isDark
                                              ? AppTheme.sakuraPink
                                                  .withValues(alpha: 0.9)
                                              : AppTheme.sakuraPink,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // 구분선
                                  Divider(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.06),
                                    thickness: 1,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 20),

                                  // 소개
                                  _AnimatedSection(
                                    controller: _controller,
                                    delay: 0.2,
                                    child: _buildInfoSection(
                                      context,
                                      title: '소개',
                                      icon: Icons.person_rounded,
                                      color: AppTheme.sakuraPink,
                                      isDark: isDark,
                                      children: [
                                        _buildInfoText(
                                          context,
                                          '봄에 태어난 설녀 ʚ✿ɞ',
                                          isDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // 활동 플랫폼
                                  _AnimatedSection(
                                    controller: _controller,
                                    delay: 0.25,
                                    child: _buildInfoSection(
                                      context,
                                      title: '활동 플랫폼',
                                      icon: Icons.connected_tv_rounded,
                                      color: AppTheme.iceBlue,
                                      isDark: isDark,
                                      children: [
                                        _buildPlatformChip(context, '치지직',
                                            AppTheme.sakuraPink, isDark),
                                        const SizedBox(width: 8),
                                        _buildPlatformChip(context, '유튜브',
                                            const Color(0xFFFF4444), isDark),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // 기본 정보
                                  _AnimatedSection(
                                    controller: _controller,
                                    delay: 0.3,
                                    child: _buildInfoSection(
                                      context,
                                      title: '기본 정보',
                                      icon: Icons.info_rounded,
                                      color: AppTheme.crystalBlue,
                                      isDark: isDark,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildDetailRow(
                                                  context, '성별', '여성', isDark),
                                              _buildDetailRow(
                                                  context, '종족', '설녀', isDark),
                                              _buildDetailRow(context, '생일',
                                                  '4월 10일', isDark),
                                              _buildDetailRow(context, '나이',
                                                  '500살', isDark),
                                              _buildDetailRow(context, '신장',
                                                  '165cm', isDark),
                                              _buildDetailRow(context, 'MBTI',
                                                  'INFJ', isDark),
                                              _buildDetailRow(context, '마마',
                                                  'Hisiya', isDark),
                                              _buildDetailRow(context, '파파',
                                                  'Doha', isDark),
                                              _buildDetailRow(context, '오시마크',
                                                  '❄️🌸', isDark),
                                              _buildDetailRow(
                                                  context, '팬네임', '예티', isDark,
                                                  isLast: true),
                                            ],
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
                  ),
                ),

                const SizedBox(height: 24),

                // D-Day 위젯
                _AnimatedSection(
                  controller: _controller,
                  delay: 0.35,
                  child: _buildDDayWidget(context, isDark),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDDayWidget(BuildContext context, bool isDark) {
    final now = DateTime.now();

    // 생일 계산 (4월 10일)
    final currentYear = now.year;
    var birthday = DateTime(currentYear, 4, 10);
    if (birthday.isBefore(now)) {
      birthday = DateTime(currentYear + 1, 4, 10);
    }
    final daysUntilBirthday = birthday.difference(now).inDays;

    // 방송 시작일로부터 계산 (2023년 9월 12일)
    final debutDate = DateTime(2023, 9, 12);
    final daysSinceDebut = now.difference(debutDate).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.winterDark.withValues(alpha: 0.7),
                  AppTheme.deepIce.withValues(alpha: 0.3),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  AppTheme.iceBlue.withValues(alpha: 0.2),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          // 타이틀
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.sakuraPink.withValues(alpha: 0.15),
                      AppTheme.petalPink.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: AppTheme.sakuraPink.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: AppTheme.sakuraPink,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '특별한 날들',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white : AppTheme.deepIce,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // D-Day 카드들
          Row(
            children: [
              // 생일 카드
              Expanded(
                child: _buildDDayCard(
                  context,
                  emoji: '🌸',
                  label: '생일',
                  days: daysUntilBirthday,
                  isPast: false,
                  color: AppTheme.sakuraPink,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              // 데뷔일 카드
              Expanded(
                child: _buildDDayCard(
                  context,
                  emoji: '❄️',
                  label: '데뷔',
                  days: daysSinceDebut,
                  isPast: true,
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

  Widget _buildDDayCard(
    BuildContext context, {
    required String emoji,
    required String label,
    required int days,
    required bool isPast,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 이모지
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          // 라벨
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          // D-Day
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: isPast ? 'D+' : 'D-',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                ),
                TextSpan(
                  text: days.toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark ? Colors.white : AppTheme.deepIce,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // 서브텍스트
          Text(
            isPast ? '$days일째' : '$days일 남음',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppTheme.textSecondary.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : AppTheme.deepIce,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(BuildContext context, String text, bool isDark) {
    return Flexible(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.75)
                  : AppTheme.textSecondary,
              fontSize: 13.5,
              height: 1.6,
              letterSpacing: -0.1,
            ),
      ),
    );
  }

  Widget _buildPlatformChip(
      BuildContext context, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              letterSpacing: -0.1,
            ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    bool isDark, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppTheme.textSecondary.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppTheme.deepIce,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// 프로필 이미지 애니메이션
class _AnimatedProfileImage extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;

  const _AnimatedProfileImage({
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
      ),
    );

    final rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Transform.rotate(
            angle: rotateAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppTheme.crystalBlue.withValues(alpha: 0.5),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.sakuraPink.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/Live-2D-Debut.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
                      ),
                      child: const Center(
                        child: Text(
                          '🌸',
                          style: TextStyle(fontSize: 50),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 텍스트 애니메이션
class _AnimatedText extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _AnimatedText({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, delay + 0.5, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}

// 섹션 애니메이션
class _AnimatedSection extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _AnimatedSection({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, delay + 0.6, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}
