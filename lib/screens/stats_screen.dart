import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_provider.dart';
import '../language_provider.dart';
import '../services/gamification_service.dart';
import 'history_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<WorkoutHistory> _workouts = [];
  bool _isLoading = true;
  int _selectedDays = 7; // 7, 30, 90, 0 = all

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyStrings =
        prefs.getStringList('workout_history') ?? [];

    setState(() {
      _workouts = historyStrings.map((s) {
        List<String> parts = s.split('|');
        return WorkoutHistory(
          type: parts[0],
          duration: int.parse(parts[1]),
          rounds: int.parse(parts[2]),
          date: DateTime.parse(parts[3]),
        );
      }).toList();

      _workouts.sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
    });
  }

  List<WorkoutHistory> get _filteredWorkouts {
    if (_selectedDays == 0) return _workouts;
    final cutoff = DateTime.now().subtract(Duration(days: _selectedDays));
    return _workouts.where((w) => w.date.isAfter(cutoff)).toList();
  }

  int get _totalWorkouts => _filteredWorkouts.length;

  int get _totalSeconds =>
      _filteredWorkouts.fold(0, (sum, w) => sum + w.duration);

  int get _currentStreak {
    if (_filteredWorkouts.isEmpty) return 0;

    Set<String> workoutDays = _filteredWorkouts
        .map((w) =>
            '${w.date.year}-${w.date.month}-${w.date.day}')
        .toSet();

    DateTime today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    // Check if today or yesterday has a workout to start counting
    String todayKey =
        '${checkDate.year}-${checkDate.month}-${checkDate.day}';
    DateTime yesterday = checkDate.subtract(const Duration(days: 1));
    String yesterdayKey =
        '${yesterday.year}-${yesterday.month}-${yesterday.day}';

    if (!workoutDays.contains(todayKey) &&
        !workoutDays.contains(yesterdayKey)) {
      return 0;
    }

    // If no workout today, start from yesterday
    if (!workoutDays.contains(todayKey)) {
      checkDate = yesterday;
    }

    int streak = 0;
    while (workoutDays.contains(
        '${checkDate.year}-${checkDate.month}-${checkDate.day}')) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get _bestStreak {
    if (_filteredWorkouts.isEmpty) return 0;

    Set<DateTime> workoutDays = _filteredWorkouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();

    List<DateTime> sortedDays = workoutDays.toList()..sort();

    int best = 1;
    int current = 1;

    for (int i = 1; i < sortedDays.length; i++) {
      if (sortedDays[i].difference(sortedDays[i - 1]).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }
    return best;
  }

  Map<String, int> get _workoutsByType {
    Map<String, int> counts = {};
    for (var w in _filteredWorkouts) {
      counts[w.type] = (counts[w.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Returns workout counts per day for the selected period.
  /// For 7d: daily bars. For 30d: daily bars. For 90d/all: weekly bars.
  List<MapEntry<DateTime, int>> get _chartData {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int numDays = _selectedDays == 0 ? 90 : _selectedDays;

    if (numDays <= 30) {
      // Daily bars
      List<MapEntry<DateTime, int>> days = [];
      for (int i = numDays - 1; i >= 0; i--) {
        DateTime day = today.subtract(Duration(days: i));
        int count = _filteredWorkouts
            .where((w) =>
                w.date.year == day.year &&
                w.date.month == day.month &&
                w.date.day == day.day)
            .length;
        days.add(MapEntry(day, count));
      }
      return days;
    } else {
      // Weekly bars
      int numWeeks = (numDays / 7).ceil();
      List<MapEntry<DateTime, int>> weeks = [];
      for (int i = numWeeks - 1; i >= 0; i--) {
        DateTime weekStart = today.subtract(Duration(days: i * 7 + 6));
        DateTime weekEnd = today.subtract(Duration(days: i * 7));
        int count = _filteredWorkouts
            .where((w) {
              DateTime wDay = DateTime(w.date.year, w.date.month, w.date.day);
              return !wDay.isBefore(weekStart) && !wDay.isAfter(weekEnd);
            })
            .length;
        weeks.add(MapEntry(weekStart, count));
      }
      return weeks;
    }
  }

  String _formatTotalTime(int totalSeconds, LanguageProvider lang) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _getDayAbbreviation(int weekday, LanguageProvider lang) {
    bool isSpanish = lang.currentLanguage == 'es';
    const esLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    const enLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return isSpanish
        ? esLabels[weekday - 1]
        : enLabels[weekday - 1];
  }

  void _shareStats(LanguageProvider lang) {
    final typeData = _workoutsByType;
    final sorted = typeData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    bool isSpanish = lang.currentLanguage == 'es';

    StringBuffer text = StringBuffer();
    text.writeln(isSpanish
        ? '📊 Mis estadísticas en CrossFit Timer Pro'
        : '📊 My stats on CrossFit Timer Pro');
    text.writeln('');
    text.writeln('💪 $_totalWorkouts ${lang.getText('stats_total_workouts').toLowerCase()}');
    text.writeln('⏱️ ${_formatTotalTime(_totalSeconds, lang)} ${lang.getText('stats_total_time').toLowerCase()}');
    text.writeln('🔥 $_currentStreak ${isSpanish ? 'días de racha' : 'day streak'}');
    text.writeln('🏆 ${isSpanish ? 'Mejor racha' : 'Best streak'}: $_bestStreak ${isSpanish ? 'días' : 'days'}');

    if (sorted.isNotEmpty) {
      text.writeln('');
      text.writeln('📈 ${lang.getText('stats_by_type')}:');
      for (var entry in sorted) {
        double pct = (entry.value / _totalWorkouts) * 100;
        text.writeln('  ${entry.key}: ${entry.value} (${pct.toStringAsFixed(0)}%)');
      }
    }

    text.writeln('');
    text.writeln('#CrossFit #WOD #CrossFitTimerPro');

    Share.share(text.toString());
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'AMRAP':
        return Colors.orange;
      case 'EMOM':
        return Colors.blue;
      case 'TABATA':
        return Colors.red;
      case 'COUNTDOWN':
        return Colors.green;
      case 'RUNNING':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'AMRAP':
        return Icons.repeat;
      case 'EMOM':
        return Icons.timer;
      case 'TABATA':
        return Icons.flash_on;
      case 'COUNTDOWN':
        return Icons.hourglass_bottom;
      case 'RUNNING':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          languageProvider.getText('stats_title'),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (_workouts.isNotEmpty)
            IconButton(
              onPressed: () => _shareStats(languageProvider),
              icon: const Icon(Icons.share),
              tooltip: languageProvider.getText('share'),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF1E2030),
                        Color(0xFF2A2A38),
                        Color(0xFF1E2030)
                      ]
                    : const [
                        Color(0xFFE0F7FA),
                        Color(0xFFFCE4EC),
                        Color(0xFFE8EAF6)
                      ],
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _workouts.isEmpty
                    ? _buildEmptyState(textColor, languageProvider)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Period filter
                            _buildPeriodFilter(
                                isDark, textColor, languageProvider),
                            const SizedBox(height: 16),

                            // Summary cards
                            _buildSummaryCards(
                                isDark, textColor, languageProvider),
                            const SizedBox(height: 24),

                            // Chart
                            _buildSectionTitle(
                              _selectedDays == 7
                                  ? languageProvider.getText('stats_weekly')
                                  : _selectedDays == 30
                                      ? languageProvider.getText('stats_monthly')
                                      : _selectedDays == 90
                                          ? languageProvider.getText('stats_quarterly')
                                          : languageProvider.getText('stats_all_time'),
                              Icons.bar_chart,
                              textColor,
                            ),
                            const SizedBox(height: 12),
                            _buildWeeklyChart(
                                isDark, textColor, languageProvider),
                            const SizedBox(height: 24),

                            const SizedBox(height: 24),

                            // By type
                            _buildSectionTitle(
                              languageProvider.getText('stats_by_type'),
                              Icons.pie_chart,
                              textColor,
                            ),
                            const SizedBox(height: 12),
                            _buildTypeBreakdown(
                                isDark, textColor, languageProvider),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter(
      bool isDark, Color textColor, LanguageProvider lang) {
    final options = [
      (days: 7, label: '7D'),
      (days: 30, label: '30D'),
      (days: 90, label: '3M'),
      (days: 0, label: lang.getText('stats_all')),
    ];

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.5),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: options.map((opt) {
              final isSelected = _selectedDays == opt.days;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDays = opt.days),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Colors.orange
                          : Colors.transparent,
                    ),
                    child: Text(
                      opt.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 50.ms);
  }

  Widget _buildEmptyState(Color textColor, LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined,
              size: 80,
              color: textColor.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text(
            lang.getText('stats_empty'),
            style: TextStyle(
                fontSize: 18,
                color: textColor.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 10),
          Text(
            lang.getText('stats_empty_hint'),
            style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.4)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
      bool isDark, Color textColor, LanguageProvider lang) {
    final subtitleColor =
        textColor.withValues(alpha: isDark ? 0.65 : 0.7);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCard(
                isDark: isDark,
                color: Colors.orange,
                icon: Icons.fitness_center,
                value: '$_totalWorkouts',
                label: lang.getText('stats_total_workouts'),
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                isDark: isDark,
                color: Colors.blue,
                icon: Icons.access_time,
                value: _formatTotalTime(_totalSeconds, lang),
                label: lang.getText('stats_total_time'),
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.15, end: 0),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCard(
                isDark: isDark,
                color: Colors.green,
                icon: Icons.local_fire_department,
                value: '$_currentStreak',
                label: lang.getText('stats_current_streak'),
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                isDark: isDark,
                color: Colors.red,
                icon: Icons.emoji_events,
                value: '$_bestStreak',
                label: lang.getText('stats_best_streak'),
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.15, end: 0),
      ],
    );
  }

  Widget _buildCard({
    required bool isDark,
    required Color color,
    required IconData icon,
    required String value,
    required String label,
    required Color textColor,
    required Color subtitleColor,
  }) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.15),
              ],
            ),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: textColor, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: textColor, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  String _getChartLabel(int index, List<MapEntry<DateTime, int>> data,
      LanguageProvider lang) {
    if (index < 0 || index >= data.length) return '';
    final date = data[index].key;
    int numDays = _selectedDays == 0 ? 90 : _selectedDays;

    if (numDays <= 7) {
      return _getDayAbbreviation(date.weekday, lang);
    } else if (numDays <= 30) {
      // Show every 5th label to avoid crowding
      if (index % 5 == 0 || index == data.length - 1) {
        return '${date.day}/${date.month}';
      }
      return '';
    } else {
      // Weekly: show week start date
      return '${date.day}/${date.month}';
    }
  }

  Widget _buildWeeklyChart(
      bool isDark, Color textColor, LanguageProvider lang) {
    final data = _chartData;
    double maxY = data
            .map((e) => e.value)
            .fold(0, (a, b) => a > b ? a : b)
            .toDouble();
    if (maxY < 1) maxY = 1;

    int numDays = _selectedDays == 0 ? 90 : _selectedDays;
    double barWidth = numDays <= 7 ? 24 : (numDays <= 30 ? 8 : 16);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04)
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.7),
                      Colors.white.withValues(alpha: 0.4)
                    ],
            ),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: BarChart(
            BarChartData(
              maxY: maxY + 1,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem:
                      (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()}',
                      TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value == value.roundToDouble() &&
                          value >= 0) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                              color: textColor.withValues(
                                  alpha: 0.5),
                              fontSize: 12),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      String label =
                          _getChartLabel(value.toInt(), data, lang);
                      if (label.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: textColor.withValues(
                                alpha: 0.6),
                            fontSize: numDays <= 7 ? 12 : 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: textColor.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: data.asMap().entries.map((entry) {
                int index = entry.key;
                int count = entry.value.value;
                bool isLast = index == data.length - 1;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: isLast
                          ? Colors.orange
                          : Colors.orange.withValues(alpha: 0.5),
                      width: barWidth,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 350.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTypeBreakdown(
      bool isDark, Color textColor, LanguageProvider lang) {
    final typeData = _workoutsByType;
    if (typeData.isEmpty) return const SizedBox.shrink();

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.1);
    final subtitleColor =
        textColor.withValues(alpha: isDark ? 0.65 : 0.7);

    // Sort by count descending
    final sorted = typeData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04)
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.7),
                      Colors.white.withValues(alpha: 0.4)
                    ],
            ),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            children: sorted.map((entry) {
              final color = _getTypeColor(entry.key);
              final icon = _getTypeIcon(entry.key);
              double percentage =
                  (entry.value / _totalWorkouts) * 100;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          color.withValues(alpha: 0.15),
                      child: Icon(icon,
                          color: textColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: color
                                  .withValues(alpha: 0.15),
                              valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildBadgesSection(
      bool isDark, Color textColor, LanguageProvider lang) {
    final gamification = Provider.of<GamificationService>(context);
    final unlocked = gamification.unlockedBadges;
    final allBadges = GamificationService.allBadges;
    final unlockedCount = unlocked.length;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.military_tech, color: textColor, size: 22),
            const SizedBox(width: 8),
            Text(
              lang.getText('badges_title'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unlockedCount/${allBadges.length} ${lang.getText('badges_unlocked')}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 450.ms),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.04)
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.4)
                        ],
                ),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = (constraints.maxWidth / 85).floor().clamp(4, 6);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: allBadges.length,
                    itemBuilder: (context, index) {
                      final badge = allBadges[index];
                      final isUnlocked = unlocked.contains(badge.id);
                      return _buildBadgeItem(
                        badge: badge,
                        isUnlocked: isUnlocked,
                        isDark: isDark,
                        textColor: textColor,
                        lang: lang,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 500.ms)
            .slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildBadgeItem({
    required AchievementBadge badge,
    required bool isUnlocked,
    required bool isDark,
    required Color textColor,
    required LanguageProvider lang,
  }) {
    final name = lang.getText('badge_${badge.id}');

    return GestureDetector(
      onTap: () => _showBadgeDetail(badge, isUnlocked, isDark, textColor, lang),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        badge.color.withValues(alpha: 0.4),
                        badge.color.withValues(alpha: 0.2),
                      ],
                    )
                  : null,
              color: isUnlocked
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06)),
              border: Border.all(
                color: isUnlocked
                    ? badge.color.withValues(alpha: 0.5)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1)),
                width: 2,
              ),
            ),
            child: Center(
              child: isUnlocked
                  ? Text(badge.icon, style: const TextStyle(fontSize: 24))
                  : Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: textColor.withValues(alpha: 0.25),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              isUnlocked ? name : '???',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isUnlocked
                    ? textColor
                    : textColor.withValues(alpha: 0.3),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(AchievementBadge badge, bool isUnlocked, bool isDark,
      Color textColor, LanguageProvider lang) {
    final name = lang.getText('badge_${badge.id}');
    final desc = lang.getText('badge_${badge.id}_desc');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF2A2A38) : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [
                          badge.color.withValues(alpha: 0.4),
                          badge.color.withValues(alpha: 0.2),
                        ],
                      )
                    : null,
                color: isUnlocked
                    ? null
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Center(
                child: isUnlocked
                    ? Text(badge.icon, style: const TextStyle(fontSize: 40))
                    : Icon(Icons.lock_outline,
                        size: 36,
                        color: textColor.withValues(alpha: 0.3)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isUnlocked ? name : lang.getText('badge_locked'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              lang.getText('close'),
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
