import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool isDarkMode;
  final String username;
  final String? profilePhotoPath;

  const SettingsState({
    required this.isDarkMode,
    required this.username,
    this.profilePhotoPath,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? username,
    String? profilePhotoPath,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      username: username ?? this.username,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState(isDarkMode: true, username: 'Utilisateur'));

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? true;
    final username = prefs.getString('username') ?? 'Utilisateur';
    final profilePhotoPath = prefs.getString('profilePhotoPath');

    emit(SettingsState(
      isDarkMode: isDarkMode,
      username: username,
      profilePhotoPath: profilePhotoPath,
    ));
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }

  Future<void> updateUsername(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newName);
    emit(state.copyWith(username: newName));
  }

  Future<void> updateProfilePhoto(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePhotoPath', path);
    emit(state.copyWith(profilePhotoPath: path));
  }
}
