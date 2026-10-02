import 'package:flutter_test/flutter_test.dart';
import 'package:geo_jamaah/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GeoJamaahApp());
    expect(find.text('GEO-JAMAAH'), findsWidgets);
  });
}
