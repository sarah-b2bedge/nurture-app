import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurture_assistant/main.dart';

void main() {
  testWidgets('user can create an account and reach the home dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const NurtureAssistantApp());

    expect(find.text('Welcome to Nurture Assistant'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Tell us about your baby'), findsOneWidget);

    await tester.tap(find.text('Finish setup'));
    await tester.pumpAndSettle();
    expect(find.text('Good evening, Maya'), findsOneWidget);
    expect(find.text('Tell me what happened'), findsOneWidget);
  });

  testWidgets('medicine parsed from AI requires confirmation before saving', (
    tester,
  ) async {
    await tester.pumpWidget(const NurtureAssistantApp());

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tell me what happened'));
    await tester.pumpAndSettle();
    expect(find.text('Review before saving'), findsOneWidget);

    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save 2 logs'),
    );
    expect(saveButton.onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    final enabledButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save 2 logs'),
    );
    expect(enabledButton.onPressed, isNotNull);
  });

  testWidgets('profile keeps care units out of personal account details', (
    tester,
  ) async {
    await tester.pumpWidget(const NurtureAssistantApp());

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Role'), findsOneWidget);
    expect(find.text('Units'), findsNothing);
    expect(find.text('ml and °F'), findsNothing);
  });
}
