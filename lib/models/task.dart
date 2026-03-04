class Task {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String priority; // High, Medium, Low
  final String status; // Pending, In Progress, Completed
  final DateTime? scheduledDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int timeSpentSeconds;
  // Time tracking state (not persisted in DB directly)
  final DateTime? timerStartedAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.category = 'General',
    this.priority = 'Medium',
    this.status = 'Pending',
    this.scheduledDate,
    DateTime? createdAt,
    this.completedAt,
    this.timeSpentSeconds = 0,
    this.timerStartedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    DateTime? scheduledDate,
    DateTime? createdAt,
    DateTime? completedAt,
    int? timeSpentSeconds,
    DateTime? timerStartedAt,
    bool clearCompletedAt = false,
    bool clearTimerStartedAt = false,
    bool clearScheduledDate = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      scheduledDate: clearScheduledDate ? null : (scheduledDate ?? this.scheduledDate),
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      timerStartedAt: clearTimerStartedAt ? null : (timerStartedAt ?? this.timerStartedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'time_spent_seconds': timeSpentSeconds,
      'timer_started_at': timerStartedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'General',
      priority: (map['priority'] as String?) ?? 'Medium',
      status: (map['status'] as String?) ?? 'Pending',
      scheduledDate: map['scheduled_date'] != null
          ? DateTime.tryParse(map['scheduled_date'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      timeSpentSeconds: (map['time_spent_seconds'] as int?) ?? 0,
      timerStartedAt: map['timer_started_at'] != null
          ? DateTime.tryParse(map['timer_started_at'] as String)
          : null,
    );
  }

  /// Formatted time spent as HH:MM:SS
  String get formattedTimeSpent {
    final h = (timeSpentSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((timeSpentSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (timeSpentSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Formatted time as Xh Ym
  String get formattedTimeFriendly {
    final hours = timeSpentSeconds ~/ 3600;
    final minutes = (timeSpentSeconds % 3600) ~/ 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    if (minutes > 0) return '${minutes}m';
    return '0m';
  }

  bool get isTimerRunning => timerStartedAt != null;

  /// Current time spent including live timer
  int get currentTimeSpentSeconds {
    if (timerStartedAt != null) {
      return timeSpentSeconds +
          DateTime.now().difference(timerStartedAt!).inSeconds;
    }
    return timeSpentSeconds;
  }
}
