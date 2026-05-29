class FavoriteFolder {
  final String id;
  final String name;
  final String path;
  final String serverIP;

  FavoriteFolder({
    required this.id,
    required this.name,
    required this.path,
    required this.serverIP,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'serverIP': serverIP,
    };
  }

  factory FavoriteFolder.fromJson(Map<String, dynamic> json) {
    return FavoriteFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      serverIP: json['serverIP'] as String,
    );
  }
}
