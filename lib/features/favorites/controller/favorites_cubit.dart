import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/favorite_folder.dart';
import '../data/services/favorites_folder_service.dart';

class FavoritesState {
  final List<FavoriteFolder> folders;
  const FavoritesState(this.folders);
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesFolderService _service = FavoritesFolderService();

  FavoritesCubit() : super(const FavoritesState([])) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final list = await _service.loadFavorites();
      emit(FavoritesState(list));
    } catch (_) {}
  }

  Future<void> toggleFavorite({
    required String name,
    required String path,
    required String serverIP,
  }) async {
    final id = '${serverIP}_${path}'.hashCode.toString();
    final current = List<FavoriteFolder>.from(state.folders);
    final existsIndex = current.indexWhere((f) => f.id == id);

    if (existsIndex >= 0) {
      current.removeAt(existsIndex);
    } else {
      current.add(FavoriteFolder(
        id: id,
        name: name,
        path: path,
        serverIP: serverIP,
      ));
    }

    await _service.saveFavorites(current);
    emit(FavoritesState(current));
  }

  bool isFavorite(String path, String serverIP) {
    final id = '${serverIP}_${path}'.hashCode.toString();
    return state.folders.any((f) => f.id == id);
  }
}
