import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/integration/models/photo_markup_launch_context.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/widgets/dimension_lines_overlay.dart';
import 'package:ncd_photo_markup/main.dart';

void main() {
  testWidgets('renders shell empty-state text and open-photo action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appVersion), findsOneWidget);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
    expect(find.text(ToolbarConstants.openPhoto), findsOneWidget);
  });

  testWidgets('startup splash shows centralized app version', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: true));

    expect(find.text(AppConstants.appVersion), findsOneWidget);
    await tester.pump(
      const Duration(
        milliseconds: BrandingAssetConstants.startupSplashDurationMs,
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('shows launch context summary when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const NcdPhotoMarkupApp(
        showStartupSplash: false,
        launchContext: PhotoMarkupLaunchContext(
          launchedFromControlCenter: true,
          clientName: 'Client X',
          projectCode: 'PRJ-42',
          sourceLabel: 'Control Center',
        ),
      ),
    );

    expect(find.textContaining('Client: Client X'), findsOneWidget);
    expect(find.textContaining('Project: PRJ-42'), findsOneWidget);
  });

  testWidgets('selecting dimension without image does not crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await tester.tap(
      find.widgetWithText(OutlinedButton, ToolbarConstants.dimension),
    );
    await tester.pump();
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('selecting rectangle without image does not crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    final Finder rectangleButton = find.widgetWithText(
      OutlinedButton,
      ToolbarConstants.rectangle,
    );
    final Finder toolbarScrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      rectangleButton,
      240,
      scrollable: toolbarScrollable,
    );
    await tester.tap(rectangleButton);
    await tester.pump();
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('selecting circle without image does not crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    final Finder circleButton = find.widgetWithText(
      OutlinedButton,
      ToolbarConstants.circle,
    );
    final Finder toolbarScrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      circleButton,
      240,
      scrollable: toolbarScrollable,
    );
    await tester.tap(circleButton);
    await tester.pump();
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('selecting freehand without image does not crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    final Finder freehandButton = find.widgetWithText(
      OutlinedButton,
      ToolbarConstants.freehand,
    );
    final Finder toolbarScrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      freehandButton,
      240,
      scrollable: toolbarScrollable,
    );
    await tester.tap(freehandButton);
    await tester.pump();
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('selecting text note without image does not crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    final Finder textNoteButton = find.widgetWithText(
      OutlinedButton,
      ToolbarConstants.textNote,
    );
    final Finder toolbarScrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      textNoteButton,
      240,
      scrollable: toolbarScrollable,
    );
    await tester.tap(textNoteButton);
    await tester.pump();
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('style preset dialog opens and applies selection safely', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    final Finder styleButton = find.widgetWithText(
      OutlinedButton,
      'Style: Blue',
    );
    final Finder toolbarScrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      styleButton,
      240,
      scrollable: toolbarScrollable,
    );
    await tester.tap(styleButton);
    await tester.pumpAndSettle();
    expect(find.text(UiCopyConstants.styleDialogTitle), findsOneWidget);

    await tester.tap(find.text('Red'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(OutlinedButton, 'Style: Red'), findsOneWidget);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('export with no photo shows friendly warning', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    final Finder exportButton = find.widgetWithText(
      OutlinedButton,
      ToolbarConstants.export,
    );
    final Finder toolbarScrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      exportButton,
      240,
      scrollable: toolbarScrollable,
    );
    await tester.tap(exportButton);
    await tester.pump();

    expect(find.text(UiCopyConstants.exportNoPhotoMessage), findsOneWidget);
  });

  testWidgets('save markup with no photo shows friendly warning', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    final Finder saveMarkupButton = find.widgetWithText(
      OutlinedButton,
      ToolbarConstants.saveMarkup,
    );
    final Finder toolbarScrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      saveMarkupButton,
      240,
      scrollable: toolbarScrollable,
    );
    await tester.tap(saveMarkupButton);
    await tester.pump();

    expect(
      find.text(UiCopyConstants.markupDocumentSaveNoPhotoMessage),
      findsOneWidget,
    );
  });

  testWidgets('erase with no selected line shows gentle message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    final Finder eraseButton = find.widgetWithText(
      OutlinedButton,
      ToolbarConstants.erase,
    );
    final Finder toolbarScrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      eraseButton,
      240,
      scrollable: toolbarScrollable,
    );
    await tester.tap(eraseButton);
    await tester.pump();

    expect(find.text(UiCopyConstants.eraseNoSelectionMessage), findsOneWidget);
  });

  testWidgets('dimension overlay reports drag callbacks', (
    WidgetTester tester,
  ) async {
    Offset? startPoint;
    Offset? updatePoint;
    bool endCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 500,
          height: 320,
          child: ColoredBox(
            color: Colors.white,
            child: DimensionLinesOverlay(
              lines: const <DimensionLine>[
                DimensionLine(
                  id: 1,
                  startNormalized: Offset(0.2, 0.3),
                  endNormalized: Offset(0.7, 0.6),
                ),
              ],
              arrows: const <ArrowMarkup>[],
              rectangles: const <RectangleMarkup>[],
              ovals: const <OvalMarkup>[],
              freehands: const <FreehandMarkup>[],
              textNotes: const <TextNoteMarkup>[],
              imageRect: const Rect.fromLTWH(20, 20, 460, 280),
              selectedDimensionId: null,
              selectedArrowId: null,
              selectedRectangleId: null,
              selectedOvalId: null,
              selectedFreehandId: null,
              selectedTextNoteId: null,
              activeStylePresetId: MarkupStylePresets.defaultPresetId,
              activeTool: MarkupTool.dimension,
              activeStart: const Offset(80, 220),
              activeEnd: const Offset(360, 240),
              activeFreehandPoints: const <Offset>[],
              isEnabled: true,
              onStart: (Offset point) => startPoint = point,
              onUpdate: (Offset point) => updatePoint = point,
              onEnd: () => endCalled = true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder overlayFinder = find.byType(DimensionLinesOverlay);
    final Offset center = tester.getCenter(overlayFinder);
    final TestGesture gesture = await tester.startGesture(
      center.translate(-40, -20),
    );
    await gesture.moveTo(center.translate(60, 30));
    await gesture.up();
    await tester.pump();

    expect(startPoint, isNotNull);
    expect(updatePoint, isNotNull);
    expect(endCalled, isTrue);
  });
}
