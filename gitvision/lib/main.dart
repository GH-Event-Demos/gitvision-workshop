import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'services/github_service.dart';
import 'services/logging_service.dart';
import 'services/sentiment_service.dart';
import 'config/api_config.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConfig.printDebugInfo();
  
  runApp(const GitVisionApp());
}

class GitVisionApp extends StatelessWidget {
  const GitVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LoggingService>(
          create: (_) {
            final logger = LoggingService();
            logger.initialize(enableDebugLogs: true);
            return logger;
          },
        ),
        
        Provider<GitHubService>(
          create: (context) => GitHubService(
            logger: context.read<LoggingService>(),
          ),
        ),
        
        Provider<SentimentService>(
          create: (context) => SentimentService(
            githubToken: ApiConfig.githubToken,
            logger: context.read<LoggingService>(),
          ),
        ),
        
        ChangeNotifierProvider<AppStateProvider>(
          create: (context) => AppStateProvider(
            githubService: context.read<GitHubService>(),
            sentimentService: context.read<SentimentService>(),
            logger: context.read<LoggingService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'GitVision - Eurovision Edition',
        theme: ThemeData(
          primaryColor: Colors.blue, // Just use default Material colors
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

