import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('login screen renders without crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
