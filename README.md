<p align="center">
  <img src="AppLogo/Task Flow.png" alt="TaskFlow Logo" width="120" />
</p>

<h1 align="center">TaskFlow</h1>

<p align="center">
  <strong>A modern, feature-rich task management app built with Flutter for Windows Desktop.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.3.18-blue?style=flat-square" alt="Version" />
  <img src="https://img.shields.io/badge/platform-Windows-0078D6?style=flat-square&logo=windows" alt="Platform" />
  <img src="https://img.shields.io/badge/built_with-Flutter-02569B?style=flat-square&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License" />
</p>

---

## 🖼️ Preview

<!-- Replace with your app screenshot -->
> ![App Preview](screenshots/app_preview.png)

---

## ✨ Features

### 📊 Dashboard & Activity Overview

Get a bird's-eye view of your productivity with real-time KPI cards, a weekly productivity bar chart, category distribution donut chart, and a recent tasks table — all in one place.

<!-- Replace with dashboard screenshot -->
> ![Dashboard](screenshots/dashboard.png)

---

### ✅ Task Management

Create, edit, and organize tasks with support for:

- **Categories** — Organize by Development, Design, Research, Marketing & custom categories
- **Priorities** — High, Medium, Low with color-coded indicators
- **Statuses** — Pending, In Progress, Completed
- **Subtasks** — Break tasks down into smaller, trackable items
- **Scheduled Dates with Time** — Set precise date & time for task deadlines
- **Time Tracking** — Built-in timer to log hours spent on each task

<!-- Replace with task management screenshot -->
> ![Task Management](screenshots/tasks.png)

---

### 📅 Calendar View

Visualize your tasks across **Month**, **Week**, and **Day** views with:

- Drag & drop task rescheduling
- Color-coded task indicators on each day
- Day detail panel for quick task overview
- Seamless navigation across months and years (supports dates far into the future)

<!-- Replace with calendar screenshot -->
> ![Calendar View](screenshots/calendar.png)

---

### 📈 Analytics & Reports

Dive deep into your productivity metrics:

- Task completion trends & efficiency rates
- Radar chart for multi-category analysis
- Status breakdown with visual charts
- **CSV Export** — Export all task data including subtasks
- **CSV Import** — Upload and sync tasks from spreadsheets

<!-- Replace with analytics screenshot -->
> ![Analytics](screenshots/analytics.png)

---

### 🔔 Daily Task Reminder

On your first launch each day, TaskFlow greets you with a popup showing all tasks scheduled for that day — so you never miss a beat.

<!-- Replace with reminder popup screenshot -->
> ![Daily Reminder](screenshots/daily_reminder.png)

---

### 🌗 Dark & Light Mode

Switch between a sleek dark theme and a clean light theme from Settings. Your preference is saved automatically.

<!-- Replace with theme comparison screenshot -->
> ![Theme Toggle](screenshots/themes.png)

---

### 📋 Weekly Productivity Line Chart

Click **"View details"** on the dashboard's Weekly Productivity card to open an interactive line chart view showing your daily task completions for the current week.

<!-- Replace with line chart screenshot -->
> ![Line Chart](screenshots/line_chart.png)

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.11+)
- Windows 10/11
- Visual Studio with C++ desktop development workload

### Installation

```bash
# Clone the repository
git clone https://github.com/Robel-rai/stitch_task_management.git
cd stitch_task_management

# Install dependencies
flutter pub get

# Run the app
flutter run -d windows
```

### Build for Production

```bash
# Build a release executable
flutter build windows --release
```

The built executable will be at:
```
build/windows/x64/runner/Release/task_recorder_pro.exe
```

### Create an Installer

This project includes an [Inno Setup](https://jrsoftware.org/isinfo.php) script for creating a Windows installer:

1. Install Inno Setup
2. Build the release version first (`flutter build windows --release`)
3. Open `TaskFlowExe/TaskFlow.iss` in Inno Setup
4. Click **Build → Compile**
5. The installer will be generated in the `TaskFlowExe/` directory

---

## 🗂️ Project Structure

```
lib/
├── database/          # SQLite database layer
│   └── database.dart
├── models/            # Data models (Task, Subtask)
│   └── task.dart
├── providers/         # State management (Provider)
│   └── app_state.dart
├── screens/           # App screens
│   ├── dashboard_screen.dart
│   ├── tasks_screen.dart
│   ├── calendar_screen.dart
│   ├── analytics_screen.dart
│   └── settings_screen.dart
├── services/          # Business logic services
│   ├── notification_service.dart
│   └── reporting_service.dart
├── theme/             # Theming & colors
│   ├── app_theme.dart
│   └── app_colors.dart
├── widgets/           # Reusable UI components
│   ├── sidebar.dart
│   ├── task_dialog.dart
│   └── kpi_card.dart
└── main.dart          # App entry point
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform UI framework |
| **SQLite (sqflite_ffi)** | Local database storage |
| **Provider** | State management |
| **fl_chart** | Beautiful charts & graphs |
| **SharedPreferences** | Persistent settings & preferences |
| **Inno Setup** | Windows installer creation |

---

## 📝 Key Highlights

- 🗄️ **Portable Data** — In release builds, the database is stored alongside the app executable
- 🔄 **CSV Sync** — Import/export tasks seamlessly with subtask support
- ⏱️ **Built-in Timer** — Track time spent on tasks with start/stop functionality
- 🔔 **Smart Notifications** — Alerts for long-running tasks and daily reminders
- 🎨 **Premium UI** — Modern, polished interface with smooth animations

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ using Flutter
</p>
