Task Management App

📌 Overview

This is a Task Management App built with Flutter and state management using Riverpod. It allows users to:

Add, edit, delete, and view tasks.

Mark tasks as Completed or Pending.

Sort tasks by Date or Priority.

Persist data using SQLite for tasks and Hive for user preferences (e.g., dark mode, sort order).

Support for tablet devices with a split-view layout.

🚀 Getting Started

1 Prerequisites

Before running the app, ensure you have the following installed:

Flutter SDK

Dart SDK

Android Studio or Visual Studio Code (Optional, for development)

Emulator or Physical Device for testing

2 Install Dependencies
flutter pub get

3 Set Up Hive for User Preferences
flutter packages pub run build_runner build

4 Run the App
flutter run

Features Implemented

Task CRUD Operations (Add, Edit, Delete, View)
Task Sorting by Date & Priority
State Management using Riverpod
Dark/Light Mode using Hive
Tablet Split-View UI
Animations for Theme Switching

Troubleshooting

Common Issues & Fixes
SQLite "no such column" error: Run flutter clean and restart the app to apply database changes.
Hive not persisting data: Ensure you run flutter packages pub run build_runner build after adding new fields.
App crashes on startup: Check for missing dependencies using flutter pub get.
