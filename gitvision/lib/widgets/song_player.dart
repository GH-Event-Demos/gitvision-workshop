import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../services/playlist_generator.dart';

class SongPlayer extends StatefulWidget {
  final Map<String, dynamic> song;
  final PlaylistGenerator playlistGenerator;

  const SongPlayer({
    super.key,
    required this.song,
    required this.playlistGenerator,
  });

  @override
  State<SongPlayer> createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer> {
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  late final Map<String, dynamic> _song;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _song = widget.song;
    _listenToPlaybackState();
  }

  @override
  void didUpdateWidget(SongPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song != widget.song) {
      _song = widget.song;
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  void _listenToPlaybackState() {
    _playerStateSubscription?.cancel();
    final player = widget.playlistGenerator.audioPlayer;
    
    player.onPlayerStateChanged.listen((state) {
      print('Player state changed: $state'); // Debug
      if (mounted) {
        setState(() {
          switch (state) {
            case PlayerState.playing:
              _isPlaying = true;
              _isLoading = false;
              _error = null;
              break;
            case PlayerState.paused:
              _isPlaying = false;
              _isLoading = false;
              break;
            case PlayerState.stopped:
            case PlayerState.completed:
              _isPlaying = false;
              _isLoading = false;
              _position = Duration.zero;
              break;
            case PlayerState.disposed:
              _isPlaying = false;
              _isLoading = false;
              _position = Duration.zero;
              _duration = Duration.zero;
              break;
          }
        });
      }
    });

    player.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() => _duration = newDuration);
      }
    });

    player.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() => _position = newPosition);
      }
    });
  }

  Future<void> _handlePlayPause() async {
    if (!mounted) return;

    final hasPreview = _song['previewUrl'] != null && _song['previewUrl'].isNotEmpty;
    if (!hasPreview) {
      // If no preview is available, try to open in Spotify instead
      final webPlayerUrl = _song['webPlayerUrl'];
      if (webPlayerUrl != null && webPlayerUrl.isNotEmpty) {
        final url = Uri.parse(webPlayerUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
      return;
    }

    try {
      setState(() {
        _error = null;
        _isLoading = true;
      });

      if (_isPlaying) {
        print('Pausing playback'); // Debug
        await widget.playlistGenerator.pausePlayback();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      } else {
        print('Starting playback for: ${_song['title']} by ${_song['artist']}'); // Debug
        await widget.playlistGenerator.playSong(_song);
      }
    } catch (e) {
      print('Error in _handlePlayPause: $e'); // Debug
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } catch (e) {
      print('Error in _handlePlayPause: $e'); // Debug
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPreview = _song['previewUrl'] != null && _song['previewUrl'].isNotEmpty;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Album art with gradient overlay
                Stack(
                  children: [
                    if (_song['imageUrl'] != null)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _song['imageUrl'],
                            fit: BoxFit.cover,
                            cacheWidth: 160,
                            cacheHeight: 160,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Song details with enhanced typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _song['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _song['artist'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.flag,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_song['country']} (${_song['year']})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Enhanced player controls
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 48,
                          color: hasPreview 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        onPressed: hasPreview ? _handlePlayPause : null,
                      ),
                    if (!hasPreview)
                      IconButton(
                        icon: const Icon(Icons.launch),
                        onPressed: () async {
                          final url = Uri.parse(_song['webPlayerUrl'] ?? '');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        tooltip: 'Open in Spotify',
                      ),
                  ],
                ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            if (hasPreview) ...[
              const SizedBox(height: 12),
              ProgressBar(
                progress: _position,
                total: _duration,
                onSeek: (duration) {
                  print('Seeking to: $duration');
                  widget.playlistGenerator.seek(duration);
                },
                thumbColor: theme.colorScheme.primary,
                progressBarColor: theme.colorScheme.primary,
                baseBarColor: theme.colorScheme.surfaceContainerHighest,
                bufferedBarColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
