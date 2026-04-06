import 'package:flutter_test/flutter_test.dart';
import 'package:bizzway_rider_services/apps/rider_services_app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RiderServicesApp());
    await tester.pump();
  });
}
