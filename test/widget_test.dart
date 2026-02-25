import 'package:flutter_test/flutter_test.dart';
import 'package:itop_mobile/main.dart';

void main() {
  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ITopMobileApp());
    await tester.pumpAndSettle();

    // Verifica che la schermata di login sia visibile
    expect(find.text('iTop Mobile'), findsOneWidget);
    expect(find.text('Accedi'), findsOneWidget);
  });
}
