import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes/app_routes.dart';
import 'features/network_browser/data/services/smb_service.dart';
import 'features/network_browser/controller/smb_cubit.dart';
import 'features/favorites/controller/favorites_cubit.dart';
import 'features/settings/controller/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On charge les paramètres avant le démarrage de l'app
  final settingsCubit = SettingsCubit();
  await settingsCubit.loadSettings();
  
  runApp(PapetTvApp(settingsCubit: settingsCubit));
}

class PapetTvApp extends StatelessWidget {
  final SettingsCubit settingsCubit;
  
  const PapetTvApp({Key? key, required this.settingsCubit}) : super(key: key);

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
        BlocProvider<SettingsCubit>.value(
          value: settingsCubit,
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Papet TV',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
