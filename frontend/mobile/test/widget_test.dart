import 'package:flutter_test/flutter_test.dart';
import 'package:immortal_campus_mobile/main.dart';

void main() {
  testWidgets('Immortal Campus smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ImmortalCampusApp());
    expect(find.text('IMMORTAL CAMPUS'), findsOneWidget);
  });
}
