import 'dart:async';
import 'package:smb_connect/smb_connect.dart';
import '../models/smb_server.dart';
import '../models/network_file.dart';
import 'universal_scanner_service.dart';

class SmbService {
  SmbConnect? _connection;

  // Real scan using UniversalScannerService
  Future<List<SmbServer>> scanLocalNetwork() async {
    final List<SmbServer> servers = [];
    final scanner = UniversalScannerService();
    
    try {
      // Collects all discovered servers (SMB, DLNA, FTP) from the stream
      final List<SmbServer> streamList = await scanner.startUniversalScan().toList();
      servers.addAll(streamList);
    } catch (e) {
      print('Error during universal network scan: $e');
    }
    
    return servers;
  }

  // Connects to a real SMB server
  Future<bool> connectToServer(SmbServer server, {String? username, String? password}) async {
    await disconnectFromServer();
    
    if (server.deviceType == DeviceType.mediaServer) {
      // Simulate successful DLNA connection
      await Future.delayed(const Duration(milliseconds: 600));
      return true;
    }
    
    try {
      _connection = await SmbConnect.connectAuth(
        host: server.ipAddress,
        domain: '',
        username: username ?? '',
        password: password ?? '',
      ).timeout(const Duration(seconds: 8));
      
      return _connection != null;
    } catch (e) {
      print('SMB Connect error: $e');
      _connection = null;
      return false;
    }
  }

  // Browses folders and files on the SMB share
  Future<List<NetworkFile>> listFiles(SmbServer server, String path) async {
    final ip = server.ipAddress;
    
    if (server.deviceType == DeviceType.mediaServer) {
      // Return simulated DLNA media content
      await Future.delayed(const Duration(milliseconds: 400));
      if (path == '/' || path.isEmpty) {
        return [
          NetworkFile(
            name: 'Bibliothèque Vidéos (DLNA)',
            path: '/Videos',
            isDirectory: true,
            serverIP: ip,
          ),
          NetworkFile(
            name: 'Musiques Partagées (DLNA)',
            path: '/Music',
            isDirectory: true,
            serverIP: ip,
          ),
        ];
      } else if (path == '/Videos') {
        return [
          NetworkFile(
            name: 'Big_Buck_Bunny.mp4',
            path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            isDirectory: false,
            isVideo: true,
            size: 125890200,
            serverIP: ip,
          ),
          NetworkFile(
            name: 'Tears_of_Steel_1080p.mp4',
            path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
            isDirectory: false,
            isVideo: true,
            size: 512040900,
            serverIP: ip,
          ),
        ];
      } else if (path == '/Music') {
        return [
          NetworkFile(
            name: 'Instrumental_Sample.mp3',
            path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            isDirectory: false,
            isVideo: true,
            size: 6120500,
            serverIP: ip,
          ),
        ];
      }
      return [];
    }

    if (_connection == null) {
      throw Exception('Non connecté au serveur SMB.');
    }

    final List<NetworkFile> results = [];
    
    try {
      if (path == '/' || path.isEmpty) {
        // List root shares
        final shares = await _connection!.listShares();
        for (final share in shares) {
          if (share.name.endsWith('\$')) continue; // Skip IPC$, print$, etc.
          
          results.add(NetworkFile(
            name: share.name,
            path: share.path,
            isDirectory: true,
            serverIP: ip,
          ));
        }
      } else {
        // List directory files
        final folder = await _connection!.file(path);
        final files = await _connection!.listFiles(folder);
        
        for (final file in files) {
          if (file.name == '.' || file.name == '..') continue;
          
          final isDir = file.isDirectory();
          final String fileName = file.name;
          final isVid = _isVideoFile(fileName);
          
          results.add(NetworkFile(
            name: fileName,
            path: file.path,
            isDirectory: isDir,
            isVideo: isVid,
            size: isDir ? null : file.size,
            serverIP: ip,
          ));
        }
      }
    } catch (e) {
      print('SMB listFiles error: $e');
      throw Exception('Erreur d\'exploration SMB : $e');
    }
    
    return results;
  }

  // Simple video file detector
  bool _isVideoFile(String fileName) {
    final lowerName = fileName.toLowerCase();
    return lowerName.endsWith('.mp4') ||
           lowerName.endsWith('.mkv') ||
           lowerName.endsWith('.avi') ||
           lowerName.endsWith('.mov') ||
           lowerName.endsWith('.mp3') ||
           lowerName.endsWith('.wav') ||
           lowerName.endsWith('.m4a');
  }

  // Disconnect from server
  Future<void> disconnectFromServer() async {
    if (_connection != null) {
      try {
        await _connection!.close();
      } catch (e) {
        print('Error closing SMB connection: $e');
      } finally {
        _connection = null;
      }
    }
  }
}
