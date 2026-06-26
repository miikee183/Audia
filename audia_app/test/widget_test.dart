import 'package:flutter_test/flutter_test.dart';
import 'package:audia/main.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AudiaApp());
    expect(find.text('Audia'), findsOneWidget);
    expect(find.text('Tu día en audio'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
