import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:integration_test/integration_test.dart';
import 'package:partesdetrabajo/main.dart' as app;
import 'package:signature/signature.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  User? mockUser;

  setUpAll(() async {
    final inicioSesionGoogle = MockGoogleSignIn();
    final usuarioGoogle = await inicioSesionGoogle.signIn();
    if (usuarioGoogle == null) return;

    final autenticacionGoogle = await usuarioGoogle.authentication;
    final credencialesGoogle = GoogleAuthProvider.credential(
      accessToken: autenticacionGoogle.accessToken,
      idToken: autenticacionGoogle.idToken,
    );

    final mock = MockUser(
      email: 'usuariotest@test.com',
      displayName: 'Usuario Test',
    );

    final auth = MockFirebaseAuth(mockUser: mock);
    final result = await auth.signInWithCredential(credencialesGoogle);
    mockUser = result.user;
  });

  testWidgets('Creacion parte y cliente', (tester) async {
    app.main(testUser: mockUser);
    await tester.runAsync(() async {
      while (find.text('PARTES').evaluate().isEmpty) {
        await tester.pumpAndSettle();
      }
    });

    expect(find.text('PARTES'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('NUEVO PARTE'), findsOneWidget);
    await tester.tap(find.byType(TextFormField).at(0));
    await tester.pumpAndSettle();

    expect(find.text('SELECCIÓN CLIENTE'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('NUEVO CLIENTE'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Cliente prueba');
    await tester.enterText(find.byType(TextFormField).at(1), 'cliente@correo.com');
    await tester.enterText(find.byType(TextFormField).at(2), '12345678A');
    await tester.enterText(find.byType(TextFormField).at(3), '987654321');
    await tester.enterText(find.byType(TextFormField).at(4), 'Calle Prueba, Ciudad 12345');
    await tester.tap(find.text('GUARDAR CLIENTE'));
    await tester.pumpAndSettle();

    expect(find.text('SELECCIÓN CLIENTE'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    await tester.tap(find.text('Cliente prueba'));
    await tester.pumpAndSettle();

    expect(find.text('NUEVO PARTE'), findsOneWidget);
    await tester.tap(find.text('Fecha inicio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('ACEPTAR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fecha final'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2'));
    await tester.tap(find.text('ACEPTAR'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(5), 'Nombres de otros trabajadores');
    await tester.enterText(find.byType(TextFormField).at(6), 'Alguna observaciones');
    await tester.tap(find.byType(TextFormField).at(7));
    await tester.pumpAndSettle();

    expect(find.text('NUEVO TRABAJO'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Descripcion de trabajo realizado');
    await tester.enterText(find.byType(TextFormField).at(1), 'Material 1\nMaterial2\nMaterial3');
    await tester.tap(find.text('GUARDAR'));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);
    await tester.tap(find.byType(TextFormField).at(7));
    await tester.pumpAndSettle();

    expect(find.text('Nº 2'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Otra descripcion de trabajo');
    await tester.enterText(find.byType(TextFormField).at(1), 'Material 4\nMaterial5\nMaterial6');
    await tester.tap(find.text('GUARDAR'));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNWidgets(2));
    await tester.ensureVisible(find.byType(TextFormField).at(10));
    await tester.tap(find.byType(TextFormField).at(10));
    await tester.pumpAndSettle();

    expect(find.text('FIRMAR'), findsOneWidget);
    final signatureFinder = find.byType(Signature);
    await tester.drag(signatureFinder, const Offset(100, 100));
    await tester.pumpAndSettle();
    final signatureController = tester.widget<Signature>(signatureFinder).controller;
    expect(signatureController.isNotEmpty, true);
    await tester.enterText(find.byType(TextFormField).at(0), 'Alguien');
    await tester.enterText(find.byType(TextFormField).at(0), '12345678A');
    await tester.tap(find.text('GUARDAR'));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNWidgets(3));
    await tester.ensureVisible(find.text('GUARDAR PARTE'));
    await tester.tap(find.text('GUARDAR PARTE'));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);
    expect(find.byIcon(Icons.draw), findsOneWidget);
  });
}
