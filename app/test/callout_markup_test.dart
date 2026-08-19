import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/markup/models/callout_markup.dart';

void main() {
  test('numbered pins read as plain numbers', () {
    expect(
      CalloutMarkup.labelForSequence(1, CalloutLabelStyle.numbers),
      '1',
    );
    expect(
      CalloutMarkup.labelForSequence(42, CalloutLabelStyle.numbers),
      '42',
    );
  });

  test('lettered pins run A..Z then AA', () {
    expect(CalloutMarkup.labelForSequence(1, CalloutLabelStyle.letters), 'A');
    expect(CalloutMarkup.labelForSequence(26, CalloutLabelStyle.letters), 'Z');
    expect(CalloutMarkup.labelForSequence(27, CalloutLabelStyle.letters), 'AA');
    expect(CalloutMarkup.labelForSequence(28, CalloutLabelStyle.letters), 'AB');
    expect(CalloutMarkup.labelForSequence(52, CalloutLabelStyle.letters), 'AZ');
    expect(CalloutMarkup.labelForSequence(53, CalloutLabelStyle.letters), 'BA');
  });

  test('a nonsense sequence still produces a label', () {
    expect(CalloutMarkup.labelForSequence(0, CalloutLabelStyle.numbers), '1');
    expect(CalloutMarkup.labelForSequence(-5, CalloutLabelStyle.letters), 'A');
  });

  CalloutMarkup pin(int id, int sequence) => CalloutMarkup(
    id: id,
    anchorNormalized: const Offset(0.5, 0.5),
    sequence: sequence,
  );

  test('the next pin takes the number after the highest in use', () {
    expect(CalloutMarkup.nextSequence(const <CalloutMarkup>[]), 1);
    expect(
      CalloutMarkup.nextSequence(<CalloutMarkup>[pin(1, 1), pin(2, 2)]),
      3,
    );
  });

  test('deleting the last pin gives its number back', () {
    final List<CalloutMarkup> pins = <CalloutMarkup>[
      pin(1, 1),
      pin(2, 2),
      pin(3, 3),
    ];
    pins.removeWhere((CalloutMarkup callout) => callout.sequence == 3);
    expect(CalloutMarkup.nextSequence(pins), 3);
  });

  test('deleting from the middle does not renumber the rest', () {
    final List<CalloutMarkup> pins = <CalloutMarkup>[
      pin(1, 1),
      pin(2, 2),
      pin(3, 3),
    ];
    pins.removeWhere((CalloutMarkup callout) => callout.sequence == 2);
    expect(pins.map((CalloutMarkup c) => c.sequence).toList(), <int>[1, 3]);
    expect(CalloutMarkup.nextSequence(pins), 4);
  });

  test('a pin is hit anywhere inside its circle', () {
    const Rect imageRect = Rect.fromLTWH(0, 0, 1000, 1000);
    const CalloutMarkup callout = CalloutMarkup(
      id: 1,
      anchorNormalized: Offset(0.5, 0.5),
      sequence: 1,
    );
    expect(
      callout.distanceToPointInRect(const Offset(500, 500), imageRect, 1.0),
      0,
    );
    expect(
      callout.distanceToPointInRect(const Offset(508, 500), imageRect, 1.0),
      0,
    );
    expect(
      callout.distanceToPointInRect(const Offset(600, 500), imageRect, 1.0),
      greaterThan(50),
    );
  });

  test('a pin grows with its size setting and with the render scale', () {
    const CalloutMarkup small = CalloutMarkup(
      id: 1,
      anchorNormalized: Offset(0.5, 0.5),
      sequence: 1,
      sizeScale: 0.6,
    );
    const CalloutMarkup large = CalloutMarkup(
      id: 2,
      anchorNormalized: Offset(0.5, 0.5),
      sequence: 2,
      sizeScale: 2.6,
    );
    expect(large.radiusForScale(1), greaterThan(small.radiusForScale(1)));
    expect(
      small.radiusForScale(8),
      closeTo(small.radiusForScale(1) * 8, 0.0001),
    );
  });
}
