import 'package:flutter/material.dart';

void main() {
  runApp(const NcdPhotoMarkupApp());
}

class NcdPhotoMarkupApp extends StatelessWidget {
  const NcdPhotoMarkupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NCD Photo Markup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF009ADA),
      ),
      home: const PhotoMarkupShellScreen(),
    );
  }
}

class PhotoMarkupShellScreen extends StatelessWidget {
  const PhotoMarkupShellScreen({super.key});

  static const Color ncdBlue = Color(0xFF009ADA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ncdBlue,
        foregroundColor: Colors.white,
        title: const Text('NCD Photo Markup'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'v0.2',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ncdBlue, width: 2),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_size_select_actual_outlined,
                            size: 64, color: ncdBlue),
                        SizedBox(height: 16),
                        Text(
                          'Photo Canvas Placeholder',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ncdBlue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Open or import a photo to start marking it up.',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF2FAFE),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final label in const [
                    'Open Photo',
                    'Dimension',
                    'Arrow',
                    'Circle',
                    'Rectangle',
                    'Freehand',
                    'Text',
                    'Erase',
                    'Undo',
                    'Save',
                    'Export',
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _ToolbarPlaceholderButton(label: label),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarPlaceholderButton extends StatelessWidget {
  const _ToolbarPlaceholderButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(116, 56),
          side: const BorderSide(color: PhotoMarkupShellScreen.ncdBlue),
          foregroundColor: Colors.black87,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

