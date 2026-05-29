import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/smb_server.dart';
import '../data/models/network_file.dart';
import '../data/services/smb_service.dart';

// --- STATES ---
abstract class SmbState {
  const SmbState();
}

class SmbInitial extends SmbState {}

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

  SmbCubit(this._smbService) : super(SmbInitial());

  SmbServer? get activeServer => _activeServer;

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
    emit(SmbInitial());
  }
}
