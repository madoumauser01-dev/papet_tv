import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../controller/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      context.read<SettingsCubit>().updateProfilePhoto(pickedFile.path);
    }
  }

  void _editUsername(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nom d'utilisateur"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Entrez votre nom"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsCubit>().updateUsername(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        elevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: state.profilePhotoPath != null
                            ? FileImage(File(state.profilePhotoPath!))
                            : null,
                        child: state.profilePhotoPath == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF007AFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Nom d\'utilisateur'),
                subtitle: Text(state.username),
                trailing: const Icon(Icons.edit),
                onTap: () => _editUsername(context, state.username),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Mode Sombre'),
                value: state.isDarkMode,
                onChanged: (val) {
                  context.read<SettingsCubit>().toggleTheme(val);
                },
                secondary: Icon(state.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              ),
            ],
          );
        },
      ),
    );
  }
}
