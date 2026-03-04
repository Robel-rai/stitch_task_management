import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database.dart';
import '../models/task.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/task_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<String, List<Task>> _monthTasks = {};

  @override
  void initState() {
    super.initState();
    _loadMonthTasks();
  }

  Future<void> _loadMonthTasks() async {
    final state = context.read<AppState>();
    final month = state.viewingMonth;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59);
    final tasks = await AppDatabase.getTasksInRange(start, end);
    final map = <String, List<Task>>{};
    for (final t in tasks) {
      if (t.scheduledDate != null) {
        final key = DateFormat('yyyy-MM-dd').format(t.scheduledDate!);
        map.putIfAbsent(key, () => []);
        map[key]!.add(t);
      }
    }
    setState(() => _monthTasks = map);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final month = state.viewingMonth;
        final monthName = DateFormat('MMMM yyyy').format(month);

        return Row(
          children: [
            // Calendar Grid
            Expanded(
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundDark,
                      border: Border(
                        bottom: BorderSide(color: AppTheme.borderDark),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              monthName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceVariantDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left,
                                        size: 20, color: AppTheme.textSecondary),
                                    onPressed: () {
                                      state.setViewingMonth(DateTime(
                                          month.year, month.month - 1));
                                      Future.delayed(
                                        const Duration(milliseconds: 100),
                                        _loadMonthTasks,
                                      );
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      state.setViewingMonth(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month));
                                      Future.delayed(
                                        const Duration(milliseconds: 100),
                                        _loadMonthTasks,
                                      );
                                    },
                                    child: const Text(
                                      'TODAY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right,
                                        size: 20, color: AppTheme.textSecondary),
                                    onPressed: () {
                                      state.setViewingMonth(DateTime(
                                          month.year, month.month + 1));
                                      Future.delayed(
                                        const Duration(milliseconds: 100),
                                        _loadMonthTasks,
                                      );
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // View toggles
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceVariantDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  _viewBtn('Month', true),
                                  _viewBtn('Week', false),
                                  _viewBtn('Day', false),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () => _addTaskForDate(context, state),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New Event'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                elevation: 4,
                                shadowColor:
                                    AppTheme.primary.withValues(alpha: 0.2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Calendar Grid
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: Column(
                        children: [
                          // Day headers
                          _DayHeaders(),
                          // Grid
                          Expanded(
                            child: _CalendarGrid(
                              month: month,
                              monthTasks: _monthTasks,
                              selectedDate: state.selectedCalendarDate,
                              onDateSelected: (date) async {
                                await state.selectCalendarDate(date);
                              },
                              onTaskDropped: (taskId, newDate) async {
                                await state.rescheduleTask(taskId, newDate);
                                await _loadMonthTasks();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Day Detail Panel
            _DayDetailPanel(
              date: state.selectedCalendarDate,
              tasks: state.selectedDayTasks,
              onAddTask: () => _addTaskForDate(context, state),
              onReorder: state.reorderDayTasks,
            ),
          ],
        );
      },
    );
  }

  Widget _viewBtn(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppTheme.surfaceDark : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: active
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? AppTheme.textPrimary : AppTheme.textTertiary,
        ),
      ),
    );
  }

  void _addTaskForDate(BuildContext context, AppState state) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (_) => TaskDialog(
        task: Task(
          title: '',
          scheduledDate: state.selectedCalendarDate,
        ),
      ),
    );
    if (result != null) {
      await state.createTask(result);
      await _loadMonthTasks();
      await state.selectCalendarDate(state.selectedCalendarDate);
    }
  }
}

class _DayHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantDark.withValues(alpha: 0.5),
        border: const Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                          right: BorderSide(
                              color: AppTheme.borderDark, width: 0.5)),
                    ),
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textTertiary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<String, List<Task>> monthTasks;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Function(int taskId, DateTime newDate) onTaskDropped;

  const _CalendarGrid({
    required this.month,
    required this.monthTasks,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onTaskDropped,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startOffset = firstDay.weekday % 7; // Sunday = 0
    final totalDays = lastDay.day;
    final totalCells = ((startOffset + totalDays + 6) ~/ 7) * 7;

    final today = DateTime.now();
    final taskColors = [
      AppTheme.emerald,
      AppTheme.primary,
      AppTheme.amber,
      AppTheme.indigo,
      AppTheme.rose,
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNum = index - startOffset + 1;
        final isCurrentMonth = dayNum >= 1 && dayNum <= totalDays;
        final date = DateTime(month.year, month.month, dayNum);
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final tasks = monthTasks[dateStr] ?? [];
        final isToday = isCurrentMonth &&
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isSelected = isCurrentMonth &&
            date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;

        return DragTarget<int>(
          onAcceptWithDetails: (details) {
            if (isCurrentMonth) {
              onTaskDropped(details.data, date);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTap: isCurrentMonth ? () => onDateSelected(date) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : candidateData.isNotEmpty
                          ? AppTheme.primary.withValues(alpha: 0.1)
                          : !isCurrentMonth
                              ? AppTheme.surfaceDark.withValues(alpha: 0.2)
                              : null,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.borderDark.withValues(alpha: 0.5),
                    width: isSelected ? 2 : 0.5,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCurrentMonth ? '$dayNum' : '',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? AppTheme.primary
                            : isCurrentMonth
                                ? AppTheme.textPrimary
                                : AppTheme.textTertiary,
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Each pill is ~18px tall (padding + font), show as many as fit
                          const pillHeight = 19.0;
                          const moreHeight = 14.0;
                          final availableHeight = constraints.maxHeight - 2; // SizedBox(2)
                          int maxVisible = (availableHeight / pillHeight).floor();
                          final hasMore = tasks.length > maxVisible;
                          if (hasMore && maxVisible > 0) {
                            // Reserve space for "+N more" label
                            maxVisible = ((availableHeight - moreHeight) / pillHeight).floor();
                            if (maxVisible < 0) maxVisible = 0;
                          }
                          final visibleTasks = tasks.take(maxVisible).toList();
                          final remaining = tasks.length - visibleTasks.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 2),
                              ...visibleTasks.asMap().entries.map((entry) {
                                final t = entry.value;
                                final color =
                                    taskColors[entry.key % taskColors.length];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 1),
                                  child: Draggable<int>(
                                    data: t.id,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          t.title,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: _TaskPill(title: t.title, color: color),
                                    ),
                                    child: _TaskPill(title: t.title, color: color),
                                  ),
                                );
                              }),
                              if (remaining > 0)
                                Text(
                                  '+$remaining more',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: AppTheme.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TaskPill extends StatelessWidget {
  final String title;
  final Color color;
  const _TaskPill({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border(left: BorderSide(color: color, width: 2)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, size: 10, color: AppTheme.textTertiary),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ──── Day Detail Panel ────
class _DayDetailPanel extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;
  final VoidCallback onAddTask;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _DayDetailPanel({
    required this.date,
    required this.tasks,
    required this.onAddTask,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE').format(date);
    final dateStr = DateFormat('MMM d, yyyy').format(date);

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(left: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$dayName — ${tasks.length} Tasks Scheduled',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Tasks list with drag-to-reorder
          Expanded(
            child: tasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          'No tasks for this day',
                          style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                        ),
                        const Spacer(),
                        _addTaskButton(),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: tasks.length,
                          onReorder: onReorder,
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              elevation: 4,
                              shadowColor: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                              child: child,
                            );
                          },
                          itemBuilder: (context, index) {
                            return _DayTaskCard(
                              key: ValueKey(tasks[index].id),
                              task: tasks[index],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _addTaskButton(),
                      ),
                    ],
                  ),
          ),

          // Upcoming Events
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withValues(alpha: 0.5),
              border: const Border(
                  top: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UPCOMING EVENTS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                if (tasks.isEmpty)
                  const Text(
                    'No events for this day',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                  )
                else
                  ...tasks.take(3).map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.getCategoryColor(t.category),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    t.category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addTaskButton() {
    return InkWell(
      onTap: onAddTask,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderDark,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline,
                color: AppTheme.textTertiary),
            SizedBox(height: 4),
            Text(
              'ADD TASK',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayTaskCard extends StatelessWidget {
  final Task task;
  const _DayTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final catColor = AppTheme.getCategoryColor(task.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: catColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  task.category,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: catColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Icon(Icons.drag_indicator,
                  size: 18, color: AppTheme.textTertiary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          if (task.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                task.description,
                style:
                    const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 12, color: AppTheme.textTertiary),
              const SizedBox(width: 4),
              Text(
                task.formattedTimeFriendly,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
