import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/smb_server.dart';

class FavoritesService {
  static const _key = 'saved_servers';

  Future<List<SmbServer>> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return SmbServer(
        id: map['id'],
        name: map['name'],
        ipAddress: map['ipAddress'],
        isRequiresAuth: map['isRequiresAuth'] ?? false,
        username: map['username'],
        password: map['password'],
        deviceType: DeviceType.values.firstWhere(
          (d) => d.name == map['deviceType'],
          orElse: () => DeviceType.smbShare,
        ),
        port: map['port'] ?? 445,
      );
    }).toList();
  }

  Future<void> saveServers(List<SmbServer> servers) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = servers.map((s) => jsonEncode({
      'id': s.id,
      'name': s.name,
      'ipAddress': s.ipAddress,
      'isRequiresAuth': s.isRequiresAuth,
      'username': s.username,
      'password': s.password,
      'deviceType': s.deviceType.name,
      'port': s.port,
    })).toList();
    await prefs.setStringList(_key, raw);
  }
}
