import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:work_plan_front/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('register -> login flow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // jeśli app startuje na LoginScreen -- otwórz RegisterScreen (jeśli jest przycisk)
    final openRegister = find.byKey(const Key('open_register'));
    final nameField = find.byKey(const Key('register_name'));
    bool registerVisible = false;
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      if (nameField.evaluate().isNotEmpty) {
        registerVisible = true;
        break;
      }
      if (openRegister.evaluate().isNotEmpty) {
        await tester.tap(openRegister);
        await tester.pumpAndSettle();
      }
    }
    expect(
      nameField,
      findsOneWidget,
      reason:
          'Nie udało się otworzyć ekranu rejestracji (brak Key register_name).',
    );

    // wypełnij formularz rejestracji (upewnij się, że Keys w UI są takie same)
    // nameField zdefiniowany wyżej
    final emailField = find.byKey(const Key('register_email'));
    final passwordField = find.byKey(const Key('register_password'));
    final confirmField = find.byKey(const Key('register_confirm_password'));
    final submitBtn = find.byKey(const Key('register_create_account'));

    // fokusu i wpisywanie (ważne na web)
    await tester.ensureVisible(nameField);
    await tester.tap(nameField);
    await tester.pumpAndSettle();
    await tester.enterText(nameField, 'TestUser');

    await tester.tap(emailField);
    await tester.pumpAndSettle();
    await tester.enterText(emailField, 'test@example.com');

    await tester.tap(passwordField);
    await tester.pumpAndSettle();
    await tester.enterText(passwordField, 'Password1');

    await tester.tap(confirmField);
    await tester.pumpAndSettle();
    await tester.enterText(confirmField, 'Password1');

    await tester.ensureVisible(submitBtn);
    await tester.pumpAndSettle();
    await tester.tap(submitBtn);

    // polling: czekaj na pole login lub na tekst błędu w SnackBar
    final loginEmail = find.byKey(const Key('login_email'));
    final errorTextFinder = find.byWidgetPredicate(
      (w) =>
          w is Text && w.data != null && w.data!.contains('Błąd rejestracji'),
      description: 'SnackBar z błędem rejestracji',
    );

    bool success = false;
    String? errorMessage;
    for (int i = 0; i < 16; i++) {
      // ~8s total
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      if (loginEmail.evaluate().isNotEmpty) {
        success = true;
        break;
      }
      if (errorTextFinder.evaluate().isNotEmpty) {
        final textWidget = errorTextFinder.evaluate().first.widget as Text;
        errorMessage = textWidget.data;
        break;
      }
    }

    if (!success) {
      if (errorMessage != null) {
        fail('Rejestracja zakończona błędem: $errorMessage');
      } else {
        fail(
          'Timeout: nie pojawił się ani ekran logowania, ani komunikat o błędzie. Sprawdź backend/CORS.',
        );
      }
    }

    // kontynuuj test logowania (jeśli rejestracja powiodła się)
    await tester.tap(loginEmail);
    await tester.pumpAndSettle();
    await tester.enterText(loginEmail, 'test@example.com');

    final loginPassword = find.byKey(const Key('login_password'));
    await tester.tap(loginPassword);
    await tester.pumpAndSettle();
    await tester.enterText(loginPassword, 'Password1');

    final loginBtn = find.byKey(const Key('login_login_account'));
    await tester.ensureVisible(loginBtn);
    await tester.pumpAndSettle();
    await tester.tap(loginBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(Scaffold), findsWidgets);
  });
}
