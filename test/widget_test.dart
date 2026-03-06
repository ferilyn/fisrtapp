import 'package:flutter_test/flutter_test.dart'; 

// Ensure 'fisrtapp' matches the name in your pubspec.yaml
import 'package:fisrtapp/main.dart';

void main() {
  testWidgets('VMS Home Screen Load Test', (WidgetTester tester) async {
    // FIX: Pass empty cameras list to resolve 'missing_required_argument'
    await tester.pumpWidget(const MyApp(cameras: []));

    // Verify your actual category buttons are visible
    expect(find.text('O.J.T.'), findsOneWidget); 
    expect(find.text('MAINTENANCE'), findsOneWidget);
    
    // Verify that the old counter '0' text is gone
    expect(find.text('0'), findsNothing);
  });
}