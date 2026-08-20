import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_tool.dart';
import 'package:ncd_photo_markup/features/markup/utils/dimension_label_formatter.dart';
import 'package:ncd_photo_markup/features/markup/utils/markup_text_layout_utils.dart';
import 'package:ncd_photo_markup/main.dart';

Future<void> _pumpFrames(WidgetTester tester, {int frames = 12}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _expandSidebarIfCollapsed(WidgetTester tester) async {
  final Finder drawerToggle = find.byKey(
    const ValueKey<String>('sidebar-drawer-toggle'),
  );
  if (drawerToggle.evaluate().isNotEmpty) {
    return;
  }
  final Finder expandButton = find.byKey(
    const ValueKey<String>('sidebar-rail-toggle'),
  );
  if (expandButton.evaluate().isNotEmpty) {
    await tester.tap(expandButton);
    await _pumpFrames(tester, frames: 20);
  }
}

ValueKey<String> _drawerActionKey(String actionLabel) =>
    ValueKey<String>('sidebar-drawer-$actionLabel');

Future<void> _tapSidebarAction(WidgetTester tester, String label) async {
  await _expandSidebarIfCollapsed(tester);
  final Finder sidebarScrollable = find.descendant(
    of: find.byKey(const ValueKey<String>('sidebar-drawer-scroll')),
    matching: find.byType(Scrollable),
  );
  final Finder actionLabel = find.byKey(_drawerActionKey(label));
  await tester.scrollUntilVisible(
    actionLabel,
    220,
    scrollable: sidebarScrollable,
  );
  await tester.ensureVisible(actionLabel);
  await _pumpFrames(tester, frames: 8);
  await tester.tap(actionLabel, warnIfMissed: false);
  await _pumpFrames(tester, frames: 8);
}

void main() {
  testWidgets(
    'dimension tool can create near existing dimension without selection stealing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const NcdPhotoMarkupApp(showStartupSplash: false),
      );
      await _pumpFrames(tester, frames: 12);

      final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
      state.debugSeedLoadedImageState();
      state.debugSetDimensionLines(<DimensionLine>[
        const DimensionLine(
          id: 1,
          startNormalized: Offset(0.20, 0.30),
          endNormalized: Offset(0.55, 0.30),
          label: '100',
        ),
      ]);
      await _pumpFrames(tester, frames: 12);

      await _tapSidebarAction(tester, ToolbarConstants.dimension);

      final Rect imageRect = state.debugCurrentImageRect() as Rect;
      final Offset start =
          imageRect.topLeft +
          Offset(imageRect.width * 0.22, imageRect.height * 0.34);
      final Offset end =
          start + Offset(imageRect.width * 0.26, imageRect.height * 0.01);
      unawaited(state.debugCanvasDrag(start: start, end: end));
      await _pumpFrames(tester, frames: 12);

      expect(
        find.text(UiCopyConstants.dimensionLabelDialogTitle),
        findsOneWidget,
      );
      await tester.tap(find.text(UiCopyConstants.dimensionLabelSkipButton));
      await _pumpFrames(tester, frames: 12);

      final dynamic refreshedState = tester.state(
        find.byType(PhotoMarkupShellScreen),
      );
      expect(refreshedState.debugDimensionLinesSnapshot.length, 2);
      expect(refreshedState.debugSelectedTool, MarkupTool.dimension);
    },
  );

  testWidgets('select mode can select and move an existing dimension line', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _pumpFrames(tester, frames: 12);

    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState();
    state.debugSetDimensionLines(<DimensionLine>[
      const DimensionLine(
        id: 1,
        startNormalized: Offset(0.20, 0.30),
        endNormalized: Offset(0.55, 0.30),
        label: '100',
      ),
    ]);
    await _pumpFrames(tester, frames: 12);

    final Rect imageRect = state.debugCurrentImageRect() as Rect;
    final Offset lineBodyPoint =
        imageRect.topLeft +
        Offset(imageRect.width * 0.24, imageRect.height * 0.30);
    await state.debugCanvasTap(lineBodyPoint);
    await _pumpFrames(tester, frames: 8);

    dynamic refreshedState = tester.state(find.byType(PhotoMarkupShellScreen));
    expect(refreshedState.debugSelectedDimensionId, 1);

    final DimensionLine beforeMove =
        (refreshedState.debugDimensionLinesSnapshot as List<DimensionLine>)
            .first;
    await refreshedState.debugCanvasDrag(
      start: lineBodyPoint,
      end: lineBodyPoint + const Offset(36, 18),
    );
    await _pumpFrames(tester, frames: 12);

    refreshedState = tester.state(find.byType(PhotoMarkupShellScreen));
    final DimensionLine afterMove =
        (refreshedState.debugDimensionLinesSnapshot as List<DimensionLine>)
            .first;
    expect(afterMove.startNormalized, isNot(beforeMove.startNormalized));
    expect(afterMove.endNormalized, isNot(beforeMove.endNormalized));
  });

  testWidgets('select mode can edit an existing dimension label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _pumpFrames(tester, frames: 12);

    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    const DimensionLine line = DimensionLine(
      id: 1,
      startNormalized: Offset(0.20, 0.30),
      endNormalized: Offset(0.55, 0.30),
      label: '100',
    );
    state.debugSeedLoadedImageState();
    state.debugSetDimensionLines(<DimensionLine>[line], selectedId: 1);
    await _pumpFrames(tester, frames: 12);

    final Rect imageRect = state.debugCurrentImageRect() as Rect;
    final DimensionLabelLayout? labelLayout =
        MarkupTextLayoutUtils.layoutDimensionLabel(
          line: line,
          imageRect: imageRect,
          start: line.startInRect(imageRect),
          end: line.endInRect(imageRect),
        );
    expect(labelLayout, isNotNull);

    unawaited(state.debugCanvasTap(labelLayout!.labelCenter));
    await _pumpFrames(tester, frames: 12);

    expect(
      find.text(UiCopyConstants.dimensionLabelDialogTitle),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), '125');
    await tester.tap(find.text(UiCopyConstants.dimensionLabelSaveButton));
    await _pumpFrames(tester, frames: 12);

    final dynamic refreshedState = tester.state(
      find.byType(PhotoMarkupShellScreen),
    );
    final DimensionLine updatedLine =
        (refreshedState.debugDimensionLinesSnapshot as List<DimensionLine>)
            .first;
    expect(updatedLine.label, DimensionLabelFormatter.format('125'));
  });

  testWidgets(
    'select mode can adjust dimension endpoints and move label independently',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const NcdPhotoMarkupApp(showStartupSplash: false),
      );
      await _pumpFrames(tester, frames: 12);

      final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
      const DimensionLine line = DimensionLine(
        id: 1,
        startNormalized: Offset(0.20, 0.30),
        endNormalized: Offset(0.55, 0.30),
        label: '100',
      );
      state.debugSeedLoadedImageState();
      state.debugSetDimensionLines(<DimensionLine>[line], selectedId: 1);
      await _pumpFrames(tester, frames: 12);

      final Rect imageRect = state.debugCurrentImageRect() as Rect;
      final Offset startHandle = line.startInRect(imageRect);
      await state.debugCanvasDrag(
        start: startHandle,
        end: startHandle + const Offset(-24, 12),
      );
      await _pumpFrames(tester, frames: 12);

      dynamic refreshedState = tester.state(
        find.byType(PhotoMarkupShellScreen),
      );
      final DimensionLine afterEndpoint =
          (refreshedState.debugDimensionLinesSnapshot as List<DimensionLine>)
              .first;
      expect(afterEndpoint.startNormalized, isNot(line.startNormalized));

      final DimensionLabelLayout? labelLayout =
          MarkupTextLayoutUtils.layoutDimensionLabel(
            line: afterEndpoint,
            imageRect: imageRect,
            start: afterEndpoint.startInRect(imageRect),
            end: afterEndpoint.endInRect(imageRect),
          );
      expect(labelLayout, isNotNull);

      await refreshedState.debugCanvasDrag(
        start: labelLayout!.labelCenter,
        end: labelLayout.labelCenter + const Offset(40, -28),
      );
      await _pumpFrames(tester, frames: 12);

      refreshedState = tester.state(find.byType(PhotoMarkupShellScreen));
      final DimensionLine afterLabelMove =
          (refreshedState.debugDimensionLinesSnapshot as List<DimensionLine>)
              .first;
      expect(afterLabelMove.labelOffsetNormalized, isNotNull);
      expect(afterLabelMove.startNormalized, afterEndpoint.startNormalized);
      expect(afterLabelMove.endNormalized, afterEndpoint.endNormalized);
    },
  );

  testWidgets('select mode can select and move an existing arrow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _pumpFrames(tester, frames: 12);

    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    const ArrowMarkup arrow = ArrowMarkup(
      id: 1,
      startNormalized: Offset(0.20, 0.40),
      endNormalized: Offset(0.48, 0.52),
    );
    state.debugSeedLoadedImageState();
    state.debugSetArrows(<ArrowMarkup>[arrow]);
    await _pumpFrames(tester, frames: 12);

    final Rect imageRect = state.debugCurrentImageRect() as Rect;
    final Offset midpoint = Offset.lerp(
      arrow.startInRect(imageRect),
      arrow.endInRect(imageRect),
      0.5,
    )!;
    await state.debugCanvasTap(midpoint);
    await _pumpFrames(tester, frames: 8);

    await state.debugCanvasDrag(
      start: midpoint,
      end: midpoint + const Offset(30, 10),
    );
    await _pumpFrames(tester, frames: 12);

    final dynamic refreshedState = tester.state(
      find.byType(PhotoMarkupShellScreen),
    );
    final ArrowMarkup movedArrow =
        (refreshedState.debugArrowsSnapshot as List<ArrowMarkup>).first;
    expect(movedArrow.startNormalized, isNot(arrow.startNormalized));
    expect(movedArrow.endNormalized, isNot(arrow.endNormalized));
  });
  testWidgets(
    'a new dimension on a calibrated photo is labelled without asking',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const NcdPhotoMarkupApp(showStartupSplash: false),
      );
      await _pumpFrames(tester, frames: 12);

      final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
      state.debugSeedLoadedImageState();
      await _pumpFrames(tester, frames: 12);

      // Calibrate: half the photo width is 10 ft.
      await _tapSidebarAction(tester, ToolbarConstants.scaleCalibration);
      final Rect imageRect = state.debugCurrentImageRect() as Rect;
      final Offset calibrationStart =
          imageRect.topLeft +
          Offset(imageRect.width * 0.20, imageRect.height * 0.20);
      final Offset calibrationEnd =
          calibrationStart + Offset(imageRect.width * 0.50, 0);
      unawaited(
        state.debugCanvasDrag(start: calibrationStart, end: calibrationEnd),
      );
      await _pumpFrames(tester, frames: 12);

      // The sidebar action carries the same label, so scope to the dialog.
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(UiCopyConstants.scaleCalibrationDialogTitle),
        ),
        findsOneWidget,
      );
      final Finder dialogFields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      final Finder distanceField = dialogFields.first;
      final Finder unitField = dialogFields.at(1);
      await tester.enterText(distanceField, '10');
      await tester.enterText(unitField, 'ft');
      await _pumpFrames(tester, frames: 4);
      await tester.tap(
        find.text(UiCopyConstants.scaleCalibrationSaveButton),
      );
      await _pumpFrames(tester, frames: 12);

      // Draw a dimension across a quarter of the photo width: 5 ft.
      await _tapSidebarAction(tester, ToolbarConstants.dimension);
      final dynamic calibratedState = tester.state(
        find.byType(PhotoMarkupShellScreen),
      );
      final Rect rect = calibratedState.debugCurrentImageRect() as Rect;
      final Offset dimensionStart =
          rect.topLeft + Offset(rect.width * 0.20, rect.height * 0.60);
      final Offset dimensionEnd =
          dimensionStart + Offset(rect.width * 0.25, 0);
      unawaited(
        calibratedState.debugCanvasDrag(
          start: dimensionStart,
          end: dimensionEnd,
        ),
      );
      await _pumpFrames(tester, frames: 12);

      // Task 2: with a scale set the measurement IS the answer, so no dialog
      // opens at all. The label lands on the line directly.
      expect(
        find.text(UiCopyConstants.dimensionLabelDialogTitle),
        findsNothing,
      );

      final dynamic savedState = tester.state(
        find.byType(PhotoMarkupShellScreen),
      );
      // Stored verbatim: never routed through the imperial shorthand
      // formatter, which would turn "5 ft" into 60 inches.
      expect(savedState.debugDimensionLinesSnapshot.last.label, '5 ft');
    },
  );

  testWidgets('a dimension without a scale still prompts for a typed label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _pumpFrames(tester, frames: 12);

    final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
    state.debugSeedLoadedImageState();
    await _pumpFrames(tester, frames: 12);

    await _tapSidebarAction(tester, ToolbarConstants.dimension);
    final Rect imageRect = state.debugCurrentImageRect() as Rect;
    final Offset start =
        imageRect.topLeft +
        Offset(imageRect.width * 0.20, imageRect.height * 0.40);
    final Offset end = start + Offset(imageRect.width * 0.30, 0);
    unawaited(state.debugCanvasDrag(start: start, end: end));
    await _pumpFrames(tester, frames: 12);

    final TextField labelField = tester.widget<TextField>(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
    );
    expect(labelField.controller!.text, isEmpty);
    expect(find.text(UiCopyConstants.dimensionMeasuredHint), findsNothing);

    await tester.tap(find.text(UiCopyConstants.dimensionLabelSkipButton));
    await _pumpFrames(tester, frames: 12);
  });

  testWidgets(
    'editing an existing dimension still opens the dialog even when a scale '
    'is set',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const NcdPhotoMarkupApp(showStartupSplash: false),
      );
      await _pumpFrames(tester, frames: 12);

      final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
      state.debugSeedLoadedImageState();
      await _pumpFrames(tester, frames: 12);

      // Calibrate so the auto-label path is live.
      await _tapSidebarAction(tester, ToolbarConstants.scaleCalibration);
      final Rect imageRect = state.debugCurrentImageRect() as Rect;
      final Offset cStart =
          imageRect.topLeft +
          Offset(imageRect.width * 0.20, imageRect.height * 0.20);
      unawaited(
        state.debugCanvasDrag(
          start: cStart,
          end: cStart + Offset(imageRect.width * 0.50, 0),
        ),
      );
      await _pumpFrames(tester, frames: 12);
      final Finder dialogFields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(dialogFields.first, '10');
      await tester.enterText(dialogFields.at(1), 'ft');
      await _pumpFrames(tester, frames: 4);
      await tester.tap(find.text(UiCopyConstants.scaleCalibrationSaveButton));
      await _pumpFrames(tester, frames: 12);

      // Draw one: auto-labelled, no dialog.
      await _tapSidebarAction(tester, ToolbarConstants.dimension);
      final dynamic s2 = tester.state(find.byType(PhotoMarkupShellScreen));
      final Rect rect = s2.debugCurrentImageRect() as Rect;
      final Offset dStart =
          rect.topLeft + Offset(rect.width * 0.20, rect.height * 0.60);
      unawaited(
        s2.debugCanvasDrag(
          start: dStart,
          end: dStart + Offset(rect.width * 0.25, 0),
        ),
      );
      await _pumpFrames(tester, frames: 12);
      expect(find.text(UiCopyConstants.dimensionLabelDialogTitle), findsNothing);

      final dynamic s3 = tester.state(find.byType(PhotoMarkupShellScreen));
      final int placedId = s3.debugDimensionLinesSnapshot.last.id as int;
      expect(s3.debugDimensionLinesSnapshot.last.label, '5 ft');

      // Auto-labelling must not make the dimension read-only. Asking to edit it
      // opens the dialog, carrying the existing label.
      unawaited(s3.debugPromptForDimensionLabel(placedId));
      await _pumpFrames(tester, frames: 12);
      expect(
        find.text(UiCopyConstants.dimensionLabelDialogTitle),
        findsOneWidget,
      );
      final TextField field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
      );
      expect(field.controller!.text, '5 ft');

      // A typed override still runs through DimensionLabelFormatter.
      await tester.enterText(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ), "6'-0\"");
      await _pumpFrames(tester, frames: 4);
      await tester.tap(find.text(UiCopyConstants.dimensionLabelSaveButton));
      await _pumpFrames(tester, frames: 12);

      final dynamic s4 = tester.state(find.byType(PhotoMarkupShellScreen));
      expect(s4.debugDimensionLinesSnapshot.last.label, '72"');
    },
  );

}
