import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/view/utils/canvas_view_transform_utils.dart';

void main() {
  test('clampScale keeps values inside configured min/max', () {
    expect(
      CanvasViewTransformUtils.clampScale(ViewControlConstants.minScale - 1),
      ViewControlConstants.minScale,
    );
    expect(
      CanvasViewTransformUtils.clampScale(ViewControlConstants.maxScale + 1),
      ViewControlConstants.maxScale,
    );
  });

  test('zoom step helpers clamp at min/max bounds', () {
    expect(
      CanvasViewTransformUtils.zoomInStep(ViewControlConstants.maxScale),
      ViewControlConstants.maxScale,
    );
    expect(
      CanvasViewTransformUtils.zoomOutStep(ViewControlConstants.minScale),
      ViewControlConstants.minScale,
    );
  });

  test('zoomPercent returns rounded integer percentage', () {
    expect(CanvasViewTransformUtils.zoomPercent(1.0), 100);
    expect(CanvasViewTransformUtils.zoomPercent(1.26), 126);
  });

  test('wheelScaleDelta zooms in on negative scroll and out on positive', () {
    final double zoomInDelta = CanvasViewTransformUtils.wheelScaleDelta(-120);
    final double zoomOutDelta = CanvasViewTransformUtils.wheelScaleDelta(120);
    expect(zoomInDelta, greaterThan(1.0));
    expect(zoomOutDelta, lessThan(1.0));
  });
}

