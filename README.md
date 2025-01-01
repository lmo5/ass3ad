# Modern Flutter App Setup

## Project Structure
```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── constants.dart
├── features/
│   └── home/
│       ├── data/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   └── repositories/
│       └── presentation/
│           ├── pages/
│           └── widgets/
├── shared/
│   ├── widgets/
│   └── services/
└── main.dart
```

## Key Files Content

### lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Flutter App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
```

### lib/core/theme/app_theme.dart
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      // Add more theme customization
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}
```

### lib/features/home/presentation/pages/home_screen.dart
```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome to Modern Flutter App'),
      ),
    );
  }
}
```

## Ubuntu Development Environment Setup

1. Install Flutter:
```bash
sudo snap install flutter --classic
flutter doctor
```

2. Install Android Studio:
```bash
sudo snap install android-studio --classic
```

3. Configure Android Studio:
- Open Android Studio
- Install Flutter plugin: File → Settings → Plugins → Search "Flutter"
- Configure Android SDK: Tools → SDK Manager

4. Setup Android emulator:
```bash
# Open Android Studio
# Tools → Device Manager → Create Device
```

5. VS Code Setup (Recommended):
```bash
sudo snap install code --classic
# Install Flutter extension from VS Code marketplace
```

6. Create and run project:
```bash
flutter create my_app
cd my_app
flutter run
```

## Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^12.0.0
  flutter_bloc: ^8.1.3
  dio: ^5.3.0
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```