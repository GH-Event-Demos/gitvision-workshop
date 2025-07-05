import 'package:flutter/material.dart';
import '../services/playlist_generator.dart';

class SongPlayerWidget extends StatefulWidget {
  final Map<String, dynamic> song;
  final PlaylistGenerator playlistGenerator;
  
  const SongPlayerWidget({
    Key? key,
    required this.song,
    required this.playlistGenerator,
  }) : super(key: key);

  @override
  State<SongPlayerWidget> createState() => _SongPlayerWidgetState();
}

class _SongPlayerWidgetState extends State<SongPlayerWidget> {
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final bool isPlayable = widget.song['isPlayable'] == true;
    
    return Row(
      children: [
        // Play button
        IconButton(
          icon: _isLoading 
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: isPlayable ? _togglePlayback : _openExternalPlayer,
          tooltip: isPlayable 
              ? (_isPlaying ? 'Pause' : 'Play') 
              : 'Open in Spotify',
        ),
        
        // Song info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.song['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${widget.song['artist']} (${widget.song['country']} ${widget.song['year']})',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 11, 
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
        
        // Spotify link
        if (widget.song['webPlayerUrl'] != null)
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 20),
            onPressed: _openExternalPlayer,
            tooltip: 'Open in Spotify',
          ),
      ],
    );
  }

  Future<void> _togglePlayback() async {
    if (_isLoading) return;
    
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    
    try {
      if (_isPlaying) {
        await widget.playlistGenerator.pausePlayback();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await widget.playlistGenerator.playSong(widget.song);
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Playback error';
      });
      print('Error playing song: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openExternalPlayer() async {
    final String? url = widget.song['webPlayerUrl'] ?? widget.song['spotifyUrl'];
    if (url == null) {
      setState(() {
        _errorMessage = 'No external link available';
      });
      return;
    }
    
    try {
      await widget.playlistGenerator.playSong(widget.song);
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not open player';
      });
      print('Error opening external player: $e');
    }
  }
}
