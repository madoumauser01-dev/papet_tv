import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/tv_focusable_card.dart';
import '../../../network_browser/controller/smb_cubit.dart';
import '../../../network_browser/data/models/smb_server.dart';
import '../../controller/favorites_cubit.dart';
import '../../data/models/favorite_folder.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  void _openFavorite(BuildContext context, FavoriteFolder fav) {
    final smbCubit = context.read<SmbCubit>();
    final targetServer = SmbServer(
      id: 'auto_target',
      name: 'Serveur NAS',
      ipAddress: fav.serverIP,
      isRequiresAuth: true,
      username: 'juju',
      password: 'p@ss_25',
    );

    if (smbCubit.activeServer != null &&
        smbCubit.activeServer!.ipAddress == fav.serverIP &&
        smbCubit.state is SmbBrowsing) {
      smbCubit.browsePath(fav.path);
      context.push('/browser');
    } else {
      smbCubit.connect(
        targetServer,
        username: targetServer.username,
        password: targetServer.password,
        initialPath: fav.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SmbCubit, SmbState>(
      listener: (context, state) {
        if (state is SmbBrowsing) {
          context.push('/browser');
        } else if (state is SmbError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 1,
          title: const Text(
            'Dossiers Favoris',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final folders = state.folders;

              if (folders.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_border, size: 64, color: AppColors.textMuted),
                      SizedBox(height: 16),
                      Text(
                        'Aucun dossier favori enregistré.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ajoutez des favoris depuis le navigateur SMB.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final fav = folders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TvFocusableCard(
                      onTap: () => _openFavorite(context, fav),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_special,
                              color: AppColors.primaryGlow,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fav.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${fav.serverIP} • ${fav.path}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.star, color: AppColors.primaryGlow),
                              onPressed: () {
                                context.read<FavoritesCubit>().toggleFavorite(
                                      name: fav.name,
                                      path: fav.path,
                                      serverIP: fav.serverIP,
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
