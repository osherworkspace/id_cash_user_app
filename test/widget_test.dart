import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:id_cash_user_app/main.dart';
import 'package:id_cash_user_app/services/idcash_api.dart';

void main() {
  testWidgets('ID-CASH welcome screen shows registration and login', (tester) async {
    final api = IdcashApi(baseUrl: 'https://example.invalid');
    addTearDown(api.close);

    await tester.pumpWidget(IdcashApp(api: api));

    expect(find.text('ID-CASH'), findsOneWidget);
    expect(find.text('YOUR IDENTITY IS YOUR CASH'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
  });
}
