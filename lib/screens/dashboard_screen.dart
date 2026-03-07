import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../database/database.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/kpi_card.dart';
import '../widgets/task_dialog.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Check reminders after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.checkUnfinishedTasks(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Consumer<AppState>(
      builder: (context, state, _) {
        return Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: colors.background.withValues(alpha: 0.5),
                border: Border(
                  bottom: BorderSide(color: colors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activity Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      // Search
                      Container(
                        width: 256,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Autocomplete<Task>(
                          optionsBuilder: (TextEditingValue textEditingValue) async {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Task>.empty();
                            }
                            final allTasks = await AppDatabase.getAllTasks(searchQuery: textEditingValue.text);
                            return allTasks.take(3);
                          },
                          displayStringForOption: (Task option) => option.title,
                          onSelected: (Task selection) async {
                            // Clear focus
                            FocusScope.of(context).unfocus();
                            // Go to tasks screen
                            state.setNavIndex(1);
                            // Set search query to match so it filters there too
                            state.setSearchQuery(selection.title);
                            
                            // Open task dialog on next frame to allow navigation
                            WidgetsBinding.instance.addPostFrameCallback((_) async {
                               final result = await showDialog<Task>(
                                  context: context,
                                  builder: (_) => TaskDialog(task: selection),
                               );
                               if (result != null && context.mounted) {
                                  context.read<AppState>().updateTask(result);
                               }
                            });
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onSubmitted: (value) {
                                state.setSearchQuery(value);
                                state.setNavIndex(1);
                              },
                              style: TextStyle(fontSize: 13, color: colors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Search activities...',
                                prefixIcon: Icon(Icons.search, size: 18, color: colors.textSecondary),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(10),
                                color: colors.surface,
                                child: Container(
                                  width: 256,
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final Task option = options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          child: Text(
                                            option.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: colors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Notification bell
                      _HeaderIconButton(
                        icon: Icons.notifications_outlined,
                        badge: state.pendingTasks > 0,
                        onTap: () =>
                            NotificationService.showDailySummary(context),
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
                    // KPI Cards
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            label: 'Total Tasks',
                            value: '${state.totalTasks}',
                            icon: Icons.assignment,
                            iconColor: AppTheme.blue,
                            badge: state.totalTasks > 0 ? '+${state.totalTasks}' : null,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: KpiCard(
                            label: 'Hours Logged',
                            value: state.hoursLogged.toStringAsFixed(1),
                            icon: Icons.schedule,
                            iconColor: AppTheme.purple,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: KpiCard(
                            label: 'Efficiency',
                            value: '${state.efficiencyRate.round()}%',
                            icon: Icons.bolt,
                            iconColor: AppTheme.emerald,
                            badge: state.efficiencyRate > 0
                                ? '${state.efficiencyRate.round()}%'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: KpiCard(
                            label: 'Pending',
                            value: '${state.pendingTasks}',
                            icon: Icons.pending_actions,
                            iconColor: AppTheme.amber,
                            badge: 'Active',
                            badgeColor: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Charts row
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bar Chart
                          Expanded(
                            flex: 2,
                            child: _WeeklyBarChart(data: state.weeklyCompletionCounts),
                          ),
                          const SizedBox(width: 24),
                          // Donut Chart
                          Expanded(
                            flex: 1,
                            child: _CategoryDonut(
                              data: state.categoryDistribution,
                              total: state.totalTasks,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Recent Tasks Table
                    _RecentTasksTable(tasks: state.recentTasks),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool badge;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    this.badge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, size: 20, color: colors.textSecondary),
            ),
          ),
        ),
        if (badge)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.rose,
                shape: BoxShape.circle,
                border: Border.all(color: colors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ──── Weekly Bar Chart ────
class _WeeklyBarChart extends StatelessWidget {
  final Map<int, int> data;
  const _WeeklyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final maxVal = data.values.fold<int>(0, (a, b) => a > b ? a : b);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
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
                  Text(
                    'Weekly Productivity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Completed tasks per day',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View details',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal > 0 ? maxVal.toDouble() + 2 : 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colors.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()} Tasks',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          days[value.toInt()],
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  final val = (data[i] ?? 0).toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        width: 28,
                        color: AppTheme.primary.withValues(
                            alpha: val > 0 ? 0.7 : 0.15),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal > 0 ? maxVal.toDouble() + 2 : 10,
                          color: AppTheme.primary.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──── Category Donut ────
class _CategoryDonut extends StatelessWidget {
  final Map<String, int> data;
  final int total;
  const _CategoryDonut({required this.data, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final chartColors = <Color>[
      AppTheme.primary,
      AppTheme.indigo,
      AppTheme.sky,
      AppTheme.purple,
      AppTheme.amber,
      AppTheme.emerald,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'By category',
            style: TextStyle(fontSize: 13, color: colors.textTertiary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: data.isEmpty
                        ? [
                            PieChartSectionData(
                              value: 1,
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              radius: 30,
                              showTitle: false,
                            ),
                          ]
                        : data.entries.toList().asMap().entries.map((e) {
                            final idx = e.key;
                            final entry = e.value;
                            return PieChartSectionData(
                              value: entry.value.toDouble(),
                              color: chartColors[idx % chartColors.length],
                              radius: 30,
                              showTitle: false,
                            );
                          }).toList(),
                    centerSpaceRadius: 50,
                    sectionsSpace: 2,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.textTertiary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          ...data.entries.toList().asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: chartColors[idx % chartColors.length],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                            fontSize: 13, color: colors.textPrimary),
                      ),
                    ],
                  ),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ──── Recent Tasks Table ────
class _RecentTasksTable extends StatelessWidget {
  final List tasks;
  const _RecentTasksTable({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<dynamic>(
                      context: context,
                      builder: (_) => const TaskDialog(),
                    );
                    if (result != null && context.mounted) {
                      context.read<AppState>().createTask(result);
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _tableHeader('Task Name', flex: 3, colors: colors),
                _tableHeader('Category', flex: 2, colors: colors),
                _tableHeader('Duration', flex: 1, colors: colors),
                _tableHeader('Status', flex: 1, colors: colors),
                _tableHeader('Date', flex: 1, alignment: CrossAxisAlignment.end, colors: colors),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          // Rows
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No tasks yet. Create your first task!',
                style: TextStyle(color: colors.textTertiary),
              ),
            )
          else
            ...tasks.map((t) => _TaskRow(task: t)),
        ],
      ),
    );
  }

  Widget _tableHeader(String text,
      {int flex = 1, CrossAxisAlignment alignment = CrossAxisAlignment.start, required AppThemeColors colors}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment == CrossAxisAlignment.end
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: colors.textTertiary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final dynamic task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final catColor = AppTheme.getCategoryColor(task.category);
    final statusColor = AppTheme.getStatusColor(task.status);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Task Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.code, size: 16, color: catColor),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Category
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                task.category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: catColor,
                ),
              ),
            ),
          ),
          // Duration
          Expanded(
            flex: 1,
            child: Text(
              task.formattedTimeFriendly,
              style: TextStyle(
                  fontSize: 13, color: colors.textPrimary),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  task.status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          // Date
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${months[task.createdAt.month - 1]} ${task.createdAt.day}, ${task.createdAt.year}',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
