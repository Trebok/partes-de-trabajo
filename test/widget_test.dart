import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partesdetrabajo/helper/local_storage.dart';
import 'package:partesdetrabajo/pages/cliente_pagina.dart';
import 'package:partesdetrabajo/pages/firma_pagina.dart';
import 'package:partesdetrabajo/pages/trabajo_pagina.dart';
import 'package:partesdetrabajo/pages/trabajos_predefinidos_pagina.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.configurePrefs();
  });
  group('Comprobacion errores', () {
    testWidgets('Crear cliente sin nombre', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ClientePagina()));
      expect(find.text('Este campo es obligatorio.'), findsNothing);
      await tester.tap(find.text('GUARDAR CLIENTE'));
      await tester.pump();
      expect(find.text('Este campo es obligatorio.'), findsOneWidget);
    });

    testWidgets('Crear trabajo sin descripcion', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TrabajoPagina(numero: 1)));
      expect(find.text('Este campo es obligatorio.'), findsNothing);
      await tester.tap(find.text('GUARDAR'));
      await tester.pump();
      expect(find.text('Este campo es obligatorio.'), findsOneWidget);
    });

    testWidgets('Firmar sin nombre', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FirmaPagina()));
      expect(find.text('Este campo es obligatorio.'), findsNothing);
      await tester.ensureVisible(find.text('GUARDAR'));
      await tester.tap(find.text('GUARDAR'));
      await tester.pump();
      expect(find.text('Este campo es obligatorio.'), findsOneWidget);
    });
  });

  testWidgets('Trabajos predefinidos', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TrabajosPredefinidos()));
    expect(find.byType(ListTile), findsNothing);
    await tester.enterText(find.byType(TextField), 'Instalación fotovoltaica');
    await tester.tap(find.text('Añadir'));
    await tester.pump();
    expect(find.byType(ListTile), findsOneWidget);
  });
}
