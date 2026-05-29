import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/video_item.dart';
import '../../widgets/glass_container.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;

  const VideoPlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isPlaying = true;
  double _progress = 0.15; // Simulated initial progress (15%)
  double _volume = 0.7; // Simulated volume (70%)
  bool _showControls = true;
  Timer? _progressTimer;
  Timer? _controlsTimer;

  // Mock duration details
  final int _totalSeconds = 7200; // 2 hours
  late int _currentSeconds;

  @override
  void initState() {
    super.initState();
    _currentSeconds = (_totalSeconds * _progress).toInt();
    _startPlaybackSimulation();
    _startControlsTimer();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controlsTimer?.cancel();
    super.dispose();
  }

  void _startPlaybackSimulation() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        setState(() {
          if (_currentSeconds < _totalSeconds) {
            _currentSeconds++;
            _progress = _currentSeconds / _totalSeconds;
          } else {
            _isPlaying = false;
            _progressTimer?.cancel();
          }
        });
      }
    });
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      _resetControlsTimeout();
    });
  }

  void _resetControlsTimeout() {
    setState(() {
      _showControls = true;
    });
    _startControlsTimer();
  }

  String _formatDuration(int totalSecs) {
    final int hours = totalSecs ~/ 3600;
    final int minutes = (totalSecs % 3600) ~/ 60;
    final int seconds = totalSecs % 60;
    
    final String hStr = hours > 0 ? '$hours:' : '';
    final String mStr = '${minutes.toString().padLeft(2, '0')}:';
    final String sStr = seconds.toString().padLeft(2, '0');
    
    return '$hStr$mStr$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _resetControlsTimeout,
        child: Stack(
          children: [
            // Black Simulated Player Background with movie thumbnail as backdrop
            Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: Image.network(
                  widget.video.thumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Neon glowing visual effects to look premium
            if (_isPlaying)
              Center(
                child: Container(
                  width: size.width * 0.7,
                  height: size.height * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.03),
                        blurRadius: 150,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),

            // Simulated Subtitle overlay
            if (_isPlaying)
              Positioned(
                bottom: _showControls ? 120 : 40,
                left: 20,
                right: 20,
                child: const Center(
                  child: GlassContainer(
                    borderRadius: 8,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "[Musique dramatique en arrière-plan]",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
                        // Top Bar controls
                        Row(
                          children: [
                            // Back Button
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 12),
                            
                            // Video Details
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
                                    widget.video.isLive ? 'DIRECT TV' : 'STREAMING HD 1080P',
                                    style: TextStyle(
                                      color: widget.video.isLive ? AppColors.error : AppColors.primaryGlow,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Subtitles and Settings
                            IconButton(
                              icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
                              onPressed: _resetControlsTimeout,
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined, color: Colors.white),
                              onPressed: _resetControlsTimeout,
                            ),
                          ],
                        ),
                        
                        // Center Play / Pause indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                              onPressed: () {
                                setState(() {
                                  _currentSeconds = (_currentSeconds - 10).clamp(0, _totalSeconds);
                                  _progress = _currentSeconds / _totalSeconds;
                                });
                                _resetControlsTimeout();
                              },
                            ),
                            const SizedBox(width: 32),
                            
                            // Play Button with outer glow
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
                                setState(() {
                                  _currentSeconds = (_currentSeconds + 10).clamp(0, _totalSeconds);
                                  _progress = _currentSeconds / _totalSeconds;
                                });
                                _resetControlsTimeout();
                              },
                            ),
                          ],
                        ),
                        
                        // Bottom Progress and volume controls
                        Column(
                          children: [
                            // Time slider
                            Row(
                              children: [
                                Text(
                                  _formatDuration(_currentSeconds),
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
                                      value: _progress,
                                      onChanged: (val) {
                                        setState(() {
                                          _progress = val;
                                          _currentSeconds = (_totalSeconds * val).toInt();
                                        });
                                        _resetControlsTimeout();
                                      },
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.video.isLive ? 'EN DIRECT' : _formatDuration(_totalSeconds),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            
                            // Bottom Action row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Volume indicator
                                Row(
                                  children: [
                                    Icon(
                                      _volume == 0 ? Icons.volume_off : Icons.volume_up,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 100,
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 2,
                                          activeTrackColor: Colors.white,
                                          inactiveTrackColor: Colors.white24,
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                                        ),
                                        child: Slider(
                                          value: _volume,
                                          onChanged: (val) {
                                            setState(() {
                                              _volume = val;
                                            });
                                            _resetControlsTimeout();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Quality selection badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white38),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '1080P Auto',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
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
}
