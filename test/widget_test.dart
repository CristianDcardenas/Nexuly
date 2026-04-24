import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexuly_app/shared/widgets/nexuly_gradient_button.dart';

void main() {
  testWidgets('NexulyGradientButton renders label and icon', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NexulyGradientButton(
            label: 'Continuar',
            icon: Icons.check,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Continuar'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.byType(NexulyGradientButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
