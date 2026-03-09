import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import '../database/database.dart';
import '../models/task.dart';

/// Reporting module for CSV export and summary generation.
class ReportingService {
  /// Export all tasks to CSV
  static Future<String?> exportTasksToCSV() async {
    final tasks = await AppDatabase.getAllTasks();
    if (tasks.isEmpty) return null;

    final headers = [
      'ID', 'Title', 'Description', 'Category', 'Priority', 'Status',
      'Scheduled Date', 'Created At', 'Completed At', 'Time Spent (seconds)',
      'Time Spent (formatted)',
    ];

    final rows = tasks.map((t) => [
      t.id,
      t.title,
      t.description,
      t.category,
      t.priority,
      t.status,
      t.scheduledDate != null ? DateFormat('yyyy-MM-dd').format(t.scheduledDate!) : '',
      DateFormat('yyyy-MM-dd HH:mm').format(t.createdAt),
      t.completedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(t.completedAt!) : '',
      t.timeSpentSeconds,
      t.formattedTimeFriendly,
    ]).toList();

    final csv = _toCsv([headers, ...rows]);

    // Show save dialog
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Tasks CSV',
      fileName: 'tasks_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsString(csv);
      return result;
    }
    return null;
  }

  /// Import tasks from CSV
  static Future<List<Task>?> importTasksFromCSV() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Tasks CSV Export',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    String contents;
    try {
      contents = await file.readAsString();
    } on FormatException {
      // Fallback to latin1 if not valid UTF-8 (common with Excel CSV exports)
      final bytes = await file.readAsBytes();
      contents = latin1.decode(bytes);
    } catch (e) {
      // Catch any other read errors
      return null;
    }
    
    final fields = csv.decode(contents);

    if (fields.isEmpty || fields.length < 2) return [];

    final tasks = <Task>[];
    // Start from row index 1 to skip headers
    for (int i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length < 10) continue; // safety check

      tasks.add(Task(
        id: int.tryParse(row[0].toString()),
        title: row[1]?.toString() ?? '',
        description: row[2]?.toString() ?? '',
        category: row[3]?.toString() ?? 'General',
        priority: row[4]?.toString() ?? 'Medium',
        status: row[5]?.toString() ?? 'Pending',
        scheduledDate: row[6] != null && row[6].toString().isNotEmpty
            ? DateTime.tryParse(row[6].toString())
            : null,
        createdAt: row[7] != null && row[7].toString().isNotEmpty
            ? DateTime.tryParse(row[7].toString())
            : null,
        completedAt: row[8] != null && row[8].toString().isNotEmpty
            ? DateTime.tryParse(row[8].toString())
            : null,
        timeSpentSeconds: int.tryParse(row[9].toString()) ?? 0,
      ));
    }
    return tasks;
  }

  /// Export analytics summary to CSV
  static Future<String?> exportAnalyticsToCSV() async {
    final totalTasks = await AppDatabase.getTotalTaskCount();
    final completedTasks = await AppDatabase.getCompletedTaskCount();
    final pendingTasks = await AppDatabase.getPendingTaskCount();
    final hoursLogged = await AppDatabase.getTotalHoursLogged();
    final categories = await AppDatabase.getCategoryDistribution();

    final headers = ['Metric', 'Value'];
    final rows = [
      headers,
      ['Total Tasks', totalTasks],
      ['Completed Tasks', completedTasks],
      ['Pending Tasks', pendingTasks],
      ['Hours Logged', hoursLogged.toStringAsFixed(1)],
      ['Efficiency Rate', '${(totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0).toStringAsFixed(1)}%'],
      [''],
      ['Category', 'Count'],
      ...categories.entries.map((e) => [e.key, e.value]),
    ];

    final csv = _toCsv(rows);

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Analytics CSV',
      fileName: 'analytics_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsString(csv);
      return result;
    }
    return null;
  }

  /// Generate weekly report data
  static Future<Map<String, dynamic>> generateWeeklyReport() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    // Current week tasks
    final tasks = await AppDatabase.getTasksInRange(monday, sunday);
    final completed = tasks.where((t) => t.status == 'Completed').toList();
    final totalTime = tasks.fold<int>(0, (s, t) => s + t.timeSpentSeconds);

    // Previous week for comparison
    final prevMonday = monday.subtract(const Duration(days: 7));
    final prevSunday = monday.subtract(const Duration(days: 1));
    final prevTasks = await AppDatabase.getTasksInRange(prevMonday, prevSunday);
    final prevCompleted = prevTasks.where((t) => t.status == 'Completed').length;

    // Category breakdown
    final categories = <String, int>{};
    for (final t in tasks) {
      categories[t.category] = (categories[t.category] ?? 0) + 1;
    }

    // Percentage change
    final changePercent = prevCompleted > 0
        ? ((completed.length - prevCompleted) / prevCompleted * 100).round()
        : 0;

    return {
      'startDate': monday,
      'endDate': sunday,
      'totalTasks': tasks.length,
      'completedTasks': completed.length,
      'totalTimeHours': totalTime / 3600.0,
      'changePercent': changePercent,
      'categories': categories,
      'insights': _generateInsights(tasks, completed, totalTime),
    };
  }

  static List<Map<String, String>> _generateInsights(
      List<Task> allTasks, List<Task> completed, int totalTimeSeconds) {
    final insights = <Map<String, String>>[];

    // Completion insight
    if (completed.isNotEmpty) {
      insights.add({
        'icon': 'check',
        'color': 'green',
        'text':
            'Completed ${completed.length} tasks this week.',
      });
    }

    // Time insight
    final totalHours = totalTimeSeconds / 3600.0;
    if (totalHours > 0) {
      insights.add({
        'icon': 'info',
        'color': 'blue',
        'text': 'Total focus time: ${totalHours.toStringAsFixed(1)} hours.',
      });
    }

    // Pending insight
    final pending = allTasks.where((t) => t.status == 'Pending').length;
    if (pending > 0) {
      insights.add({
        'icon': 'warning',
        'color': 'orange',
        'text': '$pending tasks still pending. Consider prioritizing them.',
      });
    }

    return insights;
  }

  /// Simple CSV converter
  static String _toCsv(List<List<dynamic>> rows) {
    return rows.map((row) {
      return row.map((cell) {
        final s = cell.toString();
        if (s.contains(',') || s.contains('"') || s.contains('\n')) {
          return '"${s.replaceAll('"', '""')}"';
        }
        return s;
      }).join(',');
    }).join('\n');
  }
}
