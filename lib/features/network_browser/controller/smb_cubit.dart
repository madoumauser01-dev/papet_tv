import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/smb_server.dart';
import '../data/models/network_file.dart';
import '../data/services/smb_service.dart';

// --- STATES ---
abstract class SmbState {
  const SmbState();
}

class SmbInitial extends SmbState {}

class SmbScanning extends SmbState {}

class SmbServerListLoaded extends SmbState {
  final List<SmbServer> servers;
  const SmbServerListLoaded(this.servers);
}

class SmbSavedServersLoaded extends SmbState {
  final List<SmbServer> servers;
  const SmbSavedServersLoaded(this.servers);
}

class SmbConnecting extends SmbState {
  final SmbServer server;
  const SmbConnecting(this.server);
}

class SmbConnected extends SmbState {
  final SmbServer server;
  const SmbConnected(this.server);
}

class SmbBrowsing extends SmbState {
  final SmbServer server;
  final String currentPath;
  final List<NetworkFile> files;
  final List<String> breadcrumbs;

  const SmbBrowsing({
    required this.server,
    required this.currentPath,
    required this.files,
    required this.breadcrumbs,
  });
}

class SmbError extends SmbState {
  final String message;
  const SmbError(this.message);
}

// --- CUBIT ---
class SmbCubit extends Cubit<SmbState> {
  final SmbService _smbService;
  
  SmbServer? _activeServer;
  final List<String> _breadcrumbs = [];
  String _currentPath = '/';

  // Saved servers list starts empty
  final List<SmbServer> _savedServers = [];

  SmbCubit(this._smbService) : super(SmbInitial()) {
    loadSavedServers();
  }

  SmbServer? get activeServer => _activeServer;
  List<SmbServer> get savedServers => _savedServers;

  // Emits the list of saved servers
  void loadSavedServers() {
    emit(SmbSavedServersLoaded(List.from(_savedServers)));
  }

  // Adds a server to the saved servers list
  void addSavedServer(SmbServer server) {
    _savedServers.removeWhere((s) => s.ipAddress == server.ipAddress);
    _savedServers.add(server);
    loadSavedServers();
  }

  // Removes a server from the saved servers list
  void removeSavedServer(String id) {
    _savedServers.removeWhere((s) => s.id == id);
    loadSavedServers();
  }

  // Triggers scanning the network for servers
  Future<void> scanNetwork() async {
    emit(SmbScanning());
    try {
      final servers = await _smbService.scanLocalNetwork();
      emit(SmbServerListLoaded(servers));
    } catch (e) {
      emit(SmbError('Erreur lors du scan réseau : ${e.toString()}'));
    }
  }

  // Connects to a server (guest or auth mode)
  Future<void> connect(SmbServer server, {String? username, String? password}) async {
    emit(SmbConnecting(server));
    try {
      final success = await _smbService.connectToServer(server, username: username, password: password);
      if (success) {
        _activeServer = server.copyWith(
          isConnected: true,
          username: username,
          password: password,
        );
        addSavedServer(_activeServer!);
        emit(SmbConnected(_activeServer!));
        // Immediately list root directory
        await browsePath('/');
      } else {
        emit(SmbError('Identifiants SMB invalides pour ${server.name}.'));
      }
    } catch (e) {
      emit(SmbError('Erreur de connexion : ${e.toString()}'));
    }
  }

  // Browses a specific path inside the connected share
  Future<void> browsePath(String path) async {
    if (_activeServer == null) {
      emit(const SmbError('Aucun serveur connecté.'));
      return;
    }

    try {
      // Re-emit connecting/loading state for smooth transition
      _currentPath = path;
      
      // Update breadcrumbs history
      if (path == '/') {
        _breadcrumbs.clear();
      } else {
        final segments = path.split('/').where((s) => s.isNotEmpty).toList();
        _breadcrumbs.clear();
        _breadcrumbs.addAll(segments);
      }

      final files = await _smbService.listFiles(_activeServer!, path);
      emit(SmbBrowsing(
        server: _activeServer!,
        currentPath: _currentPath,
        files: files,
        breadcrumbs: List.from(_breadcrumbs),
      ));
    } catch (e) {
      emit(SmbError('Erreur d\'exploration de dossier : ${e.toString()}'));
    }
  }

  // Go back one folder level
  Future<void> browseBack() async {
    if (_breadcrumbs.isEmpty) {
      // Return to server list
      _activeServer = null;
      await scanNetwork();
      return;
    }

    _breadcrumbs.removeLast();
    final newPath = _breadcrumbs.isEmpty ? '/' : '/${_breadcrumbs.join('/')}';
    await browsePath(newPath);
  }

  // Disconnect from active server
  void disconnectServer() {
    _activeServer = null;
    _breadcrumbs.clear();
    _currentPath = '/';
    scanNetwork();
  }
}
