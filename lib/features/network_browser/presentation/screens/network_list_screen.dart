import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../controller/smb_cubit.dart';
import '../../data/models/smb_server.dart';

class NetworkListScreen extends StatefulWidget {
  const NetworkListScreen({Key? key}) : super(key: key);

  @override
  State<NetworkListScreen> createState() => _NetworkListScreenState();
}

class _NetworkListScreenState extends State<NetworkListScreen> {
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    // Load saved servers on startup
    context.read<SmbCubit>().loadSavedServers();
  }

  // Helper to build appropriate icons for discovered network devices
  Widget _buildServerIcon(SmbServer server, {double folderSize = 40, double innerSize = 16, double topPos = 11}) {
    switch (server.deviceType) {
      case DeviceType.smbShare:
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.folder, size: folderSize, color: Colors.orange.shade300),
            Positioned(
              top: topPos,
              child: Icon(Icons.computer, size: innerSize, color: Colors.black54),
            )
          ],
        );
      case DeviceType.mediaServer:
        return Icon(Icons.play_circle_fill, size: folderSize, color: Colors.blue);
      case DeviceType.ftpServer:
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.folder, size: folderSize, color: Colors.green.shade300),
            Positioned(
              top: topPos,
              child: Icon(Icons.swap_horizontal_circle, size: innerSize, color: Colors.black54),
            )
          ],
        );
      default:
        return Icon(Icons.dns, size: folderSize, color: AppColors.primaryGlow);
    }
  }

  // Opens credentials dialog
  void _showCredentialsDialog(BuildContext context, SmbServer server) {
    final userController = TextEditingController(text: server.username ?? 'admin');
    final passController = TextEditingController(text: server.password ?? 'admin');
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Connexion à ${server.name}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adresse IP : ${server.ipAddress}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<SmbCubit>().connect(
                  server,
                  username: userController.text.trim(),
                  password: passController.text.trim(),
                );
              },
              child: const Text('Se connecter', style: TextStyle(color: AppColors.primaryGlow, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Opens local network scanning dialog (matches user screenshot)
  void _showLocalNetworkDialog(BuildContext context) {
    context.read<SmbCubit>().scanNetwork();
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocBuilder<SmbCubit, SmbState>(
          bloc: context.read<SmbCubit>(),
          builder: (context, state) {
            bool isLoading = state is SmbScanning || state is SmbConnecting;
            List<SmbServer> discoveredServers = [];
            
            if (state is SmbServerListLoaded) {
              discoveredServers = state.servers;
            }

            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Réseau local',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
              ),
              content: SizedBox(
                width: 340,
                height: 280,
                child: isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text('Recherche de partages réseau...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      )
                    : discoveredServers.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun appareil trouvé.\nAssurez-vous d\'être connecté sur le même Wi-Fi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          )
                        : ListView.builder(
                            itemCount: discoveredServers.length,
                            itemBuilder: (context, index) {
                              final server = discoveredServers[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                leading: _buildServerIcon(server),
                                title: Text(
                                  server.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                onTap: () {
                                  Navigator.pop(dialogContext); // Close scanning dialog
                                  if (server.isRequiresAuth) {
                                    _showCredentialsDialog(context, server);
                                  } else {
                                    context.read<SmbCubit>().connect(server);
                                  }
                                },
                              );
                            },
                          ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.read<SmbCubit>().loadSavedServers();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showManualEntryDialog(context);
                  },
                  child: const Text('Entrée manuelle', style: TextStyle(color: AppColors.primaryGlow, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Opens manual server details entry dialog
  void _showManualEntryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ipController = TextEditingController(text: '192.168.1.');
    final userController = TextEditingController(text: 'juju');
    final passController = TextEditingController(text: 'p@ss_25');
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Entrée manuelle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom du serveur (ex: NAS)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ipController,
                  decoration: const InputDecoration(labelText: 'Adresse IP ou Hôte'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: userController,
                  decoration: const InputDecoration(labelText: 'Nom d\'utilisateur (Optionnel)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe (Optionnel)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<SmbCubit>().loadSavedServers();
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final ip = ipController.text.trim();
                if (ip.isEmpty) return;
                
                final name = nameController.text.trim().isEmpty ? 'Serveur SMB ($ip)' : nameController.text.trim();
                final server = SmbServer(
                  id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  ipAddress: ip,
                  isRequiresAuth: userController.text.isNotEmpty || passController.text.isNotEmpty,
                  username: userController.text.isNotEmpty ? userController.text : null,
                  password: passController.text.isNotEmpty ? passController.text : null,
                );
                
                // Add the server immediately - closes dialog and updates list instantly
                context.read<SmbCubit>().addSavedServer(server);
                Navigator.pop(dialogContext);
              },
              child: const Text('Ajouter', style: TextStyle(color: AppColors.primaryGlow, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Distant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditMode ? Icons.check : Icons.edit,
              color: _isEditMode ? AppColors.success : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.surfaceLight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PAPET TV',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gestionnaire de Fichiers SMB',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder_shared_outlined, color: Colors.white),
              title: const Text('Emplacements Distants', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: BlocConsumer<SmbCubit, SmbState>(
        listener: (context, state) {
          if (state is SmbError) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is SmbConnecting) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔄 Connexion en cours...'),
                duration: Duration(seconds: 10),
              ),
            );
          } else if (state is SmbBrowsing) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.push('/browser');
          }
        },
        builder: (context, state) {
          // Read servers directly from the state for instant reactivity
          final List<SmbServer> savedServers;
          if (state is SmbSavedServersLoaded) {
            savedServers = state.servers;
          } else if (state is SmbConnecting) {
            savedServers = context.read<SmbCubit>().savedServers;
          } else {
            savedServers = context.read<SmbCubit>().savedServers;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // List of saved servers
                      if (savedServers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Aucun emplacement distant enregistré.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: savedServers.length,
                          itemBuilder: (context, index) {
                            final server = savedServers[index];
                            final isConnecting = state is SmbConnecting && state.server.ipAddress == server.ipAddress;
                            return Card(
                              color: AppColors.surface,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: _buildServerIcon(server, folderSize: 48, innerSize: 20, topPos: 13),
                                title: Text(
                                  server.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Text(
                                  isConnecting ? 'Connexion en cours...' : (server.username ?? server.ipAddress),
                                  style: TextStyle(
                                    color: isConnecting ? AppColors.primaryGlow : AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: _isEditMode
                                    ? IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                        onPressed: () {
                                          context.read<SmbCubit>().removeSavedServer(server.id);
                                        },
                                      )
                                    : isConnecting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGlow),
                                          )
                                        : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                onTap: _isEditMode || isConnecting
                                    ? null
                                    : () {
                                        context.read<SmbCubit>().connect(
                                          server,
                                          username: server.username,
                                          password: server.password,
                                        );
                                      },
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                      
                      // Add Remote Location Button (matches user screenshot)
                      InkWell(
                        onTap: () => _showLocalNetworkDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, color: AppColors.primaryGlow, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Ajouter un emplacement distant',
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
