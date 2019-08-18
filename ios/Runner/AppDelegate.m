#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

static FlutterMethodChannel *channel = nil;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setUncaughtExceptionHandler];
    [self setSignalHandler];
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* watchPatChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"watchpat"
                                            binaryMessenger:controller];
    channel = watchPatChannel;
    
    __weak typeof(self) weakSelf = self;
    [watchPatChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"getFreeSpace" isEqualToString:call.method]) {
            int freeSpace = [weakSelf freeDiskspace];
            result(@(freeSpace));
        } else if ([@"crashApplication" isEqualToString:call.method]) {
            @throw NSInternalInconsistencyException;
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    
    UIApplication.sharedApplication.statusBarHidden = false;
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void) applicationWillTerminate:(UIApplication *)application {
    [channel invokeMethod:@"applicationWillTerminate" arguments:nil];
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    [channel invokeMethod:@"applicationDidEnterBackground" arguments:nil];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [channel invokeMethod:@"applicationDidReceiveMemoryWarning" arguments:nil];
}

- (void) applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
    [channel invokeMethod:@"applicationProtectedDataWillBecomeUnavailable" arguments:nil];

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

- (void)setUncaughtExceptionHandler {
    NSSetUncaughtExceptionHandler(&myExceptionHandler);
}

void myExceptionHandler(NSException *exception) {
    [channel invokeMethod:@"crashHappened" arguments:[exception reason]];
}

- (void)setSignalHandler {
    struct sigaction signalAction;
    memset(&signalAction, 0, sizeof(signalAction));
    signalAction.sa_handler = signalHandler;
    sigemptyset(&signalAction.sa_mask);
    signalAction.sa_flags = 0;
    sigaction(SIGABRT, &signalAction, NULL);
    sigaction(SIGILL, &signalAction, NULL);
    sigaction(SIGBUS, &signalAction, NULL);
    sigaction(SIGFPE, &signalAction, NULL);
    sigaction(SIGSEGV, &signalAction, NULL);
    sigaction(SIGTRAP, &signalAction, NULL);
    sigaction(SIGPIPE, &signalAction, NULL);
}

void signalHandler(int signal) {
    NSString* report = [NSString stringWithFormat:@"Signal %i", signal];
    [channel invokeMethod:@"crashHappened" arguments:report];
}

@end
