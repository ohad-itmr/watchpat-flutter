#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* watchPatChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"watchpat"
                                            binaryMessenger:controller];
    
    __weak typeof(self) weakSelf = self;
    [watchPatChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"getFreeSpace" isEqualToString:call.method]) {
            int freeSpace = [weakSelf freeDiskspace];
            result(@(freeSpace));
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    
    UIApplication.sharedApplication.statusBarHidden = false;
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (int)freeDiskspace {
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@", [error domain]);
    }
    
    return (totalFreeSpace/1024ll)/1024ll;
}

@end
