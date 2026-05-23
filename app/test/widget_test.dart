import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_photo_markup/main.dart';

void main() {
  testWidgets('renders shell empty-state text and open-photo action',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NcdPhotoMarkupApp());

    expect(find.text('NCD Photo Markup'), findsOneWidget);
    expect(find.text('Open or import a photo to start marking it up.'),
        findsOneWidget);
    expect(find.text('Open Photo'), findsOneWidget);
  });
}
