import 'package:flutter_test/flutter_test.dart';
import 'package:papet_tv/main.dart';

void main() {
  testWidgets('Smoke test for Papet TV launches showing Login Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PapetTvApp());

    // Verify that the login text is found.
    expect(find.text('Connexion'), findsAtLeastNWidgets(1));
    expect(find.text('Adresse Email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
  });
}
