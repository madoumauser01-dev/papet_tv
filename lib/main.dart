import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_theme.dart';
import 'routes/app_routes.dart';
import 'features/network_browser/data/services/smb_service.dart';
import 'features/network_browser/controller/smb_cubit.dart';

void main() {
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
      ],
      child: MaterialApp.router(
        title: 'Papet TV',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
