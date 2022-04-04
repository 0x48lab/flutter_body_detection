import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'body_detection_exception.dart';
import 'models/image_result.dart';
import 'models/pose.dart';
import 'models/body_mask.dart';
import 'png_image.dart';
import 'types.dart';

enum LensFacing {
  front,
  back,
}

class BodyDetection {
  static const MethodChannel _channel =
      MethodChannel('com.0x48lab/body_detection');
  static const EventChannel _eventChannel =
      EventChannel('com.0x48lab/body_detection/image_stream');

  static StreamSubscription<dynamic>? _imageStreamSubscription;

  // Image

  static Future<Pose?> detectPose({required PngImage image}) async {
    final Uint8List pngImageBytes = image.bytes.buffer.asUint8List();
    try {
      final result = await _channel.invokeMapMethod(
        'detectImagePose',
        <String, dynamic>{
          'pngImageBytes': pngImageBytes,
        },
      );
      return result == null ? null : Pose.fromMap(result);
    } on PlatformException catch (e) {
      throw BodyDetectionException(e.code, e.message);
    }
  }

  static Future<BodyMask?> detectBodyMask({required PngImage image}) async {
    final Uint8List pngImageBytes = image.bytes.buffer.asUint8List();
    try {
      final result = await _channel.invokeMapMethod(
        'detectImageSegmentationMask',
        <String, dynamic>{
          'pngImageBytes': pngImageBytes,
        },
      );
      return result == null ? null : BodyMask.fromMap(result);
    } on PlatformException catch (e) {
      throw BodyDetectionException(e.code, e.message);
    }
  }

  // Camera

  static Future<void> startCameraStream({
    ImageCallback? onFrameAvailable,
    PoseCallback? onPoseAvailable,
    BodyMaskCallback? onMaskAvailable,
  }) async {
    try {
      await _channel.invokeMethod<void>('startCameraStream');

      _imageStreamSubscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic result) {
          final type = result['type'];
          // Camera image
          if (type == 'image' && onFrameAvailable != null) {
            onFrameAvailable(
              ImageResult.fromMap(result),
            );
          }
          // Pose detection result
          else if (type == 'pose' && onPoseAvailable != null) {
            onPoseAvailable(
              result['pose'] == null ? null : Pose.fromMap(result['pose']),
            );
          }
          // Selfie segmentation result
          else if (type == 'mask' && onMaskAvailable != null) {
            onMaskAvailable(
              result['mask'] == null ? null : BodyMask.fromMap(result['mask']),
            );
          }
        },
      );
    } on PlatformException catch (e) {
      throw BodyDetectionException(e.code, e.message);
    }
  }

  static Future<void> stopCameraStream() async {
    try {
      await _imageStreamSubscription?.cancel();
      _imageStreamSubscription = null;

      await _channel.invokeMethod<void>('stopCameraStream');
    } on PlatformException catch (e) {
      throw BodyDetectionException(e.code, e.message);
    }
  }

  static Future<void> switchCamera(LensFacing facing) async {
    try {
      await _channel.invokeMethod<void>('switchCamera', <String, dynamic>{
        'lensFacing': facing == LensFacing.front ? "FRONT" : "BACK",
      });
    } on PlatformException catch (e) {
      throw BodyDetectionException(e.code, e.message);
    }
  }

  static Future<void> enablePoseDetection() async {
    try {
      await _channel.invokeMethod<void>('enablePoseDetection');
    } on PlatformException catch (e) {
      throw BodyDetectionException(e.code, e.message);
    }
  }

  static Future<void> disablePoseDetection() async {
    try {
      await _channel.invokeMethod<void>('disablePoseDetection');
    } on PlatformException catch (e) {
      throw BodyDetectionException(e.code, e.message);
    }
  }

  static Future<void> enableBodyMaskDetection() async {
    try {
      await _channel.invokeMethod<void>('enableBodyMaskDetection');
    } on PlatformException catch (e) {
      throw BodyDetectionException(e.code, e.message);
    }
  }

  static Future<void> disableBodyMaskDetection() async {
    try {
      await _channel.invokeMethod<void>('disableBodyMaskDetection');
    } on PlatformException catch (e) {
      throw BodyDetectionException(e.code, e.message);
    }
  }
}
