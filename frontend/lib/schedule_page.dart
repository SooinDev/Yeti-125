import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'theme/app_theme.dart';
import 'config/app_config.dart';
import 'widgets/premium_app_bar.dart';

// 1. 서버에서 받아온 일정 데이터를 담을 모델 클래스
class Schedule {
  final String title;
  final DateTime scheduledStartTime;
  final String description;

  Schedule({
    required this.title,
    required this.scheduledStartTime,
    required this.description,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      title: json['title'] ?? '제목 없음',
      scheduledStartTime: DateTime.parse(json['scheduledStartTime']),
      description: json['description'] ?? '',
    );
  }
}

// 2. 일정 페이지 UI
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _isLoading = true;
  List<Schedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    await _fetchSchedulesWithRetry();
  }

  Future<void> _fetchSchedulesWithRetry() async {
    const int maxRetries = 3;
    const Duration timeout = Duration(seconds: 15);
    final url = Uri.parse('${AppConfig.baseUrl}/api/schedules');

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.get(url).timeout(timeout);
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
          setState(() {
            _schedules = data.map((json) => Schedule.fromJson(json)).toList();
            _isLoading = false;
          });
          return;
        } else {
          if (attempt == maxRetries) {
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('일정을 불러올 수 없습니다. (오류 코드: ${response.statusCode})'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (attempt == maxRetries) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('서버에 연결할 수 없습니다. 네트워크 상태를 확인해주세요.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PremiumAppBar(
        leading: PremiumActionButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.winterDarkGradient : AppTheme.mountainGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: theme.primaryColor,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '❄️ 일정을 불러오고 있습니다... 🌸',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _schedules.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 48,
                              color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.black.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '❄️ 예정된 방송이 없습니다 ❄️',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '🌸 새로운 방송 일정이 추가되면\n알림을 받으실 수 있습니다 🌸',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.black.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: ListView.separated(
                        itemCount: _schedules.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final schedule = _schedules[index];
                          final formattedDate = DateFormat('M월 d일 (E)', 'ko_KR')
                              .format(schedule.scheduledStartTime);
                          final formattedTime = DateFormat('a h:mm', 'ko_KR')
                              .format(schedule.scheduledStartTime);

                          final now = DateTime.now();
                          final isUpcoming = schedule.scheduledStartTime.isAfter(now);
                          final isPast = schedule.scheduledStartTime.isBefore(now);

                          return Container(
                            decoration: BoxDecoration(
                              color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                    ? Colors.black.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  // Date and Time Circle
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: isUpcoming
                                        ? AppTheme.iceBlue.withValues(alpha: 0.15)
                                        : isPast
                                          ? AppTheme.mountainGray.withValues(alpha: 0.15)
                                          : AppTheme.sakuraPink.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('d', 'ko_KR').format(schedule.scheduledStartTime),
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: isUpcoming
                                              ? AppTheme.iceBlue
                                              : isPast
                                                ? AppTheme.mountainGray
                                                : AppTheme.sakuraPink,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MMM', 'ko_KR').format(schedule.scheduledStartTime),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: isUpcoming
                                              ? AppTheme.iceBlue
                                              : isPast
                                                ? AppTheme.mountainGray
                                                : AppTheme.sakuraPink,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          schedule.title,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (schedule.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            schedule.description,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: isDark
                                                ? Colors.white.withValues(alpha: 0.7)
                                                : Colors.black.withValues(alpha: 0.6),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isDark
                                              ? Colors.white.withValues(alpha: 0.1)
                                              : Colors.black.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '$formattedDate $formattedTime',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: isDark
                                                ? Colors.white.withValues(alpha: 0.8)
                                                : Colors.black.withValues(alpha: 0.7),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status Indicator
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isUpcoming
                                        ? AppTheme.iceBlue
                                        : isPast
                                          ? AppTheme.mountainGray
                                          : AppTheme.sakuraPink,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}
