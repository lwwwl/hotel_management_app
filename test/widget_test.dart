// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotel_management_app/main.dart';

void main() {
  testWidgets('Hotel management app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HotelManagementApp());

    // Verify that the login page is displayed.
    expect(find.text('欢迎回来'), findsOneWidget);
    expect(find.text('登录您的员工账号'), findsOneWidget);
  });
}
