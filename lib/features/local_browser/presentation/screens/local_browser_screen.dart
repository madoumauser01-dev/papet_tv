import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/tv_focusable_card.dart';
import '../../../../models/video_item.dart';

class LocalBrowserScreen extends StatefulWidget {
  const LocalBrowserScreen({Key? key}) : super(key: key);

  @override
  State<LocalBrowserScreen> createState() => _LocalBrowserScreenState();
}

class _LocalBrowserScreenState extends State<LocalBrowserScreen> {
  bool _hasPermission = false;
  bool _isLoading = true;
  String _currentPath = '';
  List<FileSystemEntity> _files = [];
  final List<String> _history = [];

  // Demo fallback files if local directory is empty or inaccessible
  final List<VideoItem> _demoLocalFiles = [
    VideoItem(
      id: 'local_demo_1',
      title: 'Enregistrement_Camera_01.mp4',
      description: 'Vidéo locale enregistrée par la caméra de l\'appareil.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?q=80&w=600&auto=format&fit=crop',
      videoUrl: 'local://camera_01.mp4',
      category: 'Local',
      rating: 4.8,
      duration: '02:15',
      releaseYear: 'Local',
    ),
    VideoItem(
      id: 'local_demo_2',
      title: 'Film_Famille_Vacances.mkv',
      description: 'Vidéo de vacances stockée localement dans le dossier Vidéos.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600&auto=format&fit=crop',
      videoUrl: 'local://vacances.mkv',
      category: 'Local',
      rating: 5.0,
      duration: '45:30',
      releaseYear: 'Local',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInit();
  }

  Future<void> _checkPermissionAndInit() async {
    setState(() {
      _isLoading = true;
    });

    if (Platform.isAndroid) {
      // Request storage permission
      final status = await Permission.storage.request();
      if (status.isGranted) {
        _hasPermission = true;
        await _initDirectory();
      } else {
        // Fallback: try to request photos/videos on Android 13+
        final videoStatus = await Permission.videos.request();
        if (videoStatus.isGranted) {
          _hasPermission = true;
          await _initDirectory();
        } else {
          // Use application documents directory as fallback (no storage permission needed)
          _hasPermission = true;
          final appDocDir = await getApplicationDocumentsDirectory();
          _currentPath = appDocDir.path;
          await _loadDirectory(appDocDir.path);
        }
      }
    } else {
      // Non-Android platforms
      _hasPermission = true;
      final appDocDir = await getApplicationDocumentsDirectory();
      _currentPath = appDocDir.path;
      await _loadDirectory(appDocDir.path);
    }
  }

  Future<void> _initDirectory() async {
    try {
      if (Platform.isAndroid) {
        const rootPath = '/storage/emulated/0';
        final rootDir = Directory(rootPath);
        if (await rootDir.exists()) {
          _currentPath = rootPath;
          await _loadDirectory(rootPath);
          return;
        }
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      _currentPath = appDocDir.path;
      await _loadDirectory(appDocDir.path);
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDirectory(String path) async {
    setState(() {
      _isLoading = true;
      _currentPath = path;
    });

    try {
      final dir = Directory(path);
      final List<FileSystemEntity> entities = [];
      await for (final entity in dir.list()) {
        entities.add(entity);
      }

      // Sort folders first, then files
      entities.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

      setState(() {
        _files = entities;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _files = [];
        _isLoading = false;
      });
    }
  }

  void _navigateToDir(String path) {
    _history.add(_currentPath);
    _loadDirectory(path);
  }

  void _goBack() {
    if (_history.isNotEmpty) {
      final previous = _history.removeLast();
      _loadDirectory(previous);
    }
  }

  bool _isVideoFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.wav');
  }

  void _handleFileTap(FileSystemEntity entity) {
    if (entity is Directory) {
      _navigateToDir(entity.path);
    } else if (entity is File && _isVideoFile(entity.path)) {
      final name = entity.path.split(Platform.pathSeparator).last;
      final video = VideoItem(
        id: entity.path.hashCode.toString(),
        title: name,
        description: 'Fichier média local.\nChemin : ${entity.path}',
        thumbnailUrl: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?q=80&w=600&auto=format&fit=crop',
        videoUrl: entity.path,
        category: 'Local',
        rating: 5.0,
        duration: 'HD',
        releaseYear: 'Local',
      );
      context.push('/player', extra: video);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce type de fichier n\'est pas lisible en vidéo.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _playDemo(VideoItem item) {
    context.push('/player', extra: item);
  }

  @override
  Widget build(BuildContext context) {
    final showBack = _history.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _goBack,
              )
            : null,
        title: const Text(
          'Fichiers Locaux',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGlow),
              )
            : !_hasPermission
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_shared_outlined, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          const Text(
                            'Accès au stockage requis',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nous avons besoin de votre permission pour lister les vidéos locales de votre appareil.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGlow,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(200, 48),
                            ),
                            onPressed: _checkPermissionAndInit,
                            child: const Text('Autoriser l\'accès', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  )
                : _files.isEmpty
                    ? _buildDemoListView() // Use demo fallback files if empty
                    : _buildFileListView(),
      ),
    );
  }

  Widget _buildDemoListView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Icon(Icons.folder_open, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Dossier vide ou inaccessible : \n${_currentPath.split(Platform.pathSeparator).last}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                maxLines: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'DÉMO : Fichiers Médias Simulés',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        ..._demoLocalFiles.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TvFocusableCard(
              onTap: () => _playDemo(item),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.video_library, color: AppColors.secondary, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.play_circle_outline, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFileListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final entity = _files[index];
        final isDir = entity is Directory;
        final name = entity.path.split(Platform.pathSeparator).last;
        final isVid = !isDir && _isVideoFile(entity.path);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TvFocusableCard(
            onTap: () => _handleFileTap(entity),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    isDir
                        ? Icons.folder
                        : (isVid ? Icons.video_library : Icons.insert_drive_file),
                    color: isDir
                        ? AppColors.primaryGlow
                        : (isVid ? AppColors.secondary : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isDir ? Icons.chevron_right : Icons.play_circle_outline,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
