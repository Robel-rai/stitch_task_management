import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

/// Dialog for creating or editing a task.
class TaskDialog extends StatefulWidget {
  final Task? task; // null = create mode

  const TaskDialog({super.key, this.task});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  String _category = 'General';
  String _priority = 'Medium';
  String _status = 'Pending';
  DateTime? _scheduledDate;
  late DateTime _createdAt;

  static const categories = [
    'General',
    'Development',
    'Design',
    'Research',
    'Marketing',
    'Management',
    'UI Design',
    'Work',
    'Study',
    'Health',
  ];
  static const priorities = ['Low', 'Medium', 'High'];
  static const statuses = ['Pending', 'In Progress', 'Completed'];

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    _createdAt = widget.task?.createdAt ?? DateTime.now();
    if (widget.task != null) {
      _category = widget.task!.category;
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      _scheduledDate = widget.task!.scheduledDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Task' : 'New Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            _buildField('Title', _titleCtrl, 'Enter task title...', colors),
            const SizedBox(height: 16),

            // Description
            _buildField('Description', _descCtrl, 'Enter description...', colors,
                maxLines: 3),
            const SizedBox(height: 16),

            // Category + Priority row
            Row(
              children: [
                Expanded(child: _buildDropdown('Category', _category, categories,
                    (v) => setState(() => _category = v!), colors)),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown('Priority', _priority, priorities,
                    (v) => setState(() => _priority = v!), colors)),
              ],
            ),
            const SizedBox(height: 16),

            // Status
            _buildDropdown('Status', _status, statuses,
                (v) => setState(() => _status = v!), colors),
            const SizedBox(height: 16),

            // Scheduled Date
            _buildDatePicker(colors),
            const SizedBox(height: 16),

            // Created At
            _buildCreatedAtPicker(colors),
            const SizedBox(height: 28),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text(isEditing ? 'Update' : 'Create'),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController ctrl, String hint, AppThemeColors colors,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String label, String value, List<String> items, ValueChanged<String?> onChanged, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: colors.surfaceVariant,
            style: TextStyle(fontSize: 14, color: colors.textPrimary),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildCreatedAtPicker(AppThemeColors colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Created At',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _createdAt,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
                    colorScheme: isDark
                        ? ColorScheme.dark(
                            primary: AppTheme.primary,
                            surface: colors.surface,
                          )
                        : ColorScheme.light(
                            primary: AppTheme.primary,
                            surface: colors.surface,
                          ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              if (!mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_createdAt),
                builder: (context, child) {
                  return Theme(
                    data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
                      colorScheme: isDark
                          ? ColorScheme.dark(
                              primary: AppTheme.primary,
                              surface: colors.surface,
                            )
                          : ColorScheme.light(
                              primary: AppTheme.primary,
                              surface: colors.surface,
                            ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() => _createdAt = DateTime(
                    date.year, date.month, date.day, time.hour, time.minute));
              } else {
                setState(() => _createdAt = DateTime(
                    date.year, date.month, date.day, _createdAt.hour, _createdAt.minute));
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: 16, color: colors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  DateFormat('MMM dd, yyyy hh:mm a').format(_createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(AppThemeColors colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduled Date',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _scheduledDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
                    colorScheme: isDark
                        ? ColorScheme.dark(
                            primary: AppTheme.primary,
                            surface: colors.surface,
                          )
                        : ColorScheme.light(
                            primary: AppTheme.primary,
                            surface: colors.surface,
                          ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _scheduledDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: colors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  _scheduledDate != null
                      ? DateFormat('MMM dd, yyyy').format(_scheduledDate!)
                      : 'Select date...',
                  style: TextStyle(
                    fontSize: 14,
                    color: _scheduledDate != null
                        ? colors.textPrimary
                        : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;

    final task = Task(
      id: widget.task?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      priority: _priority,
      status: _status,
      scheduledDate: _scheduledDate,
      createdAt: _createdAt,
      completedAt: _status == 'Completed'
          ? (widget.task?.completedAt ?? DateTime.now())
          : null,
      timeSpentSeconds: widget.task?.timeSpentSeconds ?? 0,
      timerStartedAt: widget.task?.timerStartedAt,
    );
    Navigator.pop(context, task);
  }
}
