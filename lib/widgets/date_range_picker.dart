import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

/// A compact, custom date-range picker dialog that adapts to dark/light themes.
///
/// Usage:
///   final result = await showCustomDateRangePicker(context, startDate, endDate);
///   if (result != null) { ... }
///
/// Returns a [DateTimeRange] on confirm, or null on cancel.
Future<DateTimeRange?> showCustomDateRangePicker(
  BuildContext context, {
  DateTime? initialStart,
  DateTime? initialEnd,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _DateRangePickerDialog(
      initialStart: initialStart,
      initialEnd: initialEnd,
    ),
  );
}

class _DateRangePickerDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const _DateRangePickerDialog({this.initialStart, this.initialEnd});

  @override
  State<_DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog>
    with SingleTickerProviderStateMixin {
  late DateTime _displayedMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _hoverDate; // for live range preview
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;
    _displayedMonth = widget.initialStart ?? DateTime.now();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ─── Date helpers ───

  int _daysInMonth(int year, int month) => DateUtils.getDaysInMonth(year, month);

  int _firstWeekdayOffset(int year, int month) {
    // Monday = 0 … Sunday = 6
    return (DateTime(year, month, 1).weekday - 1) % 7;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInRange(DateTime date) {
    final s = _startDate;
    final e = _endDate ?? _hoverDate;
    if (s == null || e == null) return false;
    final start = s.isBefore(e) ? s : e;
    final end = s.isBefore(e) ? e : s;
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  bool _isRangeStart(DateTime date) =>
      _startDate != null && _isSameDay(date, _startDate!);

  bool _isRangeEnd(DateTime date) {
    if (_endDate != null) return _isSameDay(date, _endDate!);
    if (_hoverDate != null && _startDate != null) {
      return _isSameDay(date, _hoverDate!);
    }
    return false;
  }

  void _onDayTap(DateTime date) {
    setState(() {
      if (_startDate == null || _endDate != null) {
        // First click or reset: set start
        _startDate = date;
        _endDate = null;
      } else {
        // Second click: set end (ensure start <= end)
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  void _confirm() {
    if (_startDate != null) {
      Navigator.of(context).pop(DateTimeRange(
        start: _startDate!,
        end: _endDate ?? _startDate!,
      ));
    }
  }

  void _cancel() => Navigator.of(context).pop(null);

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: 340,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? colors.border.withValues(alpha: 0.6)
                    : colors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(colors, isDark),
                _buildWeekdayRow(colors),
                _buildCalendarGrid(colors, isDark),
                _buildSelectedInfo(colors),
                _buildActions(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors, bool isDark) {
    final monthYear = DateFormat('MMMM yyyy').format(_displayedMonth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Text(
            monthYear,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: _prevMonth,
            colors: colors,
          ),
          const SizedBox(width: 4),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: _nextMonth,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow(AppThemeColors colors) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(AppThemeColors colors, bool isDark) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final daysCount = _daysInMonth(year, month);
    final offset = _firstWeekdayOffset(year, month);
    final today = DateTime.now();

    // Build 6-row grid (42 cells)
    final totalCells = ((offset + daysCount) / 7).ceil() * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: List.generate((totalCells / 7).ceil(), (row) {
          return Row(
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              final dayNum = index - offset + 1;

              if (dayNum < 1 || dayNum > daysCount) {
                return const Expanded(child: SizedBox(height: 38));
              }

              final date = DateTime(year, month, dayNum);
              final isToday = _isSameDay(date, today);
              final isStart = _isRangeStart(date);
              final isEnd = _isRangeEnd(date);
              final inRange = _isInRange(date);
              final isSelected = isStart || isEnd;

              return Expanded(
                child: MouseRegion(
                  onEnter: (_) {
                    if (_startDate != null && _endDate == null) {
                      setState(() => _hoverDate = date);
                    }
                  },
                  child: GestureDetector(
                    onTap: () => _onDayTap(date),
                    child: _DayCell(
                      day: dayNum,
                      isToday: isToday,
                      isSelected: isSelected,
                      isStart: isStart,
                      isEnd: isEnd,
                      inRange: inRange,
                      colors: colors,
                      isDark: isDark,
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedInfo(AppThemeColors colors) {
    if (_startDate == null) return const SizedBox.shrink();

    final fmt = DateFormat('MMM dd, yyyy');
    final startStr = fmt.format(_startDate!);
    final endStr = _endDate != null ? fmt.format(_endDate!) : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range_rounded, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              endStr != null ? '$startStr  →  $endStr' : startStr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _cancel,
              style: TextButton.styleFrom(
                foregroundColor: colors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: colors.border),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _startDate != null ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: colors.surfaceVariant,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small nav arrow button ───
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppThemeColors colors;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: colors.textSecondary),
        ),
      ),
    );
  }
}

// ─── Individual day cell ───
class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isStart;
  final bool isEnd;
  final bool inRange;
  final AppThemeColors colors;
  final bool isDark;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isStart,
    required this.isEnd,
    required this.inRange,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Background strip for range
    final rangeColor = AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.10);
    final selectedColor = AppTheme.primary;

    return Container(
      height: 38,
      decoration: inRange && !isSelected
          ? BoxDecoration(color: rangeColor)
          : inRange && isStart
              ? BoxDecoration(
                  color: rangeColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                )
              : inRange && isEnd
                  ? BoxDecoration(
                      color: rangeColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    )
                  : null,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor
                : isToday
                    ? selectedColor.withValues(alpha: 0.12)
                    : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? AppTheme.primary
                        : colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
