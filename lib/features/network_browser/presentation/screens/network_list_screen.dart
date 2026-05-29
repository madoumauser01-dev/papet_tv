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
  final SmbServer _targetServer = SmbServer(
    id: 'auto_target',
    name: 'Serveur NAS',
    ipAddress: '192.168.1.80',
    isRequiresAuth: true,
    username: 'juju',
    password: 'p@ss_25',
  );

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SmbCubit>();
    if (cubit.state is SmbBrowsing || cubit.state is SmbConnected) {
      Future.microtask(() {
        if (mounted) {
          context.push('/browser');
        }
      });
    } else {
      _connect();
    }
  }

  void _connect() {
    final cubit = context.read<SmbCubit>();
    Future.microtask(() {
      cubit.connect(
        _targetServer,
        username: _targetServer.username,
        password: _targetServer.password,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<SmbCubit, SmbState>(
        listener: (context, state) {
          if (state is SmbBrowsing) {
            context.push('/browser');
          }
        },
        builder: (context, state) {
          final isConnected = state is SmbBrowsing || state is SmbConnected;
          final isError = state is SmbError;
          final errorMessage = isError ? state.message : '';

          return SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium Brand Logo
                    const Text(
                      'PAPET TV',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: AppColors.primaryGlow,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gestionnaire de Fichiers SMB',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Connection Status Box with Glassmorphism
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isError) ...[
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Échec de la connexion',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(180, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: _connect,
                              child: const Text(
                                'Réessayer',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ] else if (isConnected) ...[
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Connecté au serveur',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '192.168.1.80',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGlow,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(180, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () => context.push('/browser'),
                              child: const Text(
                                'Ouvrir l\'explorateur',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ] else ...[
                            const CircularProgressIndicator(
                              color: AppColors.primaryGlow,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Connexion en cours...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Connexion à 192.168.1.80',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
