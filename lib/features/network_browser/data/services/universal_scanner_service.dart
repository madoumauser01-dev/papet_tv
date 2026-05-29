import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/smb_server.dart'; // import DeviceType and SmbServer models

class UniversalScannerService {
  final NetworkInfo _networkInfo = NetworkInfo();

  /// Scans the local network for SMB, DLNA/UPnP, and FTP ports
  Stream<SmbServer> startUniversalScan() {
    final controller = StreamController<SmbServer>();
    _runScan(controller);
    return controller.stream;
  }

  Future<void> _runScan(StreamController<SmbServer> controller) async {
    String? localIP;
    
    try {
      localIP = await _networkInfo.getWifiIP();
    } catch (_) {}
    
    // Fallback using NetworkInterface list if getWifiIP fails or returns null
    if (localIP == null) {
      try {
        final interfaces = await NetworkInterface.list(
          includeLoopback: false,
          type: InternetAddressType.IPv4,
        );
        for (final interface in interfaces) {
          for (final addr in interface.addresses) {
            final ip = addr.address;
            if (ip.startsWith('192.168.') || ip.startsWith('10.') || ip.startsWith('172.')) {
              localIP = ip;
              break;
            }
          }
          if (localIP != null) break;
        }
      } catch (_) {}
    }

    if (localIP == null) {
      // Default standard subnet fallback
      localIP = '192.168.1.1';
    }

    // Determine the subnet prefix
    final String subnet = localIP.substring(0, localIP.lastIndexOf('.'));
    
    // Define the ports we want to scan
    final List<_PortConfig> configs = [
      _PortConfig(445, DeviceType.smbShare),      // SMB standard port
      _PortConfig(1900, DeviceType.mediaServer),  // SSDP / DLNA standard port
      _PortConfig(21, DeviceType.ftpServer),      // FTP standard port
    ];
    
    final Set<String> discoveredIps = {};
    
    // Create a list of tasks
    final List<Future<void> Function()> tasks = [];

    for (final config in configs) {
      for (int i = 1; i <= 254; i++) {
        final ip = '$subnet.$i';
        
        tasks.add(() async {
          try {
            final socket = await Socket.connect(ip, config.port, timeout: const Duration(milliseconds: 2000));
            socket.destroy();
            
            // Prevent duplicates if device responds on multiple ports (we keep the first discovered type)
            if (discoveredIps.contains(ip)) return;
            discoveredIps.add(ip);
            
            String friendlyName = '';
            if (config.type == DeviceType.smbShare) {
              friendlyName = 'Partage SMB ($ip)';
            } else if (config.type == DeviceType.mediaServer) {
              friendlyName = 'Serveur Média ($ip)';
            } else if (config.type == DeviceType.ftpServer) {
              friendlyName = 'Serveur FTP ($ip)';
            } else {
              friendlyName = 'Appareil ($ip)';
            }
            
            // Perform reverse lookup for hostname
            try {
              final lookup = await InternetAddress(ip).reverse().timeout(const Duration(milliseconds: 500));
              if (lookup.host != ip) {
                friendlyName = lookup.host;
              }
            } catch (_) {}

            if (!controller.isClosed) {
              controller.add(SmbServer(
                id: ip.replaceAll('.', '_'),
                name: friendlyName,
                ipAddress: ip,
                isRequiresAuth: config.type == DeviceType.smbShare || config.type == DeviceType.ftpServer,
                deviceType: config.type,
                port: config.port,
              ));
            }
          } catch (_) {
            // Port is closed / host unreachable
          }
        });
      }
    }
    
    // Process tasks in chunks to avoid "Too many open files" exception on Android
    const chunkSize = 30;
    for (int i = 0; i < tasks.length; i += chunkSize) {
      final end = (i + chunkSize < tasks.length) ? i + chunkSize : tasks.length;
      final chunk = tasks.sublist(i, end).map((task) => task()).toList();
      await Future.wait(chunk);
    }
    
    if (!controller.isClosed) {
      await controller.close();
    }
  }
}

class _PortConfig {
  final int port;
  final DeviceType type;
  _PortConfig(this.port, this.type);
}
