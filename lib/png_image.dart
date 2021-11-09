import 'dart:async';
import 'dart:typed_data';

import 'dart:ui';

import 'package:flutter/widgets.dart';

class PngImage {
  final ByteData bytes;
  final int width;
  final int height;
  PngImage.from(this.bytes, {required this.width, required this.height});
}

extension PngImageExtension on Image {
  Future<PngImage?> toPngImage() async {
    Completer<PngImage> completer = Completer();

    final stream = image.resolve(ImageConfiguration.empty);

    stream.addListener(ImageStreamListener((info, syncCall) async {
      int width = info.image.width;
      int height = info.image.height;
      ByteData? bytes =
          await info.image.toByteData(format: ImageByteFormat.png);
      info.dispose();
      if (bytes == null) {
        completer.completeError("Could not convert image to png format.");
        return;
      }
      final pngImage = PngImage.from(bytes, width: width, height: height);
      completer.complete(pngImage);
    }));

    return completer.future;
  }
}
