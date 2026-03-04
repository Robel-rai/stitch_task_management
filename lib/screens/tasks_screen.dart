import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/task_dialog.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _gridView = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Row(
          children: [
            // Main task area
            Expanded(
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark,
                      border: const Border(
                        bottom: BorderSide(color: AppTheme.borderDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Search
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            height: 36,
                            child: TextField(
                              onChanged: state.setSearchQuery,
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Search tasks...',
                                prefixIcon: const Icon(Icons.search,
                                    size: 18, color: AppTheme.textSecondary),
                                filled: true,
                                fillColor: AppTheme.surfaceVariantDark,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_outlined,
                              color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showTaskDialog(context, state),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Task'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filters & View Toggle
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _FilterChip(
                              label: 'Category',
                              icon: Icons.expand_more,
                              onTap: () => _showCategoryFilter(context, state),
                            ),
                            const SizedBox(width: 12),
                            _FilterChip(
                              label: 'Status',
                              icon: Icons.expand_more,
                              onTap: () => _showStatusFilter(context, state),
                            ),
                            const SizedBox(width: 12),
                            _FilterChip(
                              label: 'Priority',
                              icon: Icons.expand_more,
                              onTap: () => _showPriorityFilter(context, state),
                            ),
                            if (state.categoryFilter != null ||
                                state.statusFilter != null ||
                                state.priorityFilter != null) ...[
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: state.clearFilters,
                                child: const Text(
                                  'Clear filters',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // View toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariantDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _ViewToggle(
                                icon: Icons.grid_view,
                                active: _gridView,
                                onTap: () =>
                                    setState(() => _gridView = true),
                              ),
                              _ViewToggle(
                                icon: Icons.list,
                                active: !_gridView,
                                onTap: () =>
                                    setState(() => _gridView = false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tasks Grid/List
                  Expanded(
                    child: state.tasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.task_alt,
                                    size: 64,
                                    color:
                                        AppTheme.textTertiary.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                const Text(
                                  'No tasks found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Create your first task to get started',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _gridView
                            ? _buildGrid(state)
                            : _buildList(state),
                  ),
                ],
              ),
            ),

            // Right Sidebar - Today's Schedule
            _ScheduleSidebar(tasks: state.tasks),
          ],
        );
      },
    );
  }

  Widget _buildGrid(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 0.95,
        ),
        itemCount: state.tasks.length,
        itemBuilder: (context, index) {
          final task = state.tasks[index];
          return GestureDetector(
            onTap: () => _showEditDialog(context, state, task),
            onLongPress: () => _showDeleteDialog(context, state, task),
            child: TaskCard(task: task),
          );
        },
      ),
    );
  }

  Widget _buildList(AppState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: state.tasks.length,
      itemBuilder: (context, index) {
        final task = state.tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showEditDialog(context, state, task),
            onLongPress: () => _showDeleteDialog(context, state, task),
            child: _ListTaskItem(task: task),
          ),
        );
      },
    );
  }

  void _showTaskDialog(BuildContext context, AppState state) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (_) => const TaskDialog(),
    );
    if (result != null) {
      state.createTask(result);
    }
  }

  void _showEditDialog(
      BuildContext context, AppState state, Task task) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (_) => TaskDialog(task: task),
    );
    if (result != null) {
      state.updateTask(result);
    }
  }

  void _showDeleteDialog(
      BuildContext context, AppState state, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && task.id != null) {
      state.deleteTask(task.id!);
    }
  }

  void _showCategoryFilter(BuildContext context, AppState state) {
    _showFilterMenu(context, [
      'All', 'Development', 'Design', 'Research', 'Marketing',
      'Management', 'UI Design', 'General',
    ], (v) => state.setCategoryFilter(v == 'All' ? null : v));
  }

  void _showStatusFilter(BuildContext context, AppState state) {
    _showFilterMenu(context, [
      'All', 'Pending', 'In Progress', 'Completed',
    ], (v) => state.setStatusFilter(v == 'All' ? null : v));
  }

  void _showPriorityFilter(BuildContext context, AppState state) {
    _showFilterMenu(context, [
      'All', 'Low', 'Medium', 'High',
    ], (v) => state.setPriorityFilter(v == 'All' ? null : v));
  }

  void _showFilterMenu(
      BuildContext context, List<String> items, ValueChanged<String> onSelect) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 0, 0),
      color: AppTheme.surfaceVariantDark,
      items: items
          .map((e) => PopupMenuItem(value: e, child: Text(e)))
          .toList(),
    ).then((value) {
      if (value != null) onSelect(value);
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceVariantDark,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderDark),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ViewToggle({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.surfaceDark : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? AppTheme.primary : AppTheme.textTertiary,
        ),
      ),
    );
  }
}

class _ListTaskItem extends StatelessWidget {
  final Task task;
  const _ListTaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final catColor = AppTheme.getCategoryColor(task.category);
    final statusColor = AppTheme.getStatusColor(task.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => context.read<AppState>().toggleTaskStatus(task),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.status == 'Completed'
                    ? AppTheme.emerald
                    : Colors.transparent,
                border: Border.all(
                  color: task.status == 'Completed'
                      ? AppTheme.emerald
                      : AppTheme.textTertiary,
                  width: 2,
                ),
              ),
              child: task.status == 'Completed'
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    decoration: task.status == 'Completed'
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      task.description,
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task.category,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: catColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            task.formattedTimeFriendly,
            style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary),
          ),
          const SizedBox(width: 12),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ──── Right Sidebar ────
class _ScheduleSidebar extends StatelessWidget {
  final List<Task> tasks;
  const _ScheduleSidebar({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final todayTasks = tasks
        .where((t) =>
            t.scheduledDate != null &&
            _isSameDay(t.scheduledDate!, DateTime.now()))
        .toList();
    final upcomingDeadlines = tasks
        .where((t) =>
            t.scheduledDate != null &&
            t.scheduledDate!.isAfter(DateTime.now()) &&
            t.status != 'Completed')
        .take(3)
        .toList();

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(left: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upcoming Deadlines
                  const Text(
                    'UPCOMING DEADLINES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textTertiary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (upcomingDeadlines.isEmpty)
                    const Text(
                      'No upcoming deadlines',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textTertiary),
                    )
                  else
                    ...upcomingDeadlines.map((t) => _DeadlineItem(task: t)),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.borderDark),
                  const SizedBox(height: 16),
                  // Today's tasks
                  const Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textTertiary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (todayTasks.isEmpty)
                    const Text(
                      'No tasks scheduled for today',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textTertiary),
                    )
                  else
                    ...todayTasks.map((t) => _TodayTaskItem(task: t)),
                ],
              ),
            ),
          ),
          // Weekly report card
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 28, color: AppTheme.primary),
                  const SizedBox(height: 8),
                  const Text(
                    'Weekly Report Ready!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your productivity insights',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AppState>().setNavIndex(3);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('View Detailed Stats'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DeadlineItem extends StatelessWidget {
  final Task task;
  const _DeadlineItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final isUrgent = task.priority == 'High';
    final color = isUrgent ? AppTheme.rose : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.scheduledDate != null)
                  Text(
                    _formatDate(task.scheduledDate!),
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textTertiary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class _TodayTaskItem extends StatelessWidget {
  final Task task;
  const _TodayTaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final isActive = task.isTimerRunning;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary.withValues(alpha: 0.1)
            : AppTheme.surfaceVariantDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Timer running...',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
