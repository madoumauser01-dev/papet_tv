import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_folder.dart';

class FavoritesFolderService {
  static const _key = 'favorite_folders';

  Future<List<FavoriteFolder>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return FavoriteFolder.fromJson(map);
    }).toList();
  }

  Future<void> saveFavorites(List<FavoriteFolder> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = favorites.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }
}
