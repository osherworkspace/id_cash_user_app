import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:id_cash_user_app/main.dart';
import 'package:id_cash_user_app/services/idcash_api.dart';

void main() {
  testWidgets('ID-CASH welcome screen shows registration and login', (tester) async {
    SharedPreferences.setMockInitialValues({'idcash_customer_intro_completed_v1': true});
    final api = IdcashApi(baseUrl: 'https://example.invalid');
    addTearDown(api.close);

    await tester.pumpWidget(IdcashApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('ID-CASH'), findsOneWidget);
    expect(find.text('YOUR IDENTITY IS YOUR CASH'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });
}
