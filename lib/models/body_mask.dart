import 'dart:typed_data';

class BodyMask {
  final Float64List buffer;
  final int width;
  final int height;

  BodyMask({
    required this.buffer,
    required this.width,
    required this.height,
  });

  factory BodyMask.fromMap(Map<Object?, Object?> map) {
    return BodyMask(
      buffer: map['buffer'] as Float64List,
      width: map['width'] as int,
      height: map['height'] as int,
    );
  }
}
