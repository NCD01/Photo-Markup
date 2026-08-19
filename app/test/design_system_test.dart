import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/core/theme/design_tokens.dart';
import 'package:ncd_photo_markup/main.dart';

/// WCAG relative contrast between two opaque colours.
double contrastRatio(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double lighter = la > lb ? la : lb;
  final double darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('contrast', () {
    test('body text clears AAA against every surface it sits on', () {
      for (final Color surface in <Color>[
        DesignTokens.canvasVoid,
        DesignTokens.surface,
        DesignTokens.surfaceRaised,
        DesignTokens.surfaceHigh,
      ]) {
        expect(
          contrastRatio(DesignTokens.inkPrimary, surface),
          greaterThan(7.0),
        );
      }
    });

    test('the quietest text still clears AA large on every surface', () {
      for (final Color surface in <Color>[
        DesignTokens.canvasVoid,
        DesignTokens.surface,
        DesignTokens.surfaceRaised,
        DesignTokens.surfaceHigh,
      ]) {
        expect(
          contrastRatio(DesignTokens.inkSecondary, surface),
          greaterThan(4.5),
        );
      }
    });

    test('text on the brand colour is legible', () {
      expect(
        contrastRatio(DesignTokens.inkOnBrand, DesignTokens.brand),
        greaterThan(7.0),
      );
    });

    test('the danger colour separates from the surface it warns on', () {
      expect(
        contrastRatio(DesignTokens.danger, DesignTokens.surface),
        greaterThan(4.5),
      );
      expect(
        contrastRatio(DesignTokens.warning, DesignTokens.surface),
        greaterThan(4.5),
      );
    });

    test('disabled text is dim but still readable, not invisible', () {
      final double ratio = contrastRatio(
        DesignTokens.inkDisabled,
        DesignTokens.surface,
      );
      expect(ratio, greaterThan(3.0));
      expect(
        ratio,
        lessThan(
          contrastRatio(DesignTokens.inkSecondary, DesignTokens.surface),
        ),
      );
    });
  });

  group('sizing', () {
    test('touch targets are at least as large as the platform minimum', () {
      expect(DesignTokens.touchTarget, greaterThanOrEqualTo(48));
      expect(DesignTokens.touchTargetCompact, greaterThanOrEqualTo(48));
    });

    test('nothing in the type ramp is thin', () {
      expect(
        DesignTokens.weightMedium.index,
        greaterThan(FontWeight.w400.index),
      );
      expect(DesignTokens.weightBold.index, greaterThan(FontWeight.w500.index));
    });

    test('the theme uses the bundled face, not a platform default', () {
      expect(DesignTokens.buildTheme().textTheme.bodyMedium, isNotNull);
      expect(DesignTokens.fontFamily, 'Barlow');
    });

    test('the theme is dark', () {
      expect(DesignTokens.buildTheme().brightness, Brightness.dark);
    });
  });

  group('layout', () {
    for (final Size size in <Size>[
      Size(1024, 768), // the documented minimum window
      Size(1280, 800),
      Size(1920, 1080),
      Size(800, 1280), // portrait tablet
    ]) {
      testWidgets('the shell lays out with no overflow at $size', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const NcdPhotoMarkupApp(showStartupSplash: false),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
        state.debugSeedLoadedImageState(pixelSize: const Size(4000, 3000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // And with the rail open, which is the tighter case.
        await tester.tap(
          find.byKey(const ValueKey<String>('sidebar-rail-toggle')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'tool, colour and width are on screen without opening anything',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const NcdPhotoMarkupApp(showStartupSplash: false),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('status-active-tool')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('status-zoom-label')),
          findsOneWidget,
        );
        for (final String scaleLabel in MarkupStrokeConstants.allScaleLabels) {
          expect(
            find.byKey(ValueKey<String>('status-width-$scaleLabel')),
            findsOneWidget,
          );
        }
        expect(
          find.byKey(const ValueKey<String>('status-color-ncdBlue')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('status-color-orange')),
          findsOneWidget,
        );
      },
    );

    testWidgets('the rail never covers the canvas', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const NcdPhotoMarkupApp(showStartupSplash: false),
      );
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(PhotoMarkupShellScreen));
      state.debugSeedLoadedImageState(pixelSize: const Size(1600, 1200));
      await tester.pumpAndSettle();

      final double collapsedCanvasLeft = tester
          .getTopLeft(find.byKey(const ValueKey<String>('markup-canvas')))
          .dx;

      await tester.tap(
        find.byKey(const ValueKey<String>('sidebar-rail-toggle')),
      );
      await tester.pumpAndSettle();

      final double expandedCanvasLeft = tester
          .getTopLeft(find.byKey(const ValueKey<String>('markup-canvas')))
          .dx;

      // Opening the rail moves the canvas over rather than floating a panel
      // on top of it, which is what used to swallow the first stroke.
      expect(expandedCanvasLeft, greaterThan(collapsedCanvasLeft));
    });
  });
}
