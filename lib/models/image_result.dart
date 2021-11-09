import 'dart:typed_data';

import 'dart:ui';

class ImageResult {
  final Uint8List bytes;
  final Size size;

  ImageResult({
    required this.bytes,
    required this.size,
  });

  factory ImageResult.fromMap(Map<dynamic, dynamic> map) => ImageResult(
      bytes: map['image'],
      size: map['width'] != 0 && map['height'] != 0
          ? Size(map['width'].toDouble(), map['height'].toDouble())
          : Size.zero);
}
