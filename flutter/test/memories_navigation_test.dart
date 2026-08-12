import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/core/router/app_router.dart';
import 'package:ridermate/core/widgets/rm_bottom_nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Memories Navigation Unit & Widget Tests', () {
    test('AppRoutes contains canonical memories route constants', () {
      expect(AppRoutes.memories, equals('/memories'));
      expect(AppRoutes.journal, equals('/memories'));
      expect(AppRoutes.home, equals('/home'));
      expect(AppRoutes.nav, equals('/nav'));
      expect(AppRoutes.social, equals('/social'));
      expect(AppRoutes.profile, equals('/profile'));
    });

    testWidgets('RmBottomNav renders 5 primary destinations including Memories', (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                RmBottomNav(
                  currentIndex: 2, // Memories active
                  onTap: (index) {
                    tappedIndex = index;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all 5 tab labels are visible
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Ride'), findsOneWidget);
      expect(find.text('Memories'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify Memories icon is present
      expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);

      // Tap on Memories tab
      await tester.tap(find.text('Memories'));
      await tester.pump();
      expect(tappedIndex, equals(2));

      // Tap on Home tab
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(tappedIndex, equals(0));

      // Tap on Ride tab
      await tester.tap(find.text('Ride'));
      await tester.pump();
      expect(tappedIndex, equals(1));

      // Tap on Community tab
      await tester.tap(find.text('Community'));
      await tester.pump();
      expect(tappedIndex, equals(3));

      // Tap on Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(tappedIndex, equals(4));
    });
  });
}
