// This is a basic Flutter widget test.
// To run these tests, run `flutter test` from the command line.

import 'package:flutter_test/flutter_test.dart';
import 'package:task_recorder_pro/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskRecorderProApp());
    expect(find.text('Recorder Pro'), findsOneWidget);
  });
}
