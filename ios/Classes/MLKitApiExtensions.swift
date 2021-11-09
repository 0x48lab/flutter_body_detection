import Foundation
import MLKitPoseDetectionCommon
import MLKitVision
import MLKitCommon
import MLKitSegmentationCommon

// MARK: - Pose-related extensions

extension Pose {
    func toMap() -> Dictionary<String, Any> {
        return [
            "landmarks": self.landmarks.map { $0.toMap() }
        ]
    }
}

extension PoseLandmark {
    func toMap() -> Dictionary<String, Any> {
        return [
            "inFrameLikelihood": Double(self.inFrameLikelihood),
            "position": self.position.toMap(),
            "type": self.type.toInt()
        ]
    }
}

extension PoseLandmarkType {
    // This follows constants from Android's com.google.mlkit.vision.pose.PoseLandmark class.
    func toInt() -> Int {
        switch self {
        case .leftAnkle: return 27
        case .leftEar: return 7
        case .leftElbow: return 13
        case .leftEye: return 2
        case .leftEyeInner: return 1
        case .leftEyeOuter: return 3
        case .leftHeel: return 29
        case .leftHip: return 23
        case .leftIndexFinger: return 19
        case .leftKnee: return 25
        case .leftPinkyFinger: return 17
        case .leftShoulder: return 11
        case .leftThumb: return 21
        case .leftToe: return 31
        case .leftWrist: return 15
        case .mouthLeft: return 9
        case .mouthRight: return 10
        case .nose: return 0
        case .rightAnkle: return 28
        case .rightEar: return 8
        case .rightElbow: return 14
        case .rightEye: return 5
        case .rightEyeInner: return 4
        case .rightEyeOuter: return 6
        case .rightHeel: return 30
        case .rightHip: return 24
        case .rightIndexFinger: return 20
        case .rightKnee: return 26
        case .rightPinkyFinger: return 18
        case .rightShoulder: return 12
        case .rightThumb: return 22
        case .rightToe: return 32
        case .rightWrist: return 16
        default: return -1
        }
    }
}

// MARK: - Segmentation mask-related extensions

extension SegmentationMask {
    func toMap() -> Dictionary<String, Any> {
        let maskWidth = CVPixelBufferGetWidth(self.buffer)
        let maskHeight = CVPixelBufferGetHeight(self.buffer)

        CVPixelBufferLockBaseAddress(self.buffer, CVPixelBufferLockFlags.readOnly)
        let maskBytesPerRow = CVPixelBufferGetBytesPerRow(self.buffer)
        var maskAddress =
            CVPixelBufferGetBaseAddress(self.buffer)!.bindMemory(
                to: Float32.self, capacity: maskBytesPerRow * maskHeight)

        var floatArray: [Double] = []
        for _ in 0...(maskHeight - 1) {
          for col in 0...(maskWidth - 1) {
            // Gets the confidence of the pixel in the mask being in the foreground.
            let foregroundConfidence: Float32 = maskAddress[col]
            floatArray.append(Double(foregroundConfidence))
          }
          maskAddress += maskBytesPerRow / MemoryLayout<Float32>.size
        }
        let data = Data(bytes: &floatArray, count: floatArray.count * MemoryLayout<Double>.stride)
        
        return [
            "buffer": FlutterStandardTypedData(float64: data),
            "width": maskWidth,
            "height": maskHeight
        ]
    }
}

// MARK: - Other extensions

extension Vision3DPoint {
    func toMap() -> Dictionary<String, Any> {
        return [
            "x": Double(self.x),
            "y": Double(self.y),
            "z": Double(self.z)
        ]
    }
}

extension Error {
    func toFlutterError() -> FlutterError {
        if let error = self as? BodyDetectionPluginError {
            switch error {
            case .badArgument(let name):
                return FlutterError(code: "ArgumentError", message: "Invalid argument: \(name).", details: nil);
            case .custom(let code, let message):
                return FlutterError(code: code, message: message, details: nil);
            }
        }
        return FlutterError(code: self.localizedDescription, message: self.localizedDescription, details: nil);
    }
}
