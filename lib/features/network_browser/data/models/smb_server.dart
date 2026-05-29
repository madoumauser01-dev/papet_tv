enum DeviceType { smbShare, mediaServer, ftpServer, unknown }

class SmbServer {
  final String id;
  final String name;
  final String ipAddress;
  final bool isRequiresAuth;
  final String? username;
  final String? password;
  final bool isConnected;
  final DeviceType deviceType;
  final int port;

  SmbServer({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.isRequiresAuth = false,
    this.username,
    this.password,
    this.isConnected = false,
    this.deviceType = DeviceType.smbShare,
    this.port = 445,
  });

  SmbServer copyWith({
    String? id,
    String? name,
    String? ipAddress,
    bool? isRequiresAuth,
    String? username,
    String? password,
    bool? isConnected,
    DeviceType? deviceType,
    int? port,
  }) {
    return SmbServer(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      isRequiresAuth: isRequiresAuth ?? this.isRequiresAuth,
      username: username ?? this.username,
      password: password ?? this.password,
      isConnected: isConnected ?? this.isConnected,
      deviceType: deviceType ?? this.deviceType,
      port: port ?? this.port,
    );
  }
}
