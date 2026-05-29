import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../models/video_item.dart';

class LocalBrowserScreen extends StatefulWidget {
  const LocalBrowserScreen({Key? key}) : super(key: key);

  @override
  _LocalBrowserScreenState createState() => _LocalBrowserScreenState();
}

class _LocalBrowserScreenState extends State<LocalBrowserScreen> {
  Directory _currentDirectory = Directory('/storage/emulated/0');
  List<FileSystemEntity> _files = [];
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoad();
  }

  Future<void> _requestPermissionAndLoad() async {
    final status = await Permission.storage.request();
    // Sur Android 11+, il faut aussi manageExternalStorage
    final manageStatus = await Permission.manageExternalStorage.request();
    
    if (status.isGranted || manageStatus.isGranted) {
      setState(() => _hasPermission = true);
      _loadFiles(_currentDirectory);
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  void _loadFiles(Directory dir) {
    setState(() => _isLoading = true);
    try {
      final files = dir.listSync()
          .where((e) => !e.path.split('/').last.startsWith('.')) // Cacher les fichiers cachés
          .toList();
          
      // Trier: Dossiers d'abord, puis ordre alphabétique
      files.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return a.path.compareTo(b.path);
      });

      setState(() {
        _files = files;
        _currentDirectory = dir;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mkv') || lower.endsWith('.avi') || lower.endsWith('.mov');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stockage Local'),
        leading: _currentDirectory.path != '/storage/emulated/0' && _currentDirectory.path != '/'
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _loadFiles(_currentDirectory.parent),
              )
            : null,
      ),
      body: !_hasPermission
          ? Center(
              child: ElevatedButton(
                onPressed: _requestPermissionAndLoad,
                child: const Text('Autoriser l\'accès au stockage'),
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final entity = _files[index];
                    final name = entity.path.split('/').last;
                    final isDir = entity is Directory;
                    final isVid = _isVideo(name);

                    return ListTile(
                      leading: Icon(
                        isDir ? Icons.folder : (isVid ? Icons.movie : Icons.insert_drive_file),
                        color: isDir ? Colors.amber : (isVid ? Colors.blue : Colors.grey),
                        size: 32,
                      ),
                      title: Text(name),
                      onTap: () {
                        if (isDir) {
                          _loadFiles(entity as Directory);
                        } else if (isVid) {
                          final video = VideoItem(
                            id: entity.path.hashCode.toString(),
                            title: name,
                            videoUrl: entity.path,
                            category: 'Fichier Local',
                            description: 'Vidéo locale depuis le stockage de l\'appareil.',
                            thumbnailUrl: '',
                            rating: 0.0,
                            duration: 'Inconnue',
                            releaseYear: '',
                          );
                          context.push('/player', extra: video);
                        }
                      },
                    );
                  },
                ),
    );
  }
}
