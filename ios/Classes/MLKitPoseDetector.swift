import Foundation
import MLImage
import MLKitVision
import MLKitCommon
import MLKitPoseDetectionCommon
import MLKitPoseDetection
import MLKitPoseDetectionAccurate

class MLKitPoseDetector {
    private let poseDetector: PoseDetector
    private var isWorking = false
    
    init(stream: Bool) {
        let options = AccuratePoseDetectorOptions()
        if stream {
            options.detectorMode = .stream
        }
        options.detectorMode = .singleImage
        self.poseDetector = PoseDetector.poseDetector(options: options)
    }
    
    func detectPose(image: UIImage?) -> Pose? {
        guard let image = image else { return nil }
        
        guard let inputImage = MLImage(image: image) else {
            print("Failed to create MLImage from UIImage.")
            return nil
        }
        inputImage.orientation = image.imageOrientation
        
        guard !self.isWorking else { return nil }
        self.isWorking = true
        defer {
            self.isWorking = false
        }
        
        do {
            let poses = try poseDetector.results(in: inputImage)
            return poses.first
        } catch let error {
            print("Failed to detect poses with error: \(error.localizedDescription).")
            return nil
        }
    }
}
