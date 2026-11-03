import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/app.dart';

void main() {
  testWidgets('app launches to the home placeholder', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MoksharanApp()));
    await tester.pumpAndSettle();

    expect(find.text('Moksharan'), findsOneWidget);
    expect(find.text('Foundation build. Sample content only.'), findsOneWidget);
  });
}
