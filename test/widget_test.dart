import 'package:flutter_test/flutter_test.dart';
import 'package:itop_mobile/main.dart';

void main() {
  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ITopMobileApp());
    await tester.pumpAndSettle();

    // Verify that the login screen is visible
    expect(find.text('iTop Mobile'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
