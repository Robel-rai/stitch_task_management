import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/task_card.dart';
import '../widgets/task_dialog.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _gridView = true;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Initialize with current query to handle routing from Dashboard
    _searchController = TextEditingController(
      text: context.read<AppState>().searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Consumer<AppState>(
      builder: (context, state, _) {
        // Sync controller with state if updated externally (like from Dashboard)
        if (_searchController.text != state.searchQuery) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_searchController.text != state.searchQuery) {
              _searchController.value = _searchController.value.copyWith(
                text: state.searchQuery,
                selection: TextSelection.collapsed(offset: state.searchQuery.length),
              );
            }
          });
        }
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
                      color: colors.background,
                      border: Border(
                        bottom: BorderSide(color: colors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Search
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            height: 36,
                            child: TextField(
                              controller: _searchController,
                              onChanged: state.setSearchQuery,
                              style: TextStyle(
                                  fontSize: 13, color: colors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Search tasks...',
                                prefixIcon: Icon(Icons.search,
                                    size: 18, color: colors.textSecondary),
                                filled: true,
                                fillColor: colors.surfaceVariant,
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
                        Builder(
                          builder: (btnContext) => IconButton(
                            onPressed: () => _showNotificationMenu(btnContext, state),
                            icon: Badge(
                              isLabelVisible: state.notificationTasks.isNotEmpty,
                              smallSize: 8,
                              backgroundColor: AppTheme.rose,
                              child: Icon(Icons.notifications_outlined, color: colors.textSecondary),
                            ),
                          ),
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
                              onTap: (ctx) => _showCategoryFilter(ctx, state),
                            ),
                            const SizedBox(width: 12),
                            _FilterChip(
                              label: 'Status',
                              icon: Icons.expand_more,
                              onTap: (ctx) => _showStatusFilter(ctx, state),
                            ),
                            const SizedBox(width: 12),
                            _FilterChip(
                              label: 'Priority',
                              icon: Icons.expand_more,
                              onTap: (ctx) => _showPriorityFilter(ctx, state),
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
                            color: colors.surfaceVariant,
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
                                        colors.textTertiary.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  'No tasks found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first task to get started',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textTertiary,
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
          childAspectRatio: 0.80, // Reduced aspect ratio to accommodate extra action buttons height
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

  void _showNotificationMenu(BuildContext context, AppState state) {
    if (state.notificationTasks.isEmpty) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    
    // Align right edge of menu with right edge of button
    // menu width is 300.
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(button.size.width - 300, button.size.height + 8), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(const Offset(0, 8)), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<Task>(
      context: context,
      position: position,
      color: colors.surfaceVariant,
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
      items: state.notificationTasks.map((task) {
        final elapsed = task.timeSpentSeconds + 
            (task.timerStartedAt != null ? DateTime.now().difference(task.timerStartedAt!).inSeconds : 0);
        final isAlert = elapsed >= 7200;

        return PopupMenuItem<Task>(
          value: task,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isAlert ? Icons.warning_amber_rounded : Icons.timer,
                color: isAlert ? AppTheme.rose : AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAlert ? 'Running for over 2 hours!' : 'Timer running',
                      style: TextStyle(
                        color: isAlert ? AppTheme.rose : colors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedTask) {
      if (selectedTask != null) {
        // We must check if context is still mounted after the async showMenu returns
        if (!context.mounted) return;
        _showEditDialog(context, state, selectedTask);
      }
    });
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
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: colors.textSecondary)),
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
    final customCategories = state.customCategories;
    final List<String> taskDialogCategories = const [
      'General', 'Development', 'Design', 'Research', 'Marketing',
      'Management', 'UI Design', 'Work', 'Study', 'Health'
    ];
    final List<String> allCategories = <String>{
      'All', 
      ...taskDialogCategories,
      ...customCategories,
      '+ Add New Category',
      'Manage Categories'
    }.toList(); // Using Set ensures no duplicates

    _showFilterMenu(context, allCategories, (v) {
      if (v == '+ Add New Category') {
        _showAddCategoryDialog(context, state);
      } else if (v == 'Manage Categories') {
        _showManageCategoriesDialog(context, state);
      } else {
        state.setCategoryFilter(v == 'All' ? null : v);
      }
    });
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
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    // Calculate position exactly below the button
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height + 4), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(const Offset(0, 4)), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: colors.surfaceVariant,
      constraints: BoxConstraints(minWidth: button.size.width),
      items: items
          .map((e) => PopupMenuItem(
                value: e,
                textStyle: TextStyle(
                  color: (e == '+ Add New Category' || e == 'Manage Categories') ? AppTheme.primary : colors.textPrimary,
                  fontSize: 13,
                  fontWeight: (e == '+ Add New Category' || e == 'Manage Categories') ? FontWeight.w700 : FontWeight.w500,
                ),
                child: e == '+ Add New Category'
                    ? Row(
                        children: [
                          const Icon(Icons.add, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          const Text('Add New Category'),
                        ],
                      )
                    : e == 'Manage Categories'
                        ? Row(
                            children: [
                              const Icon(Icons.settings, size: 16, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              const Text('Manage Categories'),
                            ],
                          )
                        : Text(e),
              ))
          .toList(),
    ).then((value) {
      if (value != null) onSelect(value);
    });
  }

  Future<void> _showAddCategoryDialog(BuildContext context, AppState state) async {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final ctrl = TextEditingController();
    final newCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Add New Category', style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Category name...',
              filled: true,
              fillColor: colors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final txt = ctrl.text.trim();
                Navigator.pop(context, txt.isNotEmpty ? txt : null);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (newCategory != null && mounted) {
      await state.addCustomCategory(newCategory);
      state.setCategoryFilter(newCategory);
    }
  }

  void _showManageCategoriesDialog(BuildContext context, AppState state) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            final customCategories = context.watch<AppState>().customCategories;
            
            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Manage Categories', style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              content: SizedBox(
                width: 300,
                height: 300,
                child: customCategories.isEmpty
                    ? Center(
                        child: Text(
                          'No custom categories',
                          style: TextStyle(color: colors.textTertiary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: customCategories.length,
                        itemBuilder: (context, index) {
                          final category = customCategories[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              category,
                              style: TextStyle(color: colors.textPrimary, fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: AppTheme.rose, size: 20),
                              onPressed: () async {
                                await state.removeCustomCategory(category);
                              },
                              tooltip: 'Delete Category',
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function(BuildContext) onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: colors.textSecondary),
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
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? AppTheme.primary : colors.textTertiary,
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
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final catColor = AppTheme.getCategoryColor(task.category);
    final statusColor = AppTheme.getStatusColor(task.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
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
                      : colors.textTertiary,
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
                    color: colors.textPrimary,
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
                          TextStyle(fontSize: 12, color: colors.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (task.subtasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: task.subtasks.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final subtask = entry.value;
                        return GestureDetector(
                          onTap: () {
                            context.read<AppState>().toggleSubtaskStatus(task, index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: subtask.isCompleted ? AppTheme.emerald : Colors.transparent,
                                    border: Border.all(
                                      color: subtask.isCompleted ? AppTheme.emerald : colors.textTertiary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: subtask.isCompleted
                                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    subtask.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtask.isCompleted ? colors.textTertiary : colors.textSecondary,
                                      decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
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
    final colors = Theme.of(context).extension<AppThemeColors>()!;
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
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(left: BorderSide(color: colors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
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
                  Text(
                    'UPCOMING DEADLINES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.textTertiary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (upcomingDeadlines.isEmpty)
                    Text(
                      'No upcoming deadlines',
                      style: TextStyle(
                          fontSize: 13, color: colors.textTertiary),
                    )
                  else
                    ...upcomingDeadlines.map((t) => _DeadlineItem(task: t)),
                  const SizedBox(height: 24),
                  Divider(color: colors.border),
                  const SizedBox(height: 16),
                  // Today's tasks
                  Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.textTertiary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (todayTasks.isEmpty)
                    Text(
                      'No tasks scheduled for today',
                      style: TextStyle(
                          fontSize: 13, color: colors.textTertiary),
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
                  Text(
                    'Weekly Report Ready!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your productivity insights',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.textTertiary,
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
    final colors = Theme.of(context).extension<AppThemeColors>()!;
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.scheduledDate != null)
                  Text(
                    _formatDate(task.scheduledDate!),
                    style: TextStyle(
                        fontSize: 10, color: colors.textTertiary),
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
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isActive = task.isTimerRunning;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary.withValues(alpha: 0.1)
            : colors.surfaceVariant.withValues(alpha: 0.5),
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
              color: isActive ? AppTheme.primary : colors.textPrimary,
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
