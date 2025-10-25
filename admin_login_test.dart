import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockvote/core/services/service_locator.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences
    await serviceLocator.registerTestServices();
  });

  testWidgets('Admin login test', (WidgetTester tester) async {
    // TODO: Implement admin login test
    // Example: await tester.pumpWidget(const MyApp());
    // Example: await tester.enterText(find.byKey(const Key('username_field')), 'admin');
    // Example: await tester.enterText(find.byKey(const Key('password_field')), 'password');
    // Example: await tester.tap(find.byKey(const Key('login_button')));
    // Example: await tester.pumpAndSettle();
    // Example: expect(find.text('Welcome Admin'), findsOneWidget);
  });
}