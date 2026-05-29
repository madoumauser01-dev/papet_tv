import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/tv_focusable_card.dart';
import '../../controller/settings_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _usernameController = TextEditingController();

  final List<String> _avatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
  ];

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Bleu Indigo',
      'primary': const Color(0xFF6366F1),
      'secondary': const Color(0xFFEC4899),
    },
    {
      'name': 'Violet Vibrant',
      'primary': const Color(0xFF8B5CF6),
      'secondary': const Color(0xFF10B981),
    },
    {
      'name': 'Gris Carbone',
      'primary': const Color(0xFF94A3B8),
      'secondary': const Color(0xFF3B82F6),
    },
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            // Set text initial value if empty
            if (_usernameController.text.isEmpty && _usernameController.text != state.username) {
              _usernameController.text = state.username;
            }

            final themeColor = Theme.of(context).colorScheme.primary;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Identity Header (glowing card)
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 16,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundImage: NetworkImage(state.avatarUrl),
                              backgroundColor: AppColors.surfaceLight,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Thème actif : ${_themes[state.themeIndex]['name']}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section: Profile Customization
                      const Text(
                        'PERSONNALISER LE PROFIL',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Username field
                      TextField(
                        controller: _usernameController,
                        onChanged: (val) {
                          if (val.trim().isNotEmpty) {
                            context.read<SettingsCubit>().updateUsername(val.trim());
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Nom d\'utilisateur',
                          prefixIcon: Icon(Icons.person, color: themeColor),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Profile picture selector
                      const Text(
                        'Choisir une photo de profil',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 72,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _avatars.length,
                          itemBuilder: (context, index) {
                            final url = _avatars[index];
                            final isSelected = state.avatarUrl == url;
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: TvFocusableCard(
                                onTap: () => context.read<SettingsCubit>().updateAvatar(url),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? themeColor : Colors.transparent,
                                      width: 3,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(url),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Section: Theme Customization
                      const Text(
                        'PERSONNALISER LE THÈME',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Theme Choices
                      Column(
                        children: _themes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final themeInfo = entry.value;
                          final isSelected = state.themeIndex == index;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TvFocusableCard(
                              onTap: () => context.read<SettingsCubit>().updateTheme(index),
                              child: GlassContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: Row(
                                  children: [
                                    // Custom color dots
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: themeInfo['primary'],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: themeInfo['secondary'],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        themeInfo['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: themeColor,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
