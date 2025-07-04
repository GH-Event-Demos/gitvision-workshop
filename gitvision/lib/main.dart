import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'constants/app_constants.dart';
import 'config/api_config.dart';
import 'services/github_service.dart';
import 'services/spotify_service.dart';
import 'services/playlist_generator.dart';
import 'services/logging_service.dart';
import 'services/analytics_service.dart';
import 'services/error_handling_service.dart';
import 'services/theme_provider.dart';
import 'repositories/playlist_repository.dart';
import 'repositories/github_repository.dart';
import 'providers/app_state_provider.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure image cache
  PaintingBinding.instance.imageCache.maximumSize = AppConstants.imageCacheMaxSize;
  PaintingBinding.instance.imageCache.maximumSizeBytes = AppConstants.imageCacheMaxSizeBytes;

  // Initialize logging service
  LoggingService().initialize(enableDebugLogs: true);
  
  runApp(const GitVisionApp());
}

class GitVisionApp extends StatelessWidget {
  const GitVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Service Providers (using ProxyProvider to access dependencies)
        Provider<LoggingService>(create: (_) => LoggingService()),
        Provider<AnalyticsService>(create: (_) => AnalyticsService()),
        Provider<ErrorHandlingService>(create: (_) => ErrorHandlingService()),
        Provider<AudioPlayer>(create: (_) => AudioPlayer()),
        
        // API Services
        Provider<GitHubService>(create: (_) => GitHubService()),
        ProxyProvider<LoggingService, SpotifyService>(
          update: (_, logger, __) => SpotifyService(
            clientId: ApiConfig.spotifyClientId,
            clientSecret: ApiConfig.spotifyClientSecret,
          ),
        ),
        
        // Repository Layer
        ProxyProvider3<GitHubService, SpotifyService, LoggingService, PlaylistGenerator>(
          update: (_, githubService, spotifyService, logger, __) => PlaylistGenerator(
            githubToken: ApiConfig.githubToken,
            spotifyService: spotifyService,
          ),
        ),
        
        ProxyProvider3<PlaylistGenerator, SpotifyService, LoggingService, PlaylistRepository>(
          update: (_, playlistGenerator, spotifyService, logger, __) => PlaylistRepository(
            playlistGenerator: playlistGenerator,
            spotifyService: spotifyService,
            logger: logger,
          ),
        ),
        
        ProxyProvider2<GitHubService, LoggingService, GitHubRepository>(
          update: (_, githubService, logger, __) => GitHubRepository(
            githubService: githubService,
            logger: logger,
          ),
        ),
        
        // Main App State Provider
        ChangeNotifierProxyProvider6<
          PlaylistRepository,
          GitHubRepository,
          LoggingService,
          AnalyticsService,
          ErrorHandlingService,
          AudioPlayer,
          AppStateProvider
        >(
          create: (context) => AppStateProvider(
            playlistRepository: context.read<PlaylistRepository>(),
            githubRepository: context.read<GitHubRepository>(),
            logger: context.read<LoggingService>(),
            analytics: context.read<AnalyticsService>(),
            errorHandler: context.read<ErrorHandlingService>(),
            audioPlayer: context.read<AudioPlayer>(),
          ),
          update: (_, playlistRepo, githubRepo, logger, analytics, errorHandler, audioPlayer, previous) {
            return previous ?? AppStateProvider(
              playlistRepository: playlistRepo,
              githubRepository: githubRepo,
              logger: logger,
              analytics: analytics,
              errorHandler: errorHandler,
              audioPlayer: audioPlayer,
            );
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'GitVision',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
              colorScheme: themeProvider.isDarkMode
                  ? ColorScheme.fromSeed(
                      seedColor: themeProvider.primaryColor,
                      brightness: Brightness.dark,
                    )
                  : ColorScheme.fromSeed(
                      seedColor: themeProvider.primaryColor,
                      brightness: Brightness.light,
                    ),
            ),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

