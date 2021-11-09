import Foundation
import MLImage
import MLKitVision
import MLKitCommon
import MLKitSegmentationCommon
import MLKitSegmentationSelfie

class MLKitSelfieSegmenter {
    
    private let selfieSegmenter: Segmenter
    private var isWorking = false
    
    init() {
        let options = SelfieSegmenterOptions()
        options.segmenterMode = .singleImage
        options.shouldEnableRawSizeMask = true
        
        self.selfieSegmenter = Segmenter.segmenter(options: options)
    }
    
    func detectSegmentationMask(image: UIImage?) -> SegmentationMask? {
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
            let mask = try self.selfieSegmenter.results(in: inputImage)
            return mask
        } catch let error {
            print("Failed to perform segmentation with error: \(error.localizedDescription).")
            return nil
        }
    }
}
