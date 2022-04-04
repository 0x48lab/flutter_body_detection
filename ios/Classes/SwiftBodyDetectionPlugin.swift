import Flutter
import UIKit

public class SwiftBodyDetectionPlugin: NSObject, FlutterPlugin {
    private let serialQueue = DispatchQueue(label: "swiftbodydetectionplugin.serial.queue")
    private var eventSink: FlutterEventSink?
    private var cameraSession: CameraSession?
    private var poseDetectionEnabled = false
    private var bodyMaskDetectionEnabled = false
    private var isUsingFrontCamera = true
    private let poseDetector = MLKitPoseDetector(stream: true)
    private let selfieSegmenter = MLKitSelfieSegmenter()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftBodyDetectionPlugin()
        
        let channel = FlutterMethodChannel(name: "com.0x48lab/body_detection", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "com.0x48lab/body_detection/image_stream", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Note: this method is invoked on the UI thread.
        switch (call.method) {
        
        // Handle detectPose calls.
        case "detectImagePose":
            do {
                // Assume arguments are of dictionary type.
                guard let arguments = call.arguments as? [String : Any] else {
                    throw BodyDetectionPluginError.badArgument("Expected dictionary type.")
                }
                guard let pngBytes = arguments["pngImageBytes"] as? FlutterStandardTypedData else {
                    throw BodyDetectionPluginError.badArgument("pngImageBytes")
                }
                serialQueue.async {
                    do {
                        guard let uiImage = UIImage(data: pngBytes.data) else {
                            throw BodyDetectionPluginError.custom("ConversionError", message: "UIImage could not be created with provided data.")
                        }
                        
                        let detector = MLKitPoseDetector(stream: false)
                        let pose = detector.detectPose(image: uiImage)
                        
                        let resultValue = pose?.toMap()
                        
                        DispatchQueue.main.async {
                            result(resultValue)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            result(error.toFlutterError());
                        }
                    }
                }
            } catch {
                result(error.toFlutterError());
            }
            return
            
        // Handle detectSegmentationMask calls.
        case "detectImageSegmentationMask":
            do {
                // Assume arguments are of dictionary type.
                guard let arguments = call.arguments as? [String : Any] else {
                    throw BodyDetectionPluginError.badArgument("Expected dictionary type.")
                }
                guard let pngBytes = arguments["pngImageBytes"] as? FlutterStandardTypedData else {
                    throw BodyDetectionPluginError.badArgument("pngImageBytes")
                }
                serialQueue.async {
                    do {
                        guard let uiImage = UIImage(data: pngBytes.data) else {
                            throw BodyDetectionPluginError.custom("ConversionError", message: "UIImage could not be created with provided data.")
                        }
                        
                        let segmenter = MLKitSelfieSegmenter()
                        guard let mask = segmenter.detectSegmentationMask(image: uiImage) else {
                            throw BodyDetectionPluginError.custom("SegmentationFailed", message: "Segmentation mask could not be detected.")
                        }
                        
                        let resultValue = mask.toMap()
                        
                        DispatchQueue.main.async {
                            result(resultValue)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            result(error.toFlutterError());
                        }
                    }
                }
            } catch {
                result(error.toFlutterError());
            }
            return
            
        // Handle enablePoseDetection calls.
        case "enablePoseDetection":
            self.poseDetectionEnabled = true
            result(nil)
            return
            
        // Handle disablePoseDetection calls.
        case "disablePoseDetection":
            self.poseDetectionEnabled = false
            result(nil)
            return
            
        // Handle enableSelfieSegmentation calls.
        case "enableBodyMaskDetection":
            self.bodyMaskDetectionEnabled = true
            result(nil)
            return
            
        // Handle disableSelfieSegmentation calls.
        case "disableBodyMaskDetection":
            self.bodyMaskDetectionEnabled = false
            result(nil)
            return
            
        // Handle startCameraStreamPoseDetection calls.
        case "startCameraStream":
            guard self.cameraSession == nil else {
                print("Camera session already active! Call stopCameraStream first and try again.")
                return
            }
            let session = CameraSession(isUsingFrontCamera: isUsingFrontCamera)
            session.start(closure: self.handleCameraFrame)
            self.cameraSession = session
            result(true)
            return
            
        // Handle stopCameraStreamPoseDetection calls.
        case "stopCameraStream":
            guard let session = self.cameraSession else {
                print("Camera session is not active!")
                return
            }
            session.stop()
            self.cameraSession = nil
            result(true)
            return
        case "switchCamera":
            do {
                guard let arguments = call.arguments as? [String : Any] else {
                    throw BodyDetectionPluginError.badArgument("Expected dictionary type.")
                }
                guard let lensFacing = arguments["lensFacing"] as? NSString else {
                    throw BodyDetectionPluginError.badArgument("lensFacing")
                }
                isUsingFrontCamera = lensFacing == "FRONT"
                result(true)
            } catch {
                result(error.toFlutterError());
            }
            return
            
        // Method not implemented.
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleCameraFrame(sampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation) {
        do {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                throw BodyDetectionPluginError.custom("CameraFrame", message: "Failed to get image buffer from sample buffer.")
            }
            
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                return
            }
            
            let rotatedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
            UIGraphicsBeginImageContext(rotatedImage.size)
            rotatedImage.draw(at: .zero)
            let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let portraitImage = fixedImage ?? rotatedImage
            
            guard let eventSink = self.eventSink else {
                return
            }
            
            guard let data = portraitImage.jpegData(compressionQuality: 60),
                  let width = portraitImage.cgImage?.width,
                  let height = portraitImage.cgImage?.height else {
                return
            }
            
            eventSink([
                "type": "image",
                "image": data,
                "width": width,
                "height": height
            ])
            
            if self.poseDetectionEnabled {
                let pose = self.poseDetector.detectPose(image: portraitImage)
                
                eventSink([
                    "type": "pose",
                    "pose": pose?.toMap() as Any
                ])
            }
            
            if self.bodyMaskDetectionEnabled {
                let mask = self.selfieSegmenter.detectSegmentationMask(image: portraitImage)
                
                eventSink([
                    "type": "mask",
                    "mask": mask?.toMap() as Any
                ])
            }
        } catch {
            self.eventSink?(error.toFlutterError())
        }
    }
}

// MARK: FlutterStreamHandler

extension SwiftBodyDetectionPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        
        return nil
    }
}

enum BodyDetectionPluginError: Error {
    case badArgument(_ name: String)
    case custom(_ code: String, message: String?)
}

