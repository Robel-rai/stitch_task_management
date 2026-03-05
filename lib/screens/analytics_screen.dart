import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/analytics_service.dart';
import '../services/reporting_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _productivityScore = 0;
  int _streak = 0;
  int _maxStreak = 0;
  double _avgCompletionTime = 0;
  Map<int, double> _focusTimePerDay = {};
  double _dailyAvgFocusHours = 0;
  Map<String, double> _categoryPerformance = {};
  Map<String, dynamic> _weeklyReport = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final results = await Future.wait([
      AnalyticsService.getProductivityScore(),
      AnalyticsService.getDailyStreak(),
      AnalyticsService.getMaxStreak(),
      AnalyticsService.getAvgCompletionTimeMinutes(),
      AnalyticsService.getFocusTimePerDayThisWeek(),
      AnalyticsService.getDailyAvgFocusHours(),
      AnalyticsService.getCategoryPerformance(),
      ReportingService.generateWeeklyReport(),
    ]);

    setState(() {
      _productivityScore = results[0] as int;
      _streak = results[1] as int;
      _maxStreak = results[2] as int;
      _avgCompletionTime = results[3] as double;
      _focusTimePerDay = results[4] as Map<int, double>;
      _dailyAvgFocusHours = results[5] as double;
      _categoryPerformance = results[6] as Map<String, double>;
      _weeklyReport = results[7] as Map<String, dynamic>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(color: colors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics & Reporting',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 256,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: TextStyle(fontSize: 13, color: colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search data...',
                        prefixIcon: Icon(Icons.search,
                            size: 18, color: colors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications_outlined,
                        color: colors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stats Cards
                Row(
                  children: [
                    Expanded(child: _StatCard(
                      label: 'Daily Productivity Score',
                      value: '$_productivityScore',
                      icon: Icons.speed,
                      iconColor: AppTheme.primary,
                      change: '+${(_productivityScore * 0.05).round()}%',
                      changeUp: true,
                      subtitle: "Versus last week's average",
                    )),
                    const SizedBox(width: 24),
                    Expanded(child: _StatCard(
                      label: 'Current Streak',
                      value: '$_streak days',
                      icon: Icons.local_fire_department,
                      iconColor: AppTheme.orange,
                      change: _streak > 0 ? '+$_streak' : '0',
                      changeUp: _streak > 0,
                      subtitle: 'Personal record: $_maxStreak days',
                    )),
                    const SizedBox(width: 24),
                    Expanded(child: _StatCard(
                      label: 'Avg. Completion Time',
                      value: '${_avgCompletionTime.round()}m',
                      icon: Icons.timer,
                      iconColor: AppTheme.blue,
                      change: _avgCompletionTime > 0
                          ? '${_avgCompletionTime.round()}m'
                          : '0m',
                      changeUp: false,
                      subtitle: 'Per task average',
                    )),
                  ],
                ),
                const SizedBox(height: 32),

                // Charts Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Radar Chart / Category Performance
                    Expanded(child: _CategoryRadar(data: _categoryPerformance)),
                    const SizedBox(width: 32),
                    // Focus Time Line Chart
                    Expanded(child: _FocusTimeChart(
                      data: _focusTimePerDay,
                      avgHours: _dailyAvgFocusHours,
                    )),
                  ],
                ),
                const SizedBox(height: 32),

                // Export & Report Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Export Options
                    SizedBox(
                      width: 300,
                      child: _ExportSection(),
                    ),
                    const SizedBox(width: 32),
                    // Weekly Report Preview
                    Expanded(child: _WeeklyReportPreview(report: _weeklyReport)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ──── Stat Card ────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String change;
  final bool changeUp;
  final String subtitle;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.change,
    required this.changeUp,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary)),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(
                    changeUp ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: changeUp ? AppTheme.emerald : AppTheme.rose,
                  ),
                  Text(
                    change,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: changeUp ? AppTheme.emerald : AppTheme.rose,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 11, color: colors.textTertiary)),
        ],
      ),
    );
  }
}

// ──── Category Radar (simplified circular display) ────
class _CategoryRadar extends StatelessWidget {
  final Map<String, double> data;
  const _CategoryRadar({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category Performance',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Completion rate per category',
                      style: TextStyle(
                          fontSize: 13, color: colors.textTertiary)),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Full Details',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (data.isEmpty || data.length < 3)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar, size: 48,
                        color: AppTheme.primary.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      data.isEmpty
                          ? 'No category data yet'
                          : 'Need at least 3 categories for radar chart',
                      style: TextStyle(color: colors.textTertiary),
                    ),
                    if (data.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...data.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${e.key}: ${e.value.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: colors.textPrimary)),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 256,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppTheme.primary.withValues(alpha: 0.2),
                      borderColor: AppTheme.primary,
                      borderWidth: 2,
                      dataEntries: data.values
                          .map((v) => RadarEntry(value: v))
                          .toList(),
                    ),
                  ],
                  radarBorderData: BorderSide(
                    color: colors.border.withValues(alpha: 0.5),
                  ),
                  tickBorderData: BorderSide(
                    color: colors.border.withValues(alpha: 0.3),
                  ),
                  gridBorderData: BorderSide(
                    color: colors.border.withValues(alpha: 0.3),
                  ),
                  radarBackgroundColor: Colors.transparent,
                  tickCount: 4,
                  ticksTextStyle: TextStyle(
                      fontSize: 8, color: colors.textTertiary),
                  titleTextStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                  getTitle: (index, _) {
                    final keys = data.keys.toList();
                    return RadarChartTitle(
                      text: index < keys.length ? keys[index] : '',
                    );
                  },
                  titlePositionPercentageOffset: 0.15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──── Focus Time Chart ────
class _FocusTimeChart extends StatelessWidget {
  final Map<int, double> data;
  final double avgHours;
  const _FocusTimeChart({required this.data, required this.avgHours});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Focus Time Per Day',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('${avgHours.toStringAsFixed(1)}h daily average',
                      style: TextStyle(
                          fontSize: 13, color: colors.textTertiary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Week',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Month',
                          style: TextStyle(
                              fontSize: 11, color: colors.textTertiary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colors.border.withValues(alpha: 0.3),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          days[value.toInt()],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                      interval: 1,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (i) {
                      return FlSpot(i.toDouble(), data[i] ?? 0);
                    }),
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colors.surface,
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${s.y.toStringAsFixed(1)}h',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──── Export Section ────
class _ExportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('Export Summary',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              _ExportItem(
                icon: Icons.description,
                iconColor: AppTheme.blue,
                title: 'Monthly Summary',
                subtitle: 'PDF Document',
                downloadColor: AppTheme.primary,
                onDownload: () async {
                  final path = await ReportingService.exportAnalyticsToCSV();
                  if (context.mounted && path != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exported to $path')),
                    );
                  }
                },
              ),
              Divider(color: colors.border, height: 1),
              _ExportItem(
                icon: Icons.table_chart,
                iconColor: AppTheme.emerald,
                title: 'Raw Activity Data',
                subtitle: 'CSV Spreadsheet',
                downloadColor: AppTheme.emerald,
                onDownload: () async {
                  final path = await ReportingService.exportTasksToCSV();
                  if (context.mounted && path != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exported to $path')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExportItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color downloadColor;
  final VoidCallback onDownload;

  const _ExportItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.downloadColor,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: colors.textTertiary)),
                ],
              ),
            ],
          ),
          Material(
            color: downloadColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onDownload,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.download, size: 20, color: downloadColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──── Weekly Report Preview ────
class _WeeklyReportPreview extends StatelessWidget {
  final Map<String, dynamic> report;
  const _WeeklyReportPreview({required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final startDate = report['startDate'] as DateTime?;
    final endDate = report['endDate'] as DateTime?;
    final insights =
        (report['insights'] as List<Map<String, String>>?) ?? [];
    final categories =
        (report['categories'] as Map<String, int>?) ?? {};
    final total = categories.values.fold<int>(0, (a, b) => a + b);

    final catColors = {
      'Development': AppTheme.primary,
      'Design': AppTheme.blue,
      'Research': AppTheme.purple,
      'Marketing': AppTheme.amber,
      'Management': AppTheme.emerald,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('Reporting Preview',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Draft',
                  style: TextStyle(
                      fontSize: 11, color: colors.textTertiary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Header
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WEEKLY REPORT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          startDate != null && endDate != null
                              ? '${DateFormat('MMM dd').format(startDate)} — ${DateFormat('MMM dd, yyyy').format(endDate)}'
                              : 'This Week',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.polyline,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Two columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Insights
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SUMMARY INSIGHTS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: colors.textTertiary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (insights.isEmpty)
                          Text(
                            'Complete some tasks to see insights.',
                            style: TextStyle(
                                fontSize: 13, color: colors.textTertiary),
                          )
                        else
                          ...insights.map((insight) {
                            IconData ic;
                            Color col;
                            switch (insight['color']) {
                              case 'green':
                                ic = Icons.check_circle;
                                col = AppTheme.emerald;
                                break;
                              case 'blue':
                                ic = Icons.info;
                                col = AppTheme.primary;
                                break;
                              case 'orange':
                                ic = Icons.warning;
                                col = AppTheme.orange;
                                break;
                              default:
                                ic = Icons.info;
                                col = colors.textTertiary;
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(ic, size: 16, color: col),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      insight['text'] ?? '',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: colors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Top Categories
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOP CATEGORIES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.textTertiary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (categories.isEmpty)
                            Text(
                              'No data yet',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textTertiary),
                            )
                          else
                            ...categories.entries.take(5).map((entry) {
                              final pct = total > 0
                                  ? (entry.value / total * 100).round()
                                  : 0;
                              final color = catColors[entry.key] ??
                                  colors.textTertiary;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(entry.key,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    colors.textPrimary)),
                                        Text('$pct%',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    colors.textPrimary)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100),
                                      child: LinearProgressIndicator(
                                        value: pct / 100,
                                        backgroundColor: colors.surfaceVariant,
                                        color: color,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
