import '../database/database.dart';

/// Analytics engine that calculates all metrics from actual stored task data.
class AnalyticsService {
  /// Productivity score (0-100): weighted combination of efficiency + completion rate
  static Future<int> getProductivityScore() async {
    final total = await AppDatabase.getTotalTaskCount();
    if (total == 0) return 0;
    final completed = await AppDatabase.getCompletedTaskCount();
    final efficiency = (completed / total) * 100;
    // Factor in today's completed tasks for recency bonus
    final todayCompleted = await AppDatabase.getCompletedTasksToday();
    final recencyBonus = (todayCompleted * 5).clamp(0, 20);
    return (efficiency * 0.8 + recencyBonus).round().clamp(0, 100);
  }

  /// Calculate daily streak (consecutive days with at least 1 completed task)
  static Future<int> getDailyStreak() async {
    final allTasks = await AppDatabase.getAllTasks();
    final completedDates = <String>{};
    for (final task in allTasks) {
      if (task.status == 'Completed' && task.completedAt != null) {
        completedDates.add(task.completedAt!.toIso8601String().split('T')[0]);
      }
    }
    if (completedDates.isEmpty) return 0;

    int streak = 0;
    var checkDate = DateTime.now();
    // Check if today has completions, if not start from yesterday
    final todayStr = checkDate.toIso8601String().split('T')[0];
    if (!completedDates.contains(todayStr)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateStr = checkDate.toIso8601String().split('T')[0];
      if (completedDates.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Personal record streak
  static Future<int> getMaxStreak() async {
    final allTasks = await AppDatabase.getAllTasks();
    final completedDates = <String>{};
    for (final task in allTasks) {
      if (task.status == 'Completed' && task.completedAt != null) {
        completedDates.add(task.completedAt!.toIso8601String().split('T')[0]);
      }
    }
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates.toList()..sort();
    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prev = DateTime.parse(sortedDates[i - 1]);
      final curr = DateTime.parse(sortedDates[i]);
      if (curr.difference(prev).inDays == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 1;
      }
    }
    return maxStreak;
  }

  /// Average completion time in minutes
  static Future<double> getAvgCompletionTimeMinutes() async {
    final allTasks = await AppDatabase.getAllTasks(statusFilter: 'Completed');
    if (allTasks.isEmpty) return 0;
    final totalSeconds =
        allTasks.fold<int>(0, (sum, t) => sum + t.timeSpentSeconds);
    return totalSeconds / allTasks.length / 60.0;
  }

  /// Efficiency rate: (Completed / Total Scheduled) * 100
  static Future<double> getEfficiencyRate() async {
    final total = await AppDatabase.getTotalTaskCount();
    if (total == 0) return 0;
    final completed = await AppDatabase.getCompletedTaskCount();
    return (completed / total) * 100;
  }

  /// Focus time per day of the current week (hours)
  static Future<Map<int, double>> getFocusTimePerDayThisWeek() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final focusMap = <int, double>{};

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final tasks = await AppDatabase.getTasksForDate(day);
      final totalSeconds =
          tasks.fold<int>(0, (sum, t) => sum + t.timeSpentSeconds);
      focusMap[i] = totalSeconds / 3600.0;
    }
    return focusMap;
  }

  /// Daily average focus time in hours
  static Future<double> getDailyAvgFocusHours() async {
    final focusMap = await getFocusTimePerDayThisWeek();
    final values = focusMap.values.where((v) => v > 0);
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Weekly summary data
  static Future<Map<String, dynamic>> getWeeklySummary() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final tasks = await AppDatabase.getTasksInRange(monday, sunday);
    final completed = tasks.where((t) => t.status == 'Completed').length;
    final totalTime =
        tasks.fold<int>(0, (sum, t) => sum + t.timeSpentSeconds);

    return {
      'totalTasks': tasks.length,
      'completedTasks': completed,
      'totalTimeHours': totalTime / 3600.0,
      'startDate': monday,
      'endDate': sunday,
    };
  }

  /// Monthly summary data
  static Future<Map<String, dynamic>> getMonthlySummary() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final tasks = await AppDatabase.getTasksInRange(firstDay, lastDay);
    final completed = tasks.where((t) => t.status == 'Completed').length;
    final totalTime =
        tasks.fold<int>(0, (sum, t) => sum + t.timeSpentSeconds);
    final categories = <String, int>{};
    for (final t in tasks) {
      categories[t.category] = (categories[t.category] ?? 0) + 1;
    }

    return {
      'totalTasks': tasks.length,
      'completedTasks': completed,
      'totalTimeHours': totalTime / 3600.0,
      'categories': categories,
      'month': now.month,
      'year': now.year,
    };
  }

  /// Category performance scores (0-100 each)
  static Future<Map<String, double>> getCategoryPerformance() async {
    final allTasks = await AppDatabase.getAllTasks();
    final categories = <String, List<int>>{};
    for (final t in allTasks) {
      categories.putIfAbsent(t.category, () => []);
      categories[t.category]!.add(t.status == 'Completed' ? 1 : 0);
    }
    final result = <String, double>{};
    for (final entry in categories.entries) {
      final total = entry.value.length;
      final completed = entry.value.where((v) => v == 1).length;
      result[entry.key] = total > 0 ? (completed / total) * 100 : 0;
    }
    return result;
  }
}
