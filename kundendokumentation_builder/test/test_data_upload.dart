import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:kundendokumentation_builder/features/report/data_upload.dart';
import 'package:kundendokumentation_builder/core/services/report_service.dart';

// Mock ReportService
class MockReportService extends Mock implements ReportService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockReportService reportService;

  setUp(() {
    reportService = MockReportService();
  });

  group('DataUploadScreen Widget Tests', () {
    testWidgets('zeigt AppBar, Buttons und keine ProgressBar inaktiv', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: DataUploadScreen(reportId: 42)),
      );

      // AppBar-Titel
      expect(find.text('Daten hinzufügen'), findsOneWidget);

      // Buttons vorhanden
      expect(
        find.widgetWithText(ElevatedButton, 'JSON-Datei hochladen'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Bild hinzufügen'),
        findsOneWidget,
      );

      // LinearProgressIndicator ist zu Beginn nicht sichtbar
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    // Optional – interaktiver Buttontest vorbereiten (wenn FilePicker gemockt wird)
    testWidgets('tap auf Hochlade-Button ist möglich (ohne Seiteneffekte)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: DataUploadScreen(reportId: 5)),
      );

      final jsonButton = find.widgetWithText(
        ElevatedButton,
        'JSON-Datei hochladen',
      );
      final imageButton = find.widgetWithText(
        ElevatedButton,
        'Bild hinzufügen',
      );

      expect(jsonButton, findsOneWidget);
      expect(imageButton, findsOneWidget);

      // Tap möglich (aber tut nichts, weil FilePicker hier echt ist)
      await tester.tap(jsonButton);
      await tester.pump();
    });
  });
}
