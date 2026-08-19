import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/core/constants/app_constants.dart';
import 'package:ncd_photo_markup/features/markup/models/arrow_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/dimension_line.dart';
import 'package:ncd_photo_markup/features/markup/models/freehand_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/markup_snapshot.dart';
import 'package:ncd_photo_markup/features/markup/models/oval_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/rectangle_markup.dart';
import 'package:ncd_photo_markup/features/markup/models/text_note_markup.dart';
import 'package:ncd_photo_markup/features/markup/services/markup_history.dart';

MarkupSnapshot snapshotWithLines(int count, {int nextId = 1}) {
  return MarkupSnapshot(
    dimensionLines: <DimensionLine>[
      for (int i = 1; i <= count; i++)
        DimensionLine(
          id: i,
          startNormalized: Offset(0.1 * i, 0.1),
          endNormalized: Offset(0.1 * i, 0.9),
        ),
    ],
    arrows: const <ArrowMarkup>[],
    rectangles: const <RectangleMarkup>[],
    ovals: const <OvalMarkup>[],
    freehands: const <FreehandMarkup>[],
    textNotes: const <TextNoteMarkup>[],
    nextMarkupId: nextId,
  );
}

void main() {
  test('snapshot equality compares contents, not identity', () {
    expect(snapshotWithLines(2), equals(snapshotWithLines(2)));
    expect(snapshotWithLines(2), isNot(equals(snapshotWithLines(3))));
    expect(
      snapshotWithLines(2, nextId: 3),
      isNot(equals(snapshotWithLines(2, nextId: 4))),
    );
  });

  test('snapshot equality covers every markup list', () {
    final MarkupSnapshot base = MarkupSnapshot(
      dimensionLines: const <DimensionLine>[],
      arrows: const <ArrowMarkup>[],
      rectangles: const <RectangleMarkup>[],
      ovals: const <OvalMarkup>[],
      freehands: const <FreehandMarkup>[],
      textNotes: const <TextNoteMarkup>[],
      nextMarkupId: 1,
    );

    expect(
      base,
      isNot(
        equals(
          MarkupSnapshot(
            dimensionLines: const <DimensionLine>[],
            arrows: const <ArrowMarkup>[
              ArrowMarkup(
                id: 1,
                startNormalized: Offset(0.1, 0.1),
                endNormalized: Offset(0.5, 0.5),
              ),
            ],
            rectangles: const <RectangleMarkup>[],
            ovals: const <OvalMarkup>[],
            freehands: const <FreehandMarkup>[],
            textNotes: const <TextNoteMarkup>[],
            nextMarkupId: 1,
          ),
        ),
      ),
    );

    expect(
      base,
      isNot(
        equals(
          MarkupSnapshot(
            dimensionLines: const <DimensionLine>[],
            arrows: const <ArrowMarkup>[],
            rectangles: const <RectangleMarkup>[],
            ovals: const <OvalMarkup>[],
            freehands: <FreehandMarkup>[
              FreehandMarkup(
                id: 1,
                normalizedPoints: const <Offset>[
                  Offset(0.1, 0.1),
                  Offset(0.2, 0.2),
                ],
              ),
            ],
            textNotes: const <TextNoteMarkup>[],
            nextMarkupId: 1,
          ),
        ),
      ),
    );
  });

  test('history starts with nothing to undo or redo', () {
    final MarkupHistory history = MarkupHistory();
    expect(history.canUndo, isFalse);
    expect(history.canRedo, isFalse);
    expect(history.undo(snapshotWithLines(0)), isNull);
    expect(history.redo(snapshotWithLines(0)), isNull);
  });

  test('a no-op edit does not cost an undo step', () {
    final MarkupHistory history = MarkupHistory();
    final bool recorded = history.record(
      snapshotWithLines(1),
      snapshotWithLines(1),
    );
    expect(recorded, isFalse);
    expect(history.canUndo, isFalse);
  });

  test('undo walks back through many steps in order', () {
    final MarkupHistory history = MarkupHistory();
    history.record(snapshotWithLines(0), snapshotWithLines(1));
    history.record(snapshotWithLines(1), snapshotWithLines(2));
    history.record(snapshotWithLines(2), snapshotWithLines(3));

    expect(history.undoDepth, 3);
    expect(history.undo(snapshotWithLines(3)), equals(snapshotWithLines(2)));
    expect(history.undo(snapshotWithLines(2)), equals(snapshotWithLines(1)));
    expect(history.undo(snapshotWithLines(1)), equals(snapshotWithLines(0)));
    expect(history.undo(snapshotWithLines(0)), isNull);
  });

  test('redo replays the undone steps forward', () {
    final MarkupHistory history = MarkupHistory();
    history.record(snapshotWithLines(0), snapshotWithLines(1));
    history.record(snapshotWithLines(1), snapshotWithLines(2));

    expect(history.undo(snapshotWithLines(2)), equals(snapshotWithLines(1)));
    expect(history.undo(snapshotWithLines(1)), equals(snapshotWithLines(0)));
    expect(history.canRedo, isTrue);
    expect(history.redo(snapshotWithLines(0)), equals(snapshotWithLines(1)));
    expect(history.redo(snapshotWithLines(1)), equals(snapshotWithLines(2)));
    expect(history.redo(snapshotWithLines(2)), isNull);
  });

  test('a fresh edit after undo drops the redo branch', () {
    final MarkupHistory history = MarkupHistory();
    history.record(snapshotWithLines(0), snapshotWithLines(1));
    history.undo(snapshotWithLines(1));
    expect(history.canRedo, isTrue);

    history.record(snapshotWithLines(0), snapshotWithLines(5));
    expect(history.canRedo, isFalse);
  });

  test('history is bounded and drops the oldest step first', () {
    final MarkupHistory history = MarkupHistory();
    for (int i = 0; i < MarkupHistoryConstants.maxSteps + 12; i++) {
      history.record(
        snapshotWithLines(0, nextId: i),
        snapshotWithLines(0, nextId: i + 1),
      );
    }
    expect(history.undoDepth, MarkupHistoryConstants.maxSteps);
  });

  test('clear drops both stacks', () {
    final MarkupHistory history = MarkupHistory();
    history.record(snapshotWithLines(0), snapshotWithLines(1));
    history.undo(snapshotWithLines(1));
    history.clear();
    expect(history.canUndo, isFalse);
    expect(history.canRedo, isFalse);
  });
}
