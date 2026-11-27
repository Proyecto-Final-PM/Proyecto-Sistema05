import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Carga pantalla de inicio de sesion', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Inicio de sesión'), findsOneWidget);
    expect(find.text('Entrar (pantalla principal)'), findsOneWidget);
  });
}