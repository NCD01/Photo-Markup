import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/widgets/dimension_lines_overlay.dart';
import 'package:ncd_photo_markup/main.dart';

void main() {
  testWidgets('renders shell empty-state text and open-photo action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp(showStartupSplash: false));

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(UiCopyConstants.emptyStateMessage), findsOneWidget);
    expect(find.text(ToolbarConstants.openPhoto), findsOneWidget);
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
                  startNormalized: Offset(0.2, 0.3),
                  endNormalized: Offset(0.7, 0.6),
                ),
              ],
              imageRect: const Rect.fromLTWH(20, 20, 460, 280),
              activeStart: const Offset(80, 220),
              activeEnd: const Offset(360, 240),
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
