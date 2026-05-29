import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../core/constants/app_colors.dart';
import '../../models/video_item.dart';
import '../network_browser/controller/smb_cubit.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;

  const VideoPlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // Media Kit Player
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  bool _showControls = true;
  Timer? _controlsTimer;

  // Custom Controls State
  double _volume = 100.0; // 0 to 200
  double _brightness = 0.5; // 0.0 to 1.0
  bool _isDraggingVolume = false;
  bool _isDraggingBrightness = false;

  // Subscriptions
  late StreamSubscription<bool> playingSub;
  late StreamSubscription<Duration> positionSub;
  late StreamSubscription<Duration> durationSub;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _initBrightness();
    _startControlsTimer();
  }

  Future<void> _initBrightness() async {
    try {
      _brightness = await ScreenBrightness().application;
    } catch (e) {
      _brightness = 0.5;
    }
  }

  void _initPlayer() {
    String playableUrl = widget.video.videoUrl;

    // Constuire l'URL SMB si c'est un fichier réseau
    if (widget.video.category == 'Réseau SMB') {
      final server = context.read<SmbCubit>().activeServer;
      if (server != null) {
        final auth = (server.username != null && server.username!.isNotEmpty)
            ? '${server.username}:${server.password}@'
            : '';
        final path = playableUrl.startsWith('/') ? playableUrl : '/$playableUrl';
        playableUrl = 'smb://$auth${server.ipAddress}$path';
      }
    }

    player.open(Media(playableUrl));
    player.setVolume(_volume);

    playingSub = player.stream.playing.listen((playing) {
      setState(() => _isPlaying = playing);
    });

    positionSub = player.stream.position.listen((position) {
      setState(() => _position = position);
    });

    durationSub = player.stream.duration.listen((duration) {
      setState(() => _duration = duration);
    });
  }

  @override
  void dispose() {
    playingSub.cancel();
    positionSub.cancel();
    durationSub.cancel();
    player.dispose();
    _controlsTimer?.cancel();
    ScreenBrightness().resetApplicationScreenBrightness();
    super.dispose();
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying && !_isDraggingVolume && !_isDraggingBrightness) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlay() {
    player.playOrPause();
    _resetControlsTimeout();
  }

  void _resetControlsTimeout() {
    setState(() {
      _showControls = true;
    });
    _startControlsTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  // Handle Drag Gestures (Brightness left, Volume right)
  void _onVerticalDragStart(DragStartDetails details) {
    _resetControlsTimeout();
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < width / 2) {
      _isDraggingBrightness = true;
    } else {
      _isDraggingVolume = true;
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta! / -200.0; // Sensibility

    if (_isDraggingBrightness) {
      setState(() {
        _brightness = (_brightness + delta).clamp(0.0, 1.0);
      });
      ScreenBrightness().setApplicationScreenBrightness(_brightness);
    } else if (_isDraggingVolume) {
      setState(() {
        _volume = (_volume + (delta * 200)).clamp(0.0, 200.0);
      });
      player.setVolume(_volume); // media_kit supporte le volume boost
    }
    _resetControlsTimeout();
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isDraggingBrightness = false;
      _isDraggingVolume = false;
    });
    _resetControlsTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          if (_showControls) {
            setState(() => _showControls = false);
          } else {
            _resetControlsTimeout();
          }
        },
        onDoubleTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            // Rewind 10s
            player.seek(_position - const Duration(seconds: 10));
          } else {
            // Forward 10s
            player.seek(_position + const Duration(seconds: 10));
          }
          _resetControlsTimeout();
        },
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            // Video Player View
            Positioned.fill(
              child: Video(
                controller: controller,
                controls: NoVideoControls, // We use custom controls
                fit: BoxFit.contain,
              ),
            ),

            // Drag Overlays (Volume / Brightness)
            if (_isDraggingVolume)
              Positioned(
                right: 40,
                top: MediaQuery.of(context).size.height / 2 - 50,
                child: _buildVerticalIndicator(
                  Icons.volume_up,
                  _volume / 200.0, // normalized for display
                  '${_volume.toInt()}%',
                ),
              ),
            if (_isDraggingBrightness)
              Positioned(
                left: 40,
                top: MediaQuery.of(context).size.height / 2 - 50,
                child: _buildVerticalIndicator(
                  Icons.lightbulb_outline,
                  _brightness,
                  '${(_brightness * 100).toInt()}%',
                ),
              ),

            // Animated Controls Overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: AppColors.playerOverlayGradient,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Bar
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.video.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.video.category,
                                    style: const TextStyle(
                                      color: AppColors.primaryGlow,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Center Play / Pause
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                              onPressed: () {
                                player.seek(_position - const Duration(seconds: 10));
                                _resetControlsTimeout();
                              },
                            ),
                            const SizedBox(width: 32),
                            GestureDetector(
                              onTap: _togglePlay,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            IconButton(
                              icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                              onPressed: () {
                                player.seek(_position + const Duration(seconds: 10));
                                _resetControlsTimeout();
                              },
                            ),
                          ],
                        ),

                        // Bottom Progress bar
                        Row(
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbColor: Colors.white,
                                  activeTrackColor: AppColors.primary,
                                  inactiveTrackColor: Colors.white24,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                ),
                                child: Slider(
                                  value: _position.inMilliseconds.toDouble(),
                                  min: 0.0,
                                  max: max(_duration.inMilliseconds.toDouble(), 1.0),
                                  onChanged: (val) {
                                    player.seek(Duration(milliseconds: val.toInt()));
                                    _resetControlsTimeout();
                                  },
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalIndicator(IconData icon, double percentage, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            width: 8,
            child: RotatedBox(
              quarterTurns: -1,
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
