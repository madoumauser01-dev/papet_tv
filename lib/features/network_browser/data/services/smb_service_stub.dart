import 'dart:async';
import '../models/smb_server.dart';
import '../models/network_file.dart';

class SmbService {
  final List<SmbServer> _availableServers = [];

  // Simulates scanning the network
  Future<List<SmbServer>> scanLocalNetwork() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.from(_availableServers);
  }

  // Simulates connecting to a server (with optional credentials)
  Future<bool> connectToServer(SmbServer server, {String? username, String? password}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (server.isRequiresAuth) {
      if (username == null || username.isEmpty || password == null || password.isEmpty) {
        return false;
      }
      if (username == 'admin' && password == 'admin') {
        return true;
      }
      return false; // Auth failure
    }
    return true; // Guest connect success
  }

  // Simulates browsing folders on the SMB share
  Future<List<NetworkFile>> listFiles(SmbServer server, String path) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final ip = server.ipAddress;
    
    final cleanPath = path == '/' ? '/' : (path.endsWith('/') ? path : '$path/');

    if (cleanPath == '/') {
      return [
        NetworkFile(name: 'Partages_Videos', path: '/Partages_Videos', isDirectory: true, serverIP: ip),
        NetworkFile(name: 'Stockage_NAS', path: '/Stockage_NAS', isDirectory: true, serverIP: ip),
        NetworkFile(name: 'Dossier_Public', path: '/Dossier_Public', isDirectory: true, serverIP: ip),
      ];
    } else if (cleanPath == '/Partages_Videos/') {
      return [
        NetworkFile(name: 'Films', path: '/Partages_Videos/Films', isDirectory: true, serverIP: ip),
        NetworkFile(name: 'Séries', path: '/Partages_Videos/Séries', isDirectory: true, serverIP: ip),
        NetworkFile(name: 'Sports', path: '/Partages_Videos/Sports', isDirectory: true, serverIP: ip),
        NetworkFile(
          name: 'Guide_Configuration_Reseau.pdf',
          path: '/Partages_Videos/Guide_Configuration_Reseau.pdf',
          isDirectory: false,
          size: 1420500,
          serverIP: ip,
        ),
      ];
    } else if (cleanPath == '/Partages_Videos/Films/') {
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
          name: 'Elephants_Dream.mp4',
          path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          isDirectory: false,
          isVideo: true,
          size: 245903000,
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
    } else if (cleanPath == '/Partages_Videos/Séries/') {
      return [
        NetworkFile(name: 'Saison 01', path: '/Partages_Videos/Séries/Saison 01', isDirectory: true, serverIP: ip),
        NetworkFile(name: 'Saison 02', path: '/Partages_Videos/Séries/Saison 02', isDirectory: true, serverIP: ip),
      ];
    } else if (cleanPath == '/Partages_Videos/Séries/Saison 01/') {
      return [
        NetworkFile(
          name: 'Épisode 01 - Le Commencement.mp4',
          path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          isDirectory: false,
          isVideo: true,
          size: 98450120,
          serverIP: ip,
        ),
        NetworkFile(
          name: 'Épisode 02 - L\'Infiltration.mp4',
          path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
          isDirectory: false,
          isVideo: true,
          size: 104509120,
          serverIP: ip,
        ),
      ];
    } else if (cleanPath == '/Partages_Videos/Sports/') {
      return [
        NetworkFile(
          name: 'Formule_1_GP_Monaco_Replay.mp4',
          path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
          isDirectory: false,
          isVideo: true,
          size: 1980004500,
          serverIP: ip,
        ),
      ];
    }

    return [];
  }

  // Disconnect from server
  Future<void> disconnectFromServer() async {}
}
