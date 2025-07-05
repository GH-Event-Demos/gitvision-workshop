import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/main_screen.dart';
import 'config/api_config.dart';
import 'services/logging_service.dart';

void main() {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web-specific initialization can go here
  }
  
  ApiConfig.printDebugInfo();
  
  runApp(const GitVisionApp());
}

class GitVisionApp extends StatelessWidget {
  const GitVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitVision - Eurovision Edition',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

