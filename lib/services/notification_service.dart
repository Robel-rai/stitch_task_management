import 'package:flutter/material.dart';
import '../database/database.dart';

/// Notification system using in-app snackbars and checking for unfinished tasks.
class NotificationService {
  /// Check for unfinished tasks and show reminder
  static Future<void> checkUnfinishedTasks(BuildContext context) async {
    final pending = await AppDatabase.getPendingTaskCount();
    if (pending > 0 && context.mounted) {
      _showNotification(
        context,
        icon: Icons.pending_actions,
        title: 'Pending Tasks',
        message: 'You have $pending unfinished tasks. Keep going!',
        color: Colors.amber,
      );
    }
  }

  /// Check for tasks due today
  static Future<void> checkDeadlineAlerts(BuildContext context) async {
    final todayTasks = await AppDatabase.getTasksForDate(DateTime.now());
    final incomplete = todayTasks.where((t) => t.status != 'Completed').length;
    if (incomplete > 0 && context.mounted) {
      _showNotification(
        context,
        icon: Icons.calendar_today,
        title: 'Due Today',
        message: '$incomplete tasks scheduled for today need attention.',
        color: const Color(0xFFF43F5E),
      );
    }
  }

  /// Daily summary notification
  static Future<void> showDailySummary(BuildContext context) async {
    final today = await AppDatabase.getCompletedTasksToday();
    final hours = await AppDatabase.getTotalHoursLogged();
    if (context.mounted) {
      _showNotification(
        context,
        icon: Icons.auto_awesome,
        title: 'Daily Summary',
        message:
            'Completed $today tasks today. Total ${hours.toStringAsFixed(1)}h logged.',
        color: const Color(0xFF0D0DF2),
      );
    }
  }

  static void _showNotification(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 400,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
