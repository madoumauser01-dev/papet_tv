import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey<String>('ShellScreen'));

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Très important pour que le contenu passe sous la barre floutée
      body: navigationShell,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.black.withOpacity(0.5) 
              : Colors.white.withOpacity(0.6),
            child: SafeArea(
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => _onTap(context, index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF007AFF), // Bleu iOS
                unselectedItemColor: Colors.grey,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                unselectedLabelStyle: const TextStyle(fontSize: 10),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.cloud_outlined),
                    activeIcon: Icon(Icons.cloud),
                    label: 'Réseau',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_outline),
                    activeIcon: Icon(Icons.favorite),
                    label: 'Favoris',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.folder_outlined),
                    activeIcon: Icon(Icons.folder),
                    label: 'Fichiers',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Réglages',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
