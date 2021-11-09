import 'point3d.dart';
import 'pose_landmark_type.dart';

class PoseLandmark {
  final double inFrameLikelihood;
  final Point3d position;
  final PoseLandmarkType type;

  PoseLandmark({
    required this.inFrameLikelihood,
    required this.position,
    required this.type,
  });

  factory PoseLandmark.fromMap(Map<Object?, Object?> map) {
    return PoseLandmark(
      inFrameLikelihood: map['inFrameLikelihood'] as double,
      position: Point3d.fromMap(map['position'] as Map<Object?, Object?>),
      type: PoseLandmarkTypeExtension.fromId(map['type'] as int),
    );
  }
}
