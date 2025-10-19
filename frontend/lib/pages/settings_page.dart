import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_app_bar.dart';
import 'watch_stats_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 페이지 타이틀
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '설정',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: isDark ? Colors.white : AppTheme.deepIce,
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '앱 설정을 관리하세요',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 테마 설정 섹션
                _buildSettingsSection(
                  context: context,
                  isDark: isDark,
                  title: '테마 설정',
                  icon: Icons.palette_rounded,
                  iconColor: AppTheme.sakuraPink,
                  children: [
                    _buildThemeSelector(context, isDark),
                  ],
                ),
                const SizedBox(height: 24),

                // 알림 설정 섹션
                _buildSettingsSection(
                  context: context,
                  isDark: isDark,
                  title: '알림 설정',
                  icon: Icons.notifications_rounded,
                  iconColor: AppTheme.iceBlue,
                  children: [
                    _buildNotificationSwitch(
                      context: context,
                      isDark: isDark,
                      title: '방송 시작 알림',
                      subtitle: '이리온이 방송을 시작하면 알려드려요',
                      value: context.watch<NotificationProvider>().liveStartNotification,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        context.read<NotificationProvider>().setLiveStartNotification(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationSwitch(
                      context: context,
                      isDark: isDark,
                      title: '방송 종료 알림',
                      subtitle: '방송이 종료되면 알려드려요',
                      value: context.watch<NotificationProvider>().liveEndNotification,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        context.read<NotificationProvider>().setLiveEndNotification(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationSwitch(
                      context: context,
                      isDark: isDark,
                      title: '새 다시보기 알림',
                      subtitle: '새로운 다시보기가 올라오면 알려드려요',
                      value: context.watch<NotificationProvider>().newReplayNotification,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        context.read<NotificationProvider>().setNewReplayNotification(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationSwitch(
                      context: context,
                      isDark: isDark,
                      title: '일정 알림',
                      subtitle: '방송 30분 전에 알려드려요',
                      value: context.watch<NotificationProvider>().scheduleNotification,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        context.read<NotificationProvider>().setScheduleNotification(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 시청 통계 섹션
                _buildSettingsSection(
                  context: context,
                  isDark: isDark,
                  title: '시청 기록',
                  icon: Icons.bar_chart_rounded,
                  iconColor: AppTheme.sakuraPink,
                  children: [
                    _buildMenuButton(
                      context: context,
                      isDark: isDark,
                      title: '시청 통계',
                      subtitle: '내가 본 영상 기록을 확인하세요',
                      icon: Icons.analytics_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WatchStatsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.sakuraPink.withValues(alpha: 0.2),
                      AppTheme.iceBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.sakuraPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white : AppTheme.deepIce,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppTheme.textSecondary.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        iconColor.withValues(alpha: 0.2),
                        iconColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark ? Colors.white : AppTheme.deepIce,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    return Column(
      children: [
        _buildThemeOption(
          context: context,
          isDark: isDark,
          title: '시스템 설정',
          subtitle: '기기의 설정을 따릅니다',
          icon: Icons.brightness_auto_rounded,
          isSelected: currentMode == ThemeMode.system,
          onTap: () {
            HapticFeedback.mediumImpact();
            context.read<ThemeProvider>().setThemeMode(ThemeMode.system);
          },
        ),
        const SizedBox(height: 12),
        _buildThemeOption(
          context: context,
          isDark: isDark,
          title: '라이트 모드',
          subtitle: '밝은 테마를 사용합니다',
          icon: Icons.light_mode_rounded,
          isSelected: currentMode == ThemeMode.light,
          onTap: () {
            HapticFeedback.mediumImpact();
            context.read<ThemeProvider>().setThemeMode(ThemeMode.light);
          },
        ),
        const SizedBox(height: 12),
        _buildThemeOption(
          context: context,
          isDark: isDark,
          title: '다크 모드',
          subtitle: '어두운 테마를 사용합니다',
          icon: Icons.dark_mode_rounded,
          isSelected: currentMode == ThemeMode.dark,
          onTap: () {
            HapticFeedback.mediumImpact();
            context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
          },
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppTheme.sakuraPink.withValues(alpha: 0.15)
                    : AppTheme.sakuraPink.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.sakuraPink.withValues(alpha: 0.5)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.sakuraPink.withValues(alpha: 0.2)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.sakuraPink
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.5)),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? (isDark ? Colors.white : AppTheme.deepIce)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : AppTheme.deepIce.withValues(alpha: 0.8)),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppTheme.textSecondary.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.sakuraPink,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white : AppTheme.deepIce,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppTheme.textSecondary.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.sakuraPink,
            activeTrackColor: AppTheme.sakuraPink.withValues(alpha: 0.5),
            inactiveThumbColor: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.5),
            inactiveTrackColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}
