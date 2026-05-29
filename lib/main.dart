import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_theme.dart';
import 'routes/app_routes.dart';
import 'package:media_kit/media_kit.dart';
import 'features/network_browser/data/services/smb_service.dart';
import 'features/network_browser/controller/smb_cubit.dart';
import 'features/favorites/controller/favorites_cubit.dart';
import 'features/settings/controller/settings_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const PapetTvApp());
}

class PapetTvApp extends StatelessWidget {
  const PapetTvApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SmbCubit>(
          create: (context) => SmbCubit(SmbService()),
        ),
        BlocProvider<FavoritesCubit>(
          create: (context) => FavoritesCubit(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Papet TV',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(state.themeIndex),
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
