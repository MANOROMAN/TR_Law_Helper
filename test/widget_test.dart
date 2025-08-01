// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hukuki_asistan/main.dart';

void main() {
  testWidgets('Hukuki Asistan app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(HukukiAsistanApp());

    // Verify that home screen elements are present
    expect(find.text('Hukuki Asistan'), findsOneWidget);
    expect(find.text("AI'ye Sor"), findsOneWidget);
    expect(find.text('Avukatla İletişime Geç'), findsOneWidget);
    expect(find.text('Dosyalarım'), findsOneWidget);
    expect(find.text('Takvim'), findsOneWidget);
  });
}
