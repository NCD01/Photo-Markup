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
  testWidgets('renders shell empty-state text and open-photo action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appVersion), findsOneWidget);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>('sidebar-rail-${ToolbarConstants.openPhoto}'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('toolbar renders grouped section headers and core actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _expandSidebarIfCollapsed(tester);
    final Finder sidebarList = find.descendant(
      of: find.byKey(const ValueKey<String>('sidebar-drawer-scroll')),
      matching: find.byType(Scrollable),
    );

    expect(
      find.byKey(_drawerActionKey(ToolbarConstants.openPhoto)),
      findsOneWidget,
    );
    expect(
      find.byKey(_drawerActionKey(ToolbarConstants.export)),
      findsOneWidget,
    );
    expect(find.text(ToolbarConstants.fileSectionTitle), findsOneWidget);
    expect(find.text(ToolbarConstants.markupSectionTitle), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(ToolbarConstants.editSectionTitle),
      260,
      scrollable: sidebarList,
    );
    expect(find.text(ToolbarConstants.editSectionTitle), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(_drawerActionKey(ToolbarConstants.erase)),
      240,
      scrollable: sidebarList,
    );
    expect(
      find.byKey(_drawerActionKey(ToolbarConstants.erase)),
      findsOneWidget,
    );
  });

  testWidgets('sidebar toggles between expanded and collapsed states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));

    expect(
      find.byKey(const ValueKey<String>('sidebar-rail-toggle')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey<String>('sidebar-rail-toggle')));
    await tester.pumpAndSettle();

    expect(find.text(ToolbarConstants.fileSectionTitle), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('sidebar-drawer-toggle')),
      findsOneWidget,
    );
  });

  testWidgets('active tool status stays visible and updates on selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _expandSidebarIfCollapsed(tester);

    expect(
      find.textContaining(
        '${UiCopyConstants.toolbarActiveToolPrefix}: ${UiCopyConstants.toolbarActiveToolNone}',
      ),
      findsOneWidget,
    );

    await _tapSidebarAction(tester, ToolbarConstants.dimension);
    expect(
      find.textContaining(
        '${UiCopyConstants.toolbarActiveToolPrefix}: ${ToolbarConstants.dimension}',
      ),
      findsOneWidget,
    );
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
    await _pumpFrames(tester, frames: 20);
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
    await _tapSidebarAction(tester, ToolbarConstants.dimension);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('selecting rectangle without image does not crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _tapSidebarAction(tester, ToolbarConstants.rectangle);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('selecting circle without image does not crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _tapSidebarAction(tester, ToolbarConstants.circle);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('selecting freehand without image does not crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _tapSidebarAction(tester, ToolbarConstants.freehand);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('selecting text note without image does not crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _tapSidebarAction(tester, ToolbarConstants.textNote);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('style preset dialog opens and applies selection safely', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _expandSidebarIfCollapsed(tester);
    await _tapSidebarAction(tester, ToolbarConstants.style);
    await _pumpFrames(tester, frames: 16);
    expect(find.text(UiCopyConstants.styleDialogTitle), findsOneWidget);

    await tester.tap(find.text('Red'));
    await _pumpFrames(tester, frames: 16);
    await tester.tap(find.text(UiCopyConstants.styleDialogApplyButton));
    await _pumpFrames(tester, frames: 16);
    expect(find.text('Style: Red'), findsWidgets);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
  });

  testWidgets('export with no photo shows friendly warning', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _tapSidebarAction(tester, ToolbarConstants.export);

    expect(find.text(UiCopyConstants.exportNoPhotoMessage), findsOneWidget);
  });

  testWidgets('save markup with no photo shows friendly warning', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _tapSidebarAction(tester, ToolbarConstants.saveMarkup);

    expect(
      find.text(UiCopyConstants.markupDocumentSaveNoPhotoMessage),
      findsOneWidget,
    );
  });

  testWidgets('erase with no selected line shows gentle message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _tapSidebarAction(tester, ToolbarConstants.erase);

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

  testWidgets('selecting markup tool disables pan mode when active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _pumpFrames(tester, frames: 16);

    final List<String> tools = <String>[
      ToolbarConstants.dimension,
      ToolbarConstants.textNote,
      ToolbarConstants.arrow,
      ToolbarConstants.rectangle,
      ToolbarConstants.circle,
      ToolbarConstants.freehand,
    ];

    for (final String tool in tools) {
      final dynamic stateBefore = tester.state(
        find.byType(PhotoMarkupShellScreen),
      );
      stateBefore.debugSetPanModeEnabled(true);
      await _pumpFrames(tester, frames: 4);
      expect(stateBefore.debugIsPanModeEnabled, isTrue);

      final Finder railToolButton = find.byKey(
        ValueKey<String>('sidebar-rail-$tool'),
      );
      expect(railToolButton, findsOneWidget);

      await tester.tap(railToolButton);
      await _pumpFrames(tester, frames: 8);

      final dynamic stateAfter = tester.state(
        find.byType(PhotoMarkupShellScreen),
      );
      expect(stateAfter.debugIsPanModeEnabled, isFalse);
    }
  });

  testWidgets('tapping the active markup tool returns to select mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _pumpFrames(tester, frames: 12);
    await _expandSidebarIfCollapsed(tester);

    await _tapSidebarAction(tester, ToolbarConstants.dimension);
    expect(
      find.textContaining(
        '${UiCopyConstants.toolbarActiveToolPrefix}: ${ToolbarConstants.dimension}',
      ),
      findsOneWidget,
    );

    await _tapSidebarAction(tester, ToolbarConstants.dimension);
    expect(
      find.textContaining(
        '${UiCopyConstants.toolbarActiveToolPrefix}: ${UiCopyConstants.toolbarActiveToolNone}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('active tool stays selected when pan mode is turned off from it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));
    await _pumpFrames(tester, frames: 12);
    await _expandSidebarIfCollapsed(tester);

    await _tapSidebarAction(tester, ToolbarConstants.dimension);

    final dynamic stateBefore = tester.state(
      find.byType(PhotoMarkupShellScreen),
    );
    stateBefore.debugSetPanModeEnabled(true);
    await _pumpFrames(tester, frames: 4);

    await _tapSidebarAction(tester, ToolbarConstants.dimension);

    final dynamic stateAfter = tester.state(
      find.byType(PhotoMarkupShellScreen),
    );
    expect(stateAfter.debugIsPanModeEnabled, isFalse);
    expect(
      find.textContaining(
        '${UiCopyConstants.toolbarActiveToolPrefix}: ${ToolbarConstants.dimension}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('launch error message renders in empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const NcdPhotoMarkupApp(
        showStartupSplash: false,
        launchErrorMessage: ImageImportConstants.dwgPreviewUnavailableMessage,
        launchContext: PhotoMarkupLaunchContext(
          launchedFromControlCenter: true,
          clientName: 'Manual Validation',
          projectCode: 'PH1Y',
          sourceLabel: 'Known bad DWG',
        ),
      ),
    );
    await _pumpFrames(tester, frames: 16);

    expect(
      find.text(UiCopyConstants.importErrorDialogTitle),
      findsOneWidget,
    );
    expect(
      find.text(ImageImportConstants.dwgPreviewUnavailableMessage),
      findsWidgets,
    );
    expect(
      find.text(UiCopyConstants.importErrorDialogDismissButton),
      findsOneWidget,
    );
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
    expect(find.textContaining('Source: Known bad DWG'), findsOneWidget);
  });
}
