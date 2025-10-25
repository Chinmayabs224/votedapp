import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bockvote/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Integration Tests', () {
    testWidgets('Complete voting flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // 1. Login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'voter@bockvote.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'voter123',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // 2. Navigate to elections
      await tester.tap(find.byKey(const Key('elections_tab')));
      await tester.pumpAndSettle();

      // 3. Select an election
      await tester.tap(find.byKey(const Key('election_card_0')));
      await tester.pumpAndSettle();

      // 4. Cast vote
      await tester.tap(find.byKey(const Key('candidate_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_vote_button')));
      await tester.pumpAndSettle();

      // 5. Verify vote confirmation
      expect(find.text('Vote Submitted Successfully'), findsOneWidget);
      expect(find.byKey(const Key('tx_hash')), findsOneWidget);

      // 6. Check results
      await tester.tap(find.byKey(const Key('view_results_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('results_chart')), findsOneWidget);
    });

    testWidgets('Admin election creation flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // 1. Login as admin
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'admin@bockvote.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'admin123',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // 2. Navigate to admin panel
      await tester.tap(find.byKey(const Key('admin_tab')));
      await tester.pumpAndSettle();

      // 3. Create new election
      await tester.tap(find.byKey(const Key('create_election_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('election_title_field')),
        'Test Election',
      );
      await tester.enterText(
        find.byKey(const Key('election_description_field')),
        'This is a test election',
      );

      // 4. Add candidates
      await tester.tap(find.byKey(const Key('add_candidate_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('candidate_name_field')),
        'Candidate 1',
      );

      // 5. Submit election
      await tester.tap(find.byKey(const Key('submit_election_button')));
      await tester.pumpAndSettle();

      // 6. Verify election created
      expect(find.text('Election Created Successfully'), findsOneWidget);
    });

    testWidgets('Blockchain verification flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // 1. Login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'voter@bockvote.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'voter123',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // 2. Navigate to voting history
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('voting_history_button')));
      await tester.pumpAndSettle();

      // 3. Verify a vote
      await tester.tap(find.byKey(const Key('verify_vote_0')));
      await tester.pumpAndSettle();

      // 4. Check blockchain verification
      expect(find.text('Verified on Blockchain'), findsOneWidget);
      expect(find.byKey(const Key('blockchain_tx_hash')), findsOneWidget);
    });
  });
}
