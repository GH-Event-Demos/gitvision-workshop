import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state_provider.dart';
import 'repositories/github_repository.dart';
import 'repositories/playlist_repository.dart';
import 'services/playlist_generator.dart';
import 'services/logging_service.dart';
import 'services/github_service.dart';
import 'services/spotify_service.dart';
import 'services/theme_provider.dart';
import 'config/api_config.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConfig.printDebugInfo();
  
  // Initialize LoggingService
  LoggingService().initialize();
  
  runApp(const GitVisionApp());
}

class GitVisionApp extends StatelessWidget {
  const GitVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LoggingService>(
          create: (_) => LoggingService(),
        ),
        
        Provider<SpotifyService>(
          create: (_) => SpotifyService(),
        ),
        
        Provider<PlaylistGenerator>(
          create: (context) => PlaylistGenerator(
            githubToken: ApiConfig.githubToken,
            spotifyService: context.read<SpotifyService>(),
          ),
        ),
        
        Provider<GitHubRepository>(
          create: (context) => GitHubRepository(
            githubService: GitHubService(),
            logger: context.read<LoggingService>(),
          ),
        ),
        
        Provider<PlaylistRepository>(
          create: (context) => PlaylistRepository(
            playlistGenerator: context.read<PlaylistGenerator>(),
            spotifyService: context.read<SpotifyService>(),
            logger: context.read<LoggingService>(),
          ),
        ),
        
        ChangeNotifierProvider<AppStateProvider>(
          create: (context) => AppStateProvider(
            githubRepository: context.read<GitHubRepository>(),
            playlistRepository: context.read<PlaylistRepository>(),
            logger: context.read<LoggingService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'GitVision - Eurovision Edition',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

