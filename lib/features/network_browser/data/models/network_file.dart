class NetworkFile {
  final String name;
  final String path;
  final int? size;
  final bool isDirectory;
  final bool isVideo;
  final String serverIP;

  NetworkFile({
    required this.name,
    required this.path,
    this.size,
    required this.isDirectory,
    this.isVideo = false,
    required this.serverIP,
  });

  String get formattedSize {
    if (size == null || size == 0) return '';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    if (size! < 1024 * 1024 * 1024) return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
