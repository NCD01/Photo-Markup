import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/export/services/full_resolution_export_service.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/blur_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_style_preset.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/rendering/markup_scene_renderer.dart';

/// A plain white source photo of a given pixel size.
Future<ui.Image> whiteImage(int width, int height) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(width, height);
  picture.dispose();
  return image;
}

class DecodedPng {
  const DecodedPng(this.width, this.height, this.pixels);

  final int width;
  final int height;
  final ByteData pixels;

  int alphaAt(int x, int y) => pixels.getUint8(((y * width) + x) * 4 + 3);

  /// 0 for black, 255 for white, on a greyscale-ish read of the red channel.
  int redAt(int x, int y) => pixels.getUint8(((y * width) + x) * 4);
}

Future<DecodedPng> readPng(String path) async {
  final Uint8List bytes = await File(path).readAsBytes();
  final ui.Codec codec = await ui.instantiateImageCodec(bytes);
  final ui.FrameInfo frame = await codec.getNextFrame();
  final ByteData? raw = await frame.image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );
  final DecodedPng decoded = DecodedPng(
    frame.image.width,
    frame.image.height,
    raw!,
  );
  frame.image.dispose();
  codec.dispose();
  return decoded;
}

MarkupScene sceneWith({
  List<RectangleMarkup> rectangles = const <RectangleMarkup>[],
  List<ArrowMarkup> arrows = const <ArrowMarkup>[],
  List<DimensionLine> lines = const <DimensionLine>[],
  List<OvalMarkup> ovals = const <OvalMarkup>[],
  List<FreehandMarkup> freehands = const <FreehandMarkup>[],
  List<TextNoteMarkup> textNotes = const <TextNoteMarkup>[],
  List<CalloutMarkup> callouts = const <CalloutMarkup>[],
  List<BlurMarkup> blurs = const <BlurMarkup>[],
  int? selectedRectangleId,
}) {
  return MarkupScene(
    lines: lines,
    arrows: arrows,
    rectangles: rectangles,
    ovals: ovals,
    freehands: freehands,
    textNotes: textNotes,
    callouts: callouts,
    blurs: blurs,
    selectedRectangleId: selectedRectangleId,
  );
}

/// A source photo with hard vertical black and white stripes, so a blur is
/// obvious: blurred stripes average out to grey.
Future<ui.Image> stripedImage(int width, int height, int stripeWidth) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  for (int x = 0; x < width; x += stripeWidth) {
    canvas.drawRect(
      Rect.fromLTWH(x.toDouble(), 0, stripeWidth.toDouble(), height.toDouble()),
      Paint()
        ..color = ((x ~/ stripeWidth).isEven)
            ? const Color(0xFF000000)
            : const Color(0xFFFFFFFF),
    );
  }
  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(width, height);
  picture.dispose();
  return image;
}

void main() {
  late Directory outputDir;

  setUp(() {
    outputDir = Directory.systemTemp.createTempSync('ncd_export_test');
  });

  tearDown(() {
    if (outputDir.existsSync()) {
      outputDir.deleteSync(recursive: true);
    }
  });

  test('the markup scale is the ratio of export width to on-screen width', () {
    expect(
      FullResolutionExportService.markupScaleFor(
        exportWidth: 6000,
        displayWidth: 750,
      ),
      8.0,
    );
    expect(
      FullResolutionExportService.markupScaleFor(
        exportWidth: 800,
        displayWidth: 800,
      ),
      1.0,
    );
    // Degenerate inputs fall back to 1 rather than producing infinity.
    expect(
      FullResolutionExportService.markupScaleFor(
        exportWidth: 6000,
        displayWidth: 0,
      ),
      1.0,
    );
  });

  test('export writes the photo at its own pixel size, not the canvas size', () async {
    final ui.Image source = await whiteImage(3000, 2000);
    final String path = '${outputDir.path}/full_res.png';

    final FullResolutionExportResult result =
        await FullResolutionExportService.renderToPng(
          sourceImage: source,
          scene: sceneWith(),
          // The canvas on screen was only 600pt wide.
          displayImageRect: const Rect.fromLTWH(12, 40, 600, 400),
          outputPath: path,
        );
    source.dispose();

    expect(result.pixelWidth, 3000);
    expect(result.pixelHeight, 2000);
    expect(result.markupScale, 5.0);

    final DecodedPng decoded = await readPng(path);
    expect(decoded.width, 3000);
    expect(decoded.height, 2000);
  });

  test('a portrait photo exports portrait, at full size', () async {
    final ui.Image source = await whiteImage(1200, 1600);
    final String path = '${outputDir.path}/portrait.png';

    final FullResolutionExportResult result =
        await FullResolutionExportService.renderToPng(
          sourceImage: source,
          scene: sceneWith(),
          displayImageRect: const Rect.fromLTWH(0, 0, 300, 400),
          outputPath: path,
        );
    source.dispose();

    expect(result.pixelWidth, 1200);
    expect(result.pixelHeight, 1600);
    final DecodedPng decoded = await readPng(path);
    expect(decoded.width, 1200);
    expect(decoded.height, 1600);
  });

  test('annotations land on the same part of the photo they did on screen', () async {
    final ui.Image source = await whiteImage(2000, 1000);
    final String path = '${outputDir.path}/placement.png';

    // A filled black box covering the middle half of the photo.
    await FullResolutionExportService.renderToPng(
      sourceImage: source,
      scene: sceneWith(
        rectangles: const <RectangleMarkup>[
          RectangleMarkup(
            id: 1,
            startNormalized: Offset(0.25, 0.25),
            endNormalized: Offset(0.75, 0.75),
            stylePresetId: MarkupStylePresetId.black,
            filled: true,
          ),
        ],
      ),
      displayImageRect: const Rect.fromLTWH(0, 0, 500, 250),
      outputPath: path,
    );
    source.dispose();

    final DecodedPng decoded = await readPng(path);
    // Centre of the photo is inside the box, so it is darkened.
    expect(decoded.redAt(1000, 500), lessThan(200));
    // Well outside the box the photo is untouched white.
    expect(decoded.redAt(100, 100), greaterThan(240));
    expect(decoded.redAt(1900, 900), greaterThan(240));
    // Just inside the top-left corner of the box is darkened; just outside is not.
    expect(decoded.redAt(520, 260), lessThan(240));
    expect(decoded.redAt(460, 200), greaterThan(240));
  });

  test('annotation weight scales with the photo instead of staying hairline', () async {
    final String thinPath = '${outputDir.path}/small.png';
    final String widePath = '${outputDir.path}/large.png';
    const MarkupScene scene = MarkupScene(
      lines: <DimensionLine>[],
      arrows: <ArrowMarkup>[
        ArrowMarkup(
          id: 1,
          startNormalized: Offset(0.1, 0.5),
          endNormalized: Offset(0.9, 0.5),
          stylePresetId: MarkupStylePresetId.black,
        ),
      ],
      rectangles: <RectangleMarkup>[],
      ovals: <OvalMarkup>[],
      freehands: <FreehandMarkup>[],
      textNotes: <TextNoteMarkup>[],
    );

    final ui.Image small = await whiteImage(500, 250);
    await FullResolutionExportService.renderToPng(
      sourceImage: small,
      scene: scene,
      displayImageRect: const Rect.fromLTWH(0, 0, 500, 250),
      outputPath: thinPath,
    );
    small.dispose();

    final ui.Image large = await whiteImage(4000, 2000);
    await FullResolutionExportService.renderToPng(
      sourceImage: large,
      scene: scene,
      displayImageRect: const Rect.fromLTWH(0, 0, 500, 250),
      outputPath: widePath,
    );
    large.dispose();

    final DecodedPng smallPng = await readPng(thinPath);
    final DecodedPng largePng = await readPng(widePath);

    int darkRowHeight(DecodedPng png, int column) {
      int count = 0;
      for (int y = 0; y < png.height; y++) {
        if (png.redAt(column, y) < 160) {
          count++;
        }
      }
      return count;
    }

    final int smallThickness = darkRowHeight(smallPng, 250);
    final int largeThickness = darkRowHeight(largePng, 2000);
    expect(smallThickness, greaterThan(0));
    // 8x the photo width means roughly 8x the line thickness in pixels.
    expect(largeThickness, greaterThan(smallThickness * 5));
  });

  test('selection handles are never baked into the export', () async {
    final String withSelection = '${outputDir.path}/selected.png';
    final String withoutSelection = '${outputDir.path}/unselected.png';
    const RectangleMarkup rectangle = RectangleMarkup(
      id: 7,
      startNormalized: Offset(0.3, 0.3),
      endNormalized: Offset(0.7, 0.7),
      stylePresetId: MarkupStylePresetId.black,
    );

    final ui.Image a = await whiteImage(800, 600);
    await FullResolutionExportService.renderToPng(
      sourceImage: a,
      scene: sceneWith(
        rectangles: const <RectangleMarkup>[rectangle],
        selectedRectangleId: 7,
      ),
      displayImageRect: const Rect.fromLTWH(0, 0, 800, 600),
      outputPath: withSelection,
    );
    a.dispose();

    final ui.Image b = await whiteImage(800, 600);
    await FullResolutionExportService.renderToPng(
      sourceImage: b,
      scene: sceneWith(rectangles: const <RectangleMarkup>[rectangle]),
      displayImageRect: const Rect.fromLTWH(0, 0, 800, 600),
      outputPath: withoutSelection,
    );
    b.dispose();

    final Uint8List selectedBytes = await File(withSelection).readAsBytes();
    final Uint8List plainBytes = await File(withoutSelection).readAsBytes();
    expect(selectedBytes.length, plainBytes.length);
  });

  test('decoding a real photo file reports its true pixel size', () async {
    // Write a PNG, then decode it back through the same path export uses.
    final ui.Image source = await whiteImage(1234, 567);
    final ByteData? encoded = await source.toByteData(
      format: ui.ImageByteFormat.png,
    );
    source.dispose();
    final String path = '${outputDir.path}/source.png';
    await File(path).writeAsBytes(encoded!.buffer.asUint8List());

    final ui.Image decoded = await FullResolutionExportService.decodeImageFile(
      path,
    );
    expect(decoded.width, 1234);
    expect(decoded.height, 567);
    decoded.dispose();
  });

  test('a blur region actually destroys detail in the exported pixels', () async {
    final ui.Image source = await stripedImage(1200, 600, 20);
    final String path = '${outputDir.path}/blurred.png';

    await FullResolutionExportService.renderToPng(
      sourceImage: source,
      scene: sceneWith(
        blurs: const <BlurMarkup>[
          // Covers the left half of the photo.
          BlurMarkup(
            id: 1,
            startNormalized: Offset(0.0, 0.0),
            endNormalized: Offset(0.5, 1.0),
            strengthScale: 2.6,
          ),
        ],
      ),
      displayImageRect: const Rect.fromLTWH(0, 0, 600, 300),
      outputPath: path,
    );
    source.dispose();

    final DecodedPng decoded = await readPng(path);

    int spread(int fromX, int toX, int y) {
      int lowest = 255;
      int highest = 0;
      for (int x = fromX; x < toX; x++) {
        final int value = decoded.redAt(x, y);
        lowest = value < lowest ? value : lowest;
        highest = value > highest ? value : highest;
      }
      return highest - lowest;
    }

    // Untouched half still swings the full black-to-white range.
    expect(spread(700, 1100, 300), greaterThan(200));
    // Blurred half has had that contrast averaged away.
    expect(spread(100, 500, 300), lessThan(120));
  });

  test('blur strength scales up with the export so a face stays hidden', () async {
    final String path = '${outputDir.path}/blur_big.png';
    final ui.Image source = await stripedImage(4000, 2000, 60);

    await FullResolutionExportService.renderToPng(
      sourceImage: source,
      scene: sceneWith(
        blurs: const <BlurMarkup>[
          BlurMarkup(
            id: 1,
            startNormalized: Offset(0.1, 0.1),
            endNormalized: Offset(0.6, 0.9),
            strengthScale: 2.6,
          ),
        ],
      ),
      // On screen the photo was only 500pt wide, an 8x scale up.
      displayImageRect: const Rect.fromLTWH(0, 0, 500, 250),
      outputPath: path,
    );
    source.dispose();

    final DecodedPng decoded = await readPng(path);
    int lowest = 255;
    int highest = 0;
    for (int x = 800; x < 2200; x++) {
      final int value = decoded.redAt(x, 1000);
      lowest = value < lowest ? value : lowest;
      highest = value > highest ? value : highest;
    }
    expect(highest - lowest, lessThan(140));
  });

  test('callout pins are drawn into the export', () async {
    final String withPin = '${outputDir.path}/with_pin.png';
    final ui.Image source = await whiteImage(1000, 1000);

    await FullResolutionExportService.renderToPng(
      sourceImage: source,
      scene: sceneWith(
        callouts: const <CalloutMarkup>[
          CalloutMarkup(
            id: 1,
            anchorNormalized: Offset(0.5, 0.5),
            sequence: 1,
            stylePresetId: MarkupStylePresetId.black,
          ),
        ],
      ),
      displayImageRect: const Rect.fromLTWH(0, 0, 500, 500),
      outputPath: withPin,
    );
    source.dispose();

    final DecodedPng decoded = await readPng(withPin);
    // The pin body sits on the middle of the photo. Sample beside the digit
    // so the reading is the pin fill, not the glyph.
    expect(decoded.redAt(478, 500), lessThan(200));
    // Away from the pin the photo is untouched.
    expect(decoded.redAt(100, 100), greaterThan(240));
  });

  test('a rotated photo exports with its axes swapped', () async {
    final ui.Image source = await whiteImage(2000, 1000);
    final String path = '${outputDir.path}/rotated.png';

    final FullResolutionExportResult result =
        await FullResolutionExportService.renderToPng(
          sourceImage: source,
          scene: sceneWith(),
          displayImageRect: const Rect.fromLTWH(0, 0, 500, 1000),
          outputPath: path,
          quarterTurns: 1,
        );
    source.dispose();

    expect(result.pixelWidth, 1000);
    expect(result.pixelHeight, 2000);
    final DecodedPng decoded = await readPng(path);
    expect(decoded.width, 1000);
    expect(decoded.height, 2000);
  });

  test('a half turn keeps the axes and moves the photo content', () async {
    final ui.Image source = await stripedImage(800, 400, 100);
    final String upright = '${outputDir.path}/upright.png';
    final String flipped = '${outputDir.path}/flipped.png';

    await FullResolutionExportService.renderToPng(
      sourceImage: source,
      scene: sceneWith(),
      displayImageRect: const Rect.fromLTWH(0, 0, 800, 400),
      outputPath: upright,
    );
    await FullResolutionExportService.renderToPng(
      sourceImage: source,
      scene: sceneWith(),
      displayImageRect: const Rect.fromLTWH(0, 0, 800, 400),
      outputPath: flipped,
      quarterTurns: 2,
    );
    source.dispose();

    final DecodedPng a = await readPng(upright);
    final DecodedPng b = await readPng(flipped);
    expect(a.width, b.width);
    expect(a.height, b.height);
    // 800 wide with 100px stripes is 8 stripes, an even count, so a half turn
    // swaps black for white at the same column.
    expect((a.redAt(50, 200) - b.redAt(50, 200)).abs(), greaterThan(200));
  });

  test('markup on a rotated photo lands in the rotated frame', () async {
    final ui.Image source = await whiteImage(2000, 1000);
    final String path = '${outputDir.path}/rotated_markup.png';

    await FullResolutionExportService.renderToPng(
      sourceImage: source,
      scene: sceneWith(
        rectangles: const <RectangleMarkup>[
          // Top-left quarter of the rotated (1000x2000) frame.
          RectangleMarkup(
            id: 1,
            startNormalized: Offset(0.05, 0.05),
            endNormalized: Offset(0.45, 0.2),
            stylePresetId: MarkupStylePresetId.black,
            filled: true,
          ),
        ],
      ),
      displayImageRect: const Rect.fromLTWH(0, 0, 500, 1000),
      outputPath: path,
      quarterTurns: 1,
    );
    source.dispose();

    final DecodedPng decoded = await readPng(path);
    expect(decoded.width, 1000);
    expect(decoded.height, 2000);
    // Inside the box, in rotated-frame pixels.
    expect(decoded.redAt(250, 250), lessThan(200));
    // Outside it.
    expect(decoded.redAt(800, 1500), greaterThan(240));
  });
}
