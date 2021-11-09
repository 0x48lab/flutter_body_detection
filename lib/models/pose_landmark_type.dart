enum PoseLandmarkType {
  unknown,
  leftAnkle,
  leftEar,
  leftElbow,
  leftEye,
  leftEyeInner,
  leftEyeOuter,
  leftHeel,
  leftHip,
  leftIndexFinger,
  leftKnee,
  leftPinkyFinger,
  leftShoulder,
  leftThumb,
  leftToe,
  leftWrist,
  mouthLeft,
  mouthRight,
  nose,
  rightAnkle,
  rightEar,
  rightElbow,
  rightEye,
  rightEyeInner,
  rightEyeOuter,
  rightHeel,
  rightHip,
  rightIndexFinger,
  rightKnee,
  rightPinkyFinger,
  rightShoulder,
  rightThumb,
  rightToe,
  rightWrist,
}

extension PoseLandmarkTypeExtension on PoseLandmarkType {
  static PoseLandmarkType fromString(String key) {
    switch (key) {
      case "nose":
        return PoseLandmarkType.nose;
      case "leftEyeInner":
        return PoseLandmarkType.leftEyeInner;
      case "leftEye":
        return PoseLandmarkType.leftEye;
      case "leftEyeOuter":
        return PoseLandmarkType.leftEyeOuter;
      case "rightEyeInner":
        return PoseLandmarkType.rightEyeInner;
      case "rightEye":
        return PoseLandmarkType.rightEye;
      case "rightEyeOuter":
        return PoseLandmarkType.rightEyeOuter;
      case "leftEar":
        return PoseLandmarkType.leftEar;
      case "rightEar":
        return PoseLandmarkType.rightEar;
      case "mouthLeft":
        return PoseLandmarkType.mouthLeft;
      case "mouthRight":
        return PoseLandmarkType.mouthRight;
      case "leftShoulder":
        return PoseLandmarkType.leftShoulder;
      case "rightShoulder":
        return PoseLandmarkType.rightShoulder;
      case "leftElbow":
        return PoseLandmarkType.leftElbow;
      case "rightElbow":
        return PoseLandmarkType.rightElbow;
      case "leftWrist":
        return PoseLandmarkType.leftWrist;
      case "rightWrist":
        return PoseLandmarkType.rightWrist;
      case "leftPinkyFinger":
        return PoseLandmarkType.leftPinkyFinger;
      case "rightPinkyFinger":
        return PoseLandmarkType.rightPinkyFinger;
      case "leftIndexFinger":
        return PoseLandmarkType.leftIndexFinger;
      case "rightIndexFinger":
        return PoseLandmarkType.rightIndexFinger;
      case "rightThumb":
        return PoseLandmarkType.rightThumb;
      case "leftThumb":
        return PoseLandmarkType.leftThumb;
      case "leftHip":
        return PoseLandmarkType.leftHip;
      case "rightHip":
        return PoseLandmarkType.rightHip;
      case "leftKnee":
        return PoseLandmarkType.leftKnee;
      case "rightKnee":
        return PoseLandmarkType.rightKnee;
      case "leftAnkle":
        return PoseLandmarkType.leftAnkle;
      case "rightAnkle":
        return PoseLandmarkType.rightAnkle;
      case "leftHeel":
        return PoseLandmarkType.leftHeel;
      case "rightHeel":
        return PoseLandmarkType.rightHeel;
      case "leftToe":
        return PoseLandmarkType.leftToe;
      case "rightToe":
        return PoseLandmarkType.rightToe;
    }
    return PoseLandmarkType.unknown;
  }

  static PoseLandmarkType fromId(int id) {
    switch (id) {
      case 0:
        return PoseLandmarkType.nose;
      case 1:
        return PoseLandmarkType.leftEyeInner;
      case 2:
        return PoseLandmarkType.leftEye;
      case 3:
        return PoseLandmarkType.leftEyeOuter;
      case 4:
        return PoseLandmarkType.rightEyeInner;
      case 5:
        return PoseLandmarkType.rightEye;
      case 6:
        return PoseLandmarkType.rightEyeOuter;
      case 7:
        return PoseLandmarkType.leftEar;
      case 8:
        return PoseLandmarkType.rightEar;
      case 9:
        return PoseLandmarkType.mouthLeft;
      case 10:
        return PoseLandmarkType.mouthRight;
      case 11:
        return PoseLandmarkType.leftShoulder;
      case 12:
        return PoseLandmarkType.rightShoulder;
      case 13:
        return PoseLandmarkType.leftElbow;
      case 14:
        return PoseLandmarkType.rightElbow;
      case 15:
        return PoseLandmarkType.leftWrist;
      case 16:
        return PoseLandmarkType.rightWrist;
      case 17:
        return PoseLandmarkType.leftPinkyFinger;
      case 18:
        return PoseLandmarkType.rightPinkyFinger;
      case 19:
        return PoseLandmarkType.leftIndexFinger;
      case 20:
        return PoseLandmarkType.rightIndexFinger;
      case 21:
        return PoseLandmarkType.leftThumb;
      case 22:
        return PoseLandmarkType.rightThumb;
      case 23:
        return PoseLandmarkType.leftHip;
      case 24:
        return PoseLandmarkType.rightHip;
      case 25:
        return PoseLandmarkType.leftKnee;
      case 26:
        return PoseLandmarkType.rightKnee;
      case 27:
        return PoseLandmarkType.leftAnkle;
      case 28:
        return PoseLandmarkType.rightAnkle;
      case 29:
        return PoseLandmarkType.leftHeel;
      case 30:
        return PoseLandmarkType.rightHeel;
      case 31:
        return PoseLandmarkType.leftToe;
      case 32:
        return PoseLandmarkType.rightToe;
      default:
        return PoseLandmarkType.unknown;
    }
  }

  bool get isLeftSide {
    switch (this) {
      case PoseLandmarkType.leftAnkle:
      case PoseLandmarkType.leftEar:
      case PoseLandmarkType.leftElbow:
      case PoseLandmarkType.leftEye:
      case PoseLandmarkType.leftEyeInner:
      case PoseLandmarkType.leftEyeOuter:
      case PoseLandmarkType.leftHeel:
      case PoseLandmarkType.leftHip:
      case PoseLandmarkType.leftIndexFinger:
      case PoseLandmarkType.leftKnee:
      case PoseLandmarkType.leftPinkyFinger:
      case PoseLandmarkType.leftShoulder:
      case PoseLandmarkType.leftThumb:
      case PoseLandmarkType.leftToe:
      case PoseLandmarkType.leftWrist:
      case PoseLandmarkType.mouthLeft:
        return true;
      default:
        return false;
    }
  }

  bool get isRightSide {
    switch (this) {
      case PoseLandmarkType.rightAnkle:
      case PoseLandmarkType.rightEar:
      case PoseLandmarkType.rightElbow:
      case PoseLandmarkType.rightEye:
      case PoseLandmarkType.rightEyeInner:
      case PoseLandmarkType.rightEyeOuter:
      case PoseLandmarkType.rightHeel:
      case PoseLandmarkType.rightHip:
      case PoseLandmarkType.rightIndexFinger:
      case PoseLandmarkType.rightKnee:
      case PoseLandmarkType.rightPinkyFinger:
      case PoseLandmarkType.rightShoulder:
      case PoseLandmarkType.rightThumb:
      case PoseLandmarkType.rightToe:
      case PoseLandmarkType.rightWrist:
      case PoseLandmarkType.mouthRight:
        return true;
      default:
        return false;
    }
  }
}
