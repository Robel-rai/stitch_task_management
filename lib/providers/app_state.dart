import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

/// Global application state managed by ChangeNotifier.
/// All views listen to this for data changes.
class AppState extends ChangeNotifier with WidgetsBindingObserver {
  // ─── Theme ───
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // ─── Navigation ───
  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  // ─── Task Data ───
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  // ─── Filters ───
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _categoryFilter;
  String? get categoryFilter => _categoryFilter;

  String? _statusFilter;
  String? get statusFilter => _statusFilter;

  String? _priorityFilter;
  String? get priorityFilter => _priorityFilter;

  // ─── Dashboard Metrics ───
  int _totalTasks = 0;
  int get totalTasks => _totalTasks;

  int _completedTasks = 0;
  int get completedTasks => _completedTasks;

  int _pendingTasks = 0;
  int get pendingTasks => _pendingTasks;

  double _hoursLogged = 0;
  double get hoursLogged => _hoursLogged;

  double _efficiencyRate = 0;
  double get efficiencyRate => _efficiencyRate;

  Map<String, int> _categoryDistribution = {};
  Map<String, int> get categoryDistribution => _categoryDistribution;

  Map<int, int> _weeklyCompletionCounts = {};
  Map<int, int> get weeklyCompletionCounts => _weeklyCompletionCounts;

  List<Task> _recentTasks = [];
  List<Task> get recentTasks => _recentTasks;

  // ─── Custom Categories ───
  List<String> _customCategories = [];
  List<String> get customCategories => _customCategories;

  // ─── Lifecycle & Notifications ───
  bool _isAppVisible = true;
  final Set<int> _notifiedTaskIds = {}; // keeps track of tasks that triggered break reminder

  List<Task> get notificationTasks => _tasks.where((t) => t.isTimerRunning).toList();

  // ─── Timer ───
  Timer? _timerUpdateTimer;

  // ─── Calendar ───
  DateTime _selectedCalendarDate = DateTime.now();
  DateTime get selectedCalendarDate => _selectedCalendarDate;

  DateTime _viewingMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get viewingMonth => _viewingMonth;

  List<Task> _selectedDayTasks = [];
  List<Task> get selectedDayTasks => _selectedDayTasks;

  void setViewingMonth(DateTime month) {
    _viewingMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  Future<void> selectCalendarDate(DateTime date) async {
    _selectedCalendarDate = date;
    _selectedDayTasks = await AppDatabase.getTasksForDate(date);
    notifyListeners();
  }

  // ─── Navigation ───
  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  // ─── Initialization ───
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _customCategories = prefs.getStringList('customCategories') ?? [];
    
    await refreshAll();
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Start periodic timer updates for running timers
    _timerUpdateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final runningTasks = _tasks.where((t) => t.isTimerRunning);
        if (runningTasks.isNotEmpty) {
          notifyListeners();
          
          // Check for break reminder
          for (final task in runningTasks) {
            if (task.id == null) continue;
            final totalElapsed = task.timeSpentSeconds + 
                DateTime.now().difference(task.timerStartedAt!).inSeconds;
            
            // 7200 seconds = 2 hours
            if (totalElapsed >= 7200 && !_notifiedTaskIds.contains(task.id)) {
              _notifiedTaskIds.add(task.id!);
              NotificationService.showBreakReminder(
                _isAppVisible,
                task.title,
              );
            }
          }
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppVisible = true;
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _isAppVisible = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timerUpdateTimer?.cancel();
    super.dispose();
  }

  /// Refresh everything from database
  Future<void> refreshAll() async {
    await Future.wait([
      refreshTasks(),
      refreshMetrics(),
    ]);
  }

  /// Refresh task list with current filters
  Future<void> refreshTasks() async {
    _tasks = await AppDatabase.getAllTasks(
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      categoryFilter: _categoryFilter,
      statusFilter: _statusFilter,
      priorityFilter: _priorityFilter,
    );
    notifyListeners();
  }

  /// Refresh dashboard/analytics metrics
  Future<void> refreshMetrics() async {
    _totalTasks = await AppDatabase.getTotalTaskCount();
    _completedTasks = await AppDatabase.getCompletedTaskCount();
    _pendingTasks = await AppDatabase.getPendingTaskCount();
    _hoursLogged = await AppDatabase.getTotalHoursLogged();
    _efficiencyRate = _totalTasks > 0
        ? (_completedTasks / _totalTasks) * 100
        : 0;
    _categoryDistribution = await AppDatabase.getCategoryDistribution();
    _weeklyCompletionCounts = await AppDatabase.getWeeklyCompletionCounts();
    _recentTasks = await AppDatabase.getRecentTasks();
    notifyListeners();
  }

  // ─── Search/Filter ───
  void setSearchQuery(String query) {
    _searchQuery = query;
    refreshTasks();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    refreshTasks();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    refreshTasks();
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    refreshTasks();
  }

  void clearFilters() {
    _categoryFilter = null;
    _statusFilter = null;
    _priorityFilter = null;
    _searchQuery = '';
    refreshTasks();
  }

  // ─── Custom Categories Operations ───
  Future<void> addCustomCategory(String category) async {
    if (category.trim().isEmpty) return;
    if (!_customCategories.contains(category)) {
      _customCategories.add(category);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('customCategories', _customCategories);
    }
  }

  Future<void> removeCustomCategory(String category) async {
    if (_customCategories.contains(category)) {
      _customCategories.remove(category);
      // Remove from category filter if currently selected
      if (_categoryFilter == category) {
        setCategoryFilter(null);
      } else {
        notifyListeners();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('customCategories', _customCategories);
    }
  }

  // ─── Task Operations ───
  Future<void> createTask(Task task) async {
    await AppDatabase.insertTask(task);
    await refreshAll();
  }

  Future<void> updateTask(Task task) async {
    await AppDatabase.updateTask(task);
    await refreshAll();
  }

  Future<void> deleteTask(int id) async {
    await AppDatabase.deleteTask(id);
    await refreshAll();
  }

  Future<List<Task>> syncTasksFromCSV(List<Task> importedTasks) async {
    final existingTasks = await AppDatabase.getAllTasks();
    final existingIds = existingTasks.map((t) => t.id).toSet();
    
    final newTasks = <Task>[];
    for (final task in importedTasks) {
      if (task.id != null && existingIds.contains(task.id)) {
        await AppDatabase.updateTask(task);
      } else {
        newTasks.add(task);
      }
    }
    await refreshAll();
    return newTasks;
  }

  Future<void> toggleTaskStatus(Task task, {bool resumeTimer = false}) async {
    Task updated;
    if (task.status == 'Completed') {
      updated = task.copyWith(
        status: resumeTimer ? 'In Progress' : 'Pending',
        clearCompletedAt: true,
      );
      if (resumeTimer) {
        updated = updated.copyWith(timerStartedAt: DateTime.now());
      }
    } else {
      updated = task.copyWith(
        status: 'Completed',
        completedAt: DateTime.now(),
        clearTimerStartedAt: true,
      );
      // Stop timer if running
      if (task.isTimerRunning) {
        final elapsed =
            DateTime.now().difference(task.timerStartedAt!).inSeconds;
        updated = updated.copyWith(
          timeSpentSeconds: task.timeSpentSeconds + elapsed,
        );
      }
    }
    await AppDatabase.updateTask(updated);
    await refreshAll();
  }

  Future<void> startTimer(Task task) async {
    final updated = task.copyWith(
      timerStartedAt: DateTime.now(),
      status: 'In Progress',
    );
    await AppDatabase.updateTask(updated);
    await refreshAll();
  }

  Future<void> stopTimer(Task task) async {
    if (task.timerStartedAt == null) return;
    final elapsed =
        DateTime.now().difference(task.timerStartedAt!).inSeconds;
    final updated = task.copyWith(
      timeSpentSeconds: task.timeSpentSeconds + elapsed,
      clearTimerStartedAt: true,
    );
    await AppDatabase.updateTask(updated);
    await refreshAll();
  }

  Future<void> rescheduleTask(int taskId, DateTime newDate) async {
    final task = await AppDatabase.getTask(taskId);
    if (task != null) {
      final updated = task.copyWith(scheduledDate: newDate);
      await AppDatabase.updateTask(updated);
      await refreshAll();
      await selectCalendarDate(_selectedCalendarDate);
    }
  }

  void reorderDayTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _selectedDayTasks.removeAt(oldIndex);
    _selectedDayTasks.insert(newIndex, item);
    notifyListeners();
  }
}
