import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/tv_focusable_card.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../models/video_item.dart';
import '../../controller/smb_cubit.dart';
import '../../data/models/network_file.dart';

class SmbBrowserScreen extends StatelessWidget {
  const SmbBrowserScreen({Key? key}) : super(key: key);

  void _handleFileTap(BuildContext context, NetworkFile file) {
    if (file.isDirectory) {
      context.read<SmbCubit>().browsePath(file.path);
    } else if (file.isVideo) {
      // Create a mock VideoItem matching the network file to launch in player
      final video = VideoItem(
        id: file.name.hashCode.toString(),
        title: file.name,
        description: 'Fichier vidéo lu à partir du serveur SMB (${file.serverIP}).\nChemin : ${file.path}',
        thumbnailUrl: 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=600&auto=format&fit=crop',
        videoUrl: file.path, // SMB simulated HTTP source stream
        category: 'Réseau SMB',
        rating: 5.0,
        duration: file.formattedSize.isNotEmpty ? file.formattedSize : 'HD 1080P',
        releaseYear: 'SMB',
      );
      
      // Navigate to video player
      context.push('/player', extra: video);
    } else {
      // File type not supported
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le fichier "${file.name}" n\'est pas un média lisible.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: BlocBuilder<SmbCubit, SmbState>(
            builder: (context, state) {
              if (state is SmbScanning || state is SmbConnecting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is SmbBrowsing) {
                final server = state.server;
                final files = state.files;
                final currentPath = state.currentPath;
                final breadcrumbs = state.breadcrumbs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar with Server Details and Disconnect
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.read<SmbCubit>().browseBack(),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              server.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Connecté • IP : ${server.ipAddress}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        
                        // Disconnect Button
                        TvFocusableCard(
                          onTap: () {
                            context.read<SmbCubit>().disconnectServer();
                            context.pop(); // Return to local network scanner
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: AppColors.error.withOpacity(0.2),
                            child: const Row(
                              children: [
                                Icon(Icons.power_settings_new, color: Colors.red, size: 18),
                                SizedBox(width: 6),
                                Text('Déconnecter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Breadcrumb Path display
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Icon(Icons.folder_shared_outlined, color: AppColors.primaryGlow, size: 18),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => context.read<SmbCubit>().browsePath('/'),
                            child: const Text(
                              'Racine',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...breadcrumbs.map((crumb) {
                            final index = breadcrumbs.indexOf(crumb);
                            final pathBuilder = '/${breadcrumbs.sublist(0, index + 1).join('/')}';
                            return Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('/', style: TextStyle(color: AppColors.textMuted)),
                                ),
                                GestureDetector(
                                  onTap: () => context.read<SmbCubit>().browsePath(pathBuilder),
                                  child: Text(
                                    crumb,
                                    style: const TextStyle(color: AppColors.primaryGlow, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Browser list
                    Expanded(
                      child: files.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open, color: AppColors.textMuted, size: 48),
                                  SizedBox(height: 12),
                                  Text(
                                    'Dossier vide',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: files.length + (currentPath != '/' ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Add dynamic ".." parent folder card
                                if (currentPath != '/' && index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: TvFocusableCard(
                                      onTap: () => context.read<SmbCubit>().browseBack(),
                                      child: const GlassContainer(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                        child: Row(
                                          children: [
                                            Icon(Icons.drive_file_move_rtl, color: Colors.white70),
                                            SizedBox(width: 16),
                                            Text(
                                              '.. (Dossier parent)',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final fileIndex = currentPath != '/' ? index - 1 : index;
                                final file = files[fileIndex];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TvFocusableCard(
                                    onTap: () => _handleFileTap(context, file),
                                    child: GlassContainer(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      child: Row(
                                        children: [
                                          Icon(
                                            file.isDirectory
                                                ? Icons.folder
                                                : (file.isVideo ? Icons.video_library : Icons.insert_drive_file),
                                            color: file.isDirectory
                                                ? AppColors.primaryGlow
                                                : (file.isVideo ? AppColors.secondary : AppColors.textSecondary),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  file.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (!file.isDirectory && file.formattedSize.isNotEmpty)
                                                  Text(
                                                    file.formattedSize,
                                                    style: const TextStyle(
                                                      color: AppColors.textSecondary,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            file.isDirectory ? Icons.chevron_right : Icons.play_circle_outline,
                                            color: AppColors.textMuted,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }

              return const Center(
                child: Text(
                  'Déconnecté ou indisponible.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
