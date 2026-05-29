import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papet_tv/main.dart';
import 'package:papet_tv/features/settings/controller/settings_cubit.dart';

void main() {
  testWidgets('Smoke test for Papet TV launches showing Login Screen', (WidgetTester tester) async {
    final cubit = SettingsCubit();
    // Build our app and trigger a frame.
    await tester.pumpWidget(PapetTvApp(settingsCubit: cubit));

    // Verify that the login text is found.
    expect(find.text('Connexion'), findsAtLeastNWidgets(1));
    expect(find.text('Adresse Email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
  });
}
