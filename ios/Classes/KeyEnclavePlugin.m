#import "KeyEnclavePlugin.h"
#if __has_include(<key_enclave/key_enclave-Swift.h>)
#import <key_enclave/key_enclave-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "key_enclave-Swift.h"
#endif

@implementation KeyEnclavePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKeyEnclavePlugin registerWithRegistrar:registrar];
}
@end
