import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

typedef OpenFileCallback = Future<XFile?> Function();

void main() {
  const String startupImagePath =
      String.fromEnvironment('NCD_STARTUP_IMAGE_PATH');
  runApp(NcdPhotoMarkupApp(initialImagePath: startupImagePath));
}

class NcdPhotoMarkupApp extends StatelessWidget {
  const NcdPhotoMarkupApp({
    super.key,
    this.initialImagePath,
    this.openFileOverride,
  });

  final String? initialImagePath;
  final OpenFileCallback? openFileOverride;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NCD Photo Markup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF009ADA),
      ),
      home: PhotoMarkupShellScreen(
        initialImagePath: initialImagePath,
        openFileOverride: openFileOverride,
      ),
    );
  }
}

class PhotoMarkupShellScreen extends StatefulWidget {
  const PhotoMarkupShellScreen({
    super.key,
    this.initialImagePath,
    this.openFileOverride,
  });

  static const Color ncdBlue = Color(0xFF009ADA);
  final String? initialImagePath;
  final OpenFileCallback? openFileOverride;

  @override
  State<PhotoMarkupShellScreen> createState() => _PhotoMarkupShellScreenState();
}

class _PhotoMarkupShellScreenState extends State<PhotoMarkupShellScreen> {
  static const Set<String> _allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  static const XTypeGroup _imageTypeGroup = XTypeGroup(
    label: 'Images',
    extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
  );

  String? _imagePath;
  String? _loadedFileName;
  String? _errorMessage;
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    final String? initialPath = widget.initialImagePath;
    if (initialPath != null && initialPath.isNotEmpty) {
      _loadImageFromPath(initialPath, showErrorForFailure: false);
    }
  }

  Future<void> _openPhoto() async {
    if (_isPickingFile) {
      return;
    }

    setState(() {
      _isPickingFile = true;
      _errorMessage = null;
    });

    try {
      final XFile? selectedFile = widget.openFileOverride != null
          ? await widget.openFileOverride!.call()
          : await openFile(
              acceptedTypeGroups: <XTypeGroup>[_imageTypeGroup],
              confirmButtonText: 'Open Photo',
            );

      if (!mounted) {
        return;
      }

      if (selectedFile == null) {
        setState(() {
          _isPickingFile = false;
        });
        return;
      }

      await _loadImageFromPath(selectedFile.path);
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _setLoadError();
    }
  }

  void _setLoadError() {
    setState(() {
      _errorMessage =
          'Could not open this image. Please choose a JPG or PNG file.';
      _isPickingFile = false;
    });
  }

  String _fileExtension(String path) {
    final List<String> parts = path.split('.');
    if (parts.length < 2) {
      return '';
    }
    return parts.last.toLowerCase();
  }

  String _fileNameFromPath(String path) {
    final String normalized = path.replaceAll('\\', '/');
    final List<String> parts = normalized.split('/');
    return parts.isEmpty ? path : parts.last;
  }

  Future<void> _loadImageFromPath(
    String path, {
    bool showErrorForFailure = true,
  }) async {
    final String extension = _fileExtension(path);
    if (!_allowedExtensions.contains(extension)) {
      if (showErrorForFailure) {
        _setLoadError();
      }
      return;
    }

    final File imageFile = File(path);
    if (!await imageFile.exists()) {
      if (showErrorForFailure) {
        _setLoadError();
      }
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _imagePath = path;
      _loadedFileName = _fileNameFromPath(path);
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PhotoMarkupShellScreen.ncdBlue,
        foregroundColor: Colors.white,
        title: const Text('NCD Photo Markup'),
        actions: [
          if (_loadedFileName != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(
                  child: Text(
                    _loadedFileName!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'v0.3',
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
                  border:
                      Border.all(color: PhotoMarkupShellScreen.ncdBlue, width: 2),
                ),
                child: _buildCanvasContent(),
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
                  for (final String label in const [
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
                      child: _ToolbarPlaceholderButton(
                        label: label,
                        onPressed: label == 'Open Photo' ? _openPhoto : () {},
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasContent() {
    if (_imagePath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_size_select_actual_outlined,
                  size: 64, color: PhotoMarkupShellScreen.ncdBlue),
              const SizedBox(height: 16),
              const Text(
                'Photo Canvas Placeholder',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: PhotoMarkupShellScreen.ncdBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Open or import a photo to start marking it up.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_isPickingFile) ...[
                const SizedBox(height: 14),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Image.file(
                File(_imagePath!),
                fit: BoxFit.contain,
                errorBuilder: (_, Object error, StackTrace? stackTrace) {
                  return const Text(
                    'Could not open this image. Please choose a JPG or PNG file.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFD8E5EB)),
            ),
          ),
          child: Text(
            'Loaded photo: ${_loadedFileName ?? 'Unknown'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ToolbarPlaceholderButton extends StatelessWidget {
  const _ToolbarPlaceholderButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
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

