import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/app_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/sidebar.dart';

void main() {
  // Initialize FFI for Windows desktop SQLite support
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const TaskRecorderProApp());
}

class TaskRecorderProApp extends StatelessWidget {
  const TaskRecorderProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Taskflow',
            debugShowCheckedModeBanner: false,
            theme: state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          const Sidebar(),
          // Main Content
          Expanded(
            child: Consumer<AppState>(
              builder: (context, state, _) {
                return IndexedStack(
                  index: state.currentNavIndex,
                  children: const [
                    DashboardScreen(),
                    TasksScreen(),
                    CalendarScreen(),
                    AnalyticsScreen(),
                    SettingsScreen(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

