#import "BodyDetectionPlugin.h"
#if __has_include(<body_detection/body_detection-Swift.h>)
#import <body_detection/body_detection-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "body_detection-Swift.h"
#endif

@implementation BodyDetectionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBodyDetectionPlugin registerWithRegistrar:registrar];
}
@end
