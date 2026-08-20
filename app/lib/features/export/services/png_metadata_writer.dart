import 'dart:convert';
import 'dart:typed_data';

/// Writes plain-text metadata into a PNG file that has already been encoded.
///
/// PNG carries text in `tEXt` chunks: a Latin-1 keyword, a zero byte, then a
/// Latin-1 value. Anything that reads PNG properly, which includes Windows
/// Explorer's details pane, ImageMagick and ExifTool, will read them back.
///
/// Flutter's encoder gives no way to add chunks, so this rebuilds the byte
/// stream: signature, IHDR, the new chunks, then everything else exactly as it
/// was. The pixels are not touched, decoded or re-encoded, so a stamped export
/// is the same image it was before stamping.
class PngMetadataWriter {
  const PngMetadataWriter._();

  static const List<int> _signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
  static const int _chunkTypeLength = 4;
  static const int _lengthFieldLength = 4;
  static const int _crcLength = 4;

  /// The longest a PNG keyword may be, by the format specification.
  static const int maxKeywordLength = 79;

  /// Returns [pngBytes] with a `tEXt` chunk for every entry in [fields].
  ///
  /// Entries with an empty keyword or an empty value are skipped rather than
  /// written blank, because a metadata field that is present but says nothing
  /// is worse than an absent one. Bytes that are not valid PNG are returned
  /// unchanged: an export that lost its metadata is a nuisance, an export that
  /// is now a corrupt file is a disaster.
  static Uint8List withTextFields(
    Uint8List pngBytes,
    Map<String, String> fields,
  ) {
    if (!isPng(pngBytes) || fields.isEmpty) {
      return pngBytes;
    }

    final int? headerEnd = _endOfFirstChunk(pngBytes);
    if (headerEnd == null || headerEnd <= 0) {
      return pngBytes;
    }

    final BytesBuilder builder = BytesBuilder(copy: false)
      ..add(pngBytes.sublist(0, headerEnd));
    fields.forEach((String keyword, String value) {
      final Uint8List? chunk = _textChunk(keyword, value);
      if (chunk != null) {
        builder.add(chunk);
      }
    });
    builder.add(pngBytes.sublist(headerEnd));
    return builder.toBytes();
  }

  /// Reads every `tEXt` chunk back out, which is what the tests assert on.
  static Map<String, String> readTextFields(Uint8List pngBytes) {
    final Map<String, String> fields = <String, String>{};
    if (!isPng(pngBytes)) {
      return fields;
    }

    int offset = _signature.length;
    while (offset + _lengthFieldLength + _chunkTypeLength <= pngBytes.length) {
      final int length = _readUint32(pngBytes, offset);
      final int typeStart = offset + _lengthFieldLength;
      final int dataStart = typeStart + _chunkTypeLength;
      if (dataStart + length + _crcLength > pngBytes.length) {
        break;
      }
      final String type = latin1.decode(
        pngBytes.sublist(typeStart, dataStart),
        allowInvalid: true,
      );
      if (type == 'tEXt') {
        final Uint8List data = pngBytes.sublist(dataStart, dataStart + length);
        final int separator = data.indexOf(0);
        if (separator > 0) {
          fields[latin1.decode(data.sublist(0, separator), allowInvalid: true)] =
              latin1.decode(data.sublist(separator + 1), allowInvalid: true);
        }
      }
      if (type == 'IEND') {
        break;
      }
      offset = dataStart + length + _crcLength;
    }
    return fields;
  }

  static bool isPng(Uint8List bytes) {
    if (bytes.length < _signature.length) {
      return false;
    }
    for (int i = 0; i < _signature.length; i++) {
      if (bytes[i] != _signature[i]) {
        return false;
      }
    }
    return true;
  }

  /// Where IHDR ends, which is where new chunks are allowed to start.
  static int? _endOfFirstChunk(Uint8List bytes) {
    final int lengthAt = _signature.length;
    if (lengthAt + _lengthFieldLength + _chunkTypeLength > bytes.length) {
      return null;
    }
    final int length = _readUint32(bytes, lengthAt);
    final int end =
        lengthAt + _lengthFieldLength + _chunkTypeLength + length + _crcLength;
    return end <= bytes.length ? end : null;
  }

  static Uint8List? _textChunk(String keyword, String value) {
    final String trimmedKeyword = keyword.trim();
    final String trimmedValue = value.trim();
    if (trimmedKeyword.isEmpty || trimmedValue.isEmpty) {
      return null;
    }

    final List<int> keywordBytes = _toLatin1(
      trimmedKeyword,
    ).take(maxKeywordLength).toList();
    final List<int> valueBytes = _toLatin1(trimmedValue);
    final Uint8List data = Uint8List.fromList(<int>[
      ...keywordBytes,
      0,
      ...valueBytes,
    ]);

    final Uint8List typeAndData = Uint8List.fromList(<int>[
      ...latin1.encode('tEXt'),
      ...data,
    ]);

    final BytesBuilder chunk = BytesBuilder(copy: false)
      ..add(_uint32(data.length))
      ..add(typeAndData)
      ..add(_uint32(_crc32(typeAndData)));
    return chunk.toBytes();
  }

  /// PNG text is Latin-1. Anything outside it becomes a question mark rather
  /// than being dropped, so a name with an accent still reads as a name.
  static List<int> _toLatin1(String value) {
    return <int>[
      for (final int rune in value.runes) rune <= 0xFF ? rune : 0x3F,
    ];
  }

  static int _readUint32(Uint8List bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  static Uint8List _uint32(int value) {
    return Uint8List.fromList(<int>[
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ]);
  }

  static final List<int> _crcTable = _buildCrcTable();

  static List<int> _buildCrcTable() {
    return <int>[
      for (int n = 0; n < 256; n++) _crcTableEntry(n),
    ];
  }

  static int _crcTableEntry(int n) {
    int c = n;
    for (int k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
    }
    return c;
  }

  static int _crc32(List<int> bytes) {
    int c = 0xFFFFFFFF;
    for (final int byte in bytes) {
      c = _crcTable[(c ^ byte) & 0xFF] ^ (c >> 8);
    }
    return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }
}
