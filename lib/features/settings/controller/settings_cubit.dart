import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String username;
  final String avatarUrl;
  final int themeIndex;

  const SettingsState({
    required this.username,
    required this.avatarUrl,
    required this.themeIndex,
  });

  SettingsState copyWith({
    String? username,
    String? avatarUrl,
    int? themeIndex,
  }) {
    return SettingsState(
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themeIndex: themeIndex ?? this.themeIndex,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  static const _keyUser = 'settings_username';
  static const _keyAvatar = 'settings_avatar';
  static const _keyTheme = 'settings_theme';

  static const defaultAvatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop';

  SettingsCubit() : super(const SettingsState(
    username: 'Utilisateur',
    avatarUrl: defaultAvatar,
    themeIndex: 0,
  )) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString(_keyUser) ?? 'Utilisateur';
      final avatarUrl = prefs.getString(_keyAvatar) ?? defaultAvatar;
      final themeIndex = prefs.getInt(_keyTheme) ?? 0;
      emit(SettingsState(
        username: username,
        avatarUrl: avatarUrl,
        themeIndex: themeIndex,
      ));
    } catch (_) {}
  }

  Future<void> updateUsername(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, newName);
    emit(state.copyWith(username: newName));
  }

  Future<void> updateAvatar(String newAvatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatar, newAvatarUrl);
    emit(state.copyWith(avatarUrl: newAvatarUrl));
  }

  Future<void> updateTheme(int newThemeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, newThemeIndex);
    emit(state.copyWith(themeIndex: newThemeIndex));
  }
}
