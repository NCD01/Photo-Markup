import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/features/import/utils/load_error_visibility_policy.dart';

void main() {
  group('LoadErrorVisibilityPolicy', () {
    test('shows snack bar when no image is loaded yet', () {
      expect(
        LoadErrorVisibilityPolicy.shouldShowSnackBar(imagePath: null),
        isTrue,
      );
      expect(
        LoadErrorVisibilityPolicy.shouldShowSnackBar(imagePath: '   '),
        isTrue,
      );
    });

    test('shows snack bar when an image is already loaded', () {
      expect(
        LoadErrorVisibilityPolicy.shouldShowSnackBar(
          imagePath: r'C:\photos\drawing.png',
        ),
        isTrue,
      );
    });
  });
}
