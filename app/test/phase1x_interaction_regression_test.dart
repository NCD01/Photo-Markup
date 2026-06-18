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
}
