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

+ (void)writeLogToFile:(NSString *)str {
    NSString *message = [AppDelegate generateLogMessage:str];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSString *fileName = @"ios_logs.txt";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (0 < [paths count]) {
        NSString *documentsDirPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirPath stringByAppendingPathComponent:fileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            // Add the text at the end of the file.
            NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
            [fileHandler seekToEndOfFile];
            [fileHandler writeData:data];
            [fileHandler closeFile];
        } else {
            // Create the file and write text to it.
            [data writeToFile:filePath atomically:YES];
        }
    }
}

+ (NSString *) generateLogMessage: (NSString *)str {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    NSString *message = [NSString stringWithFormat:@"%@ %@ \n", dateString, str];
    return message;
}

- (void) applicationWillTerminate:(UIApplication *)application {
    [AppDelegate writeLogToFile:@"Application will be terminated"];
    [channel invokeMethod:@"applicationWillTerminate" arguments:nil];
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    [AppDelegate writeLogToFile:@"Application entered background"];
    [channel invokeMethod:@"applicationDidEnterBackground" arguments:nil];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [AppDelegate writeLogToFile:@"Application received memory warning"];
    [channel invokeMethod:@"applicationDidReceiveMemoryWarning" arguments:nil];
}

- (void) applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
    [AppDelegate writeLogToFile:@"Application protected data became unavailable"];
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
    NSString *msg = [NSString stringWithFormat:@"EXCEPTION: %@", [exception reason]];
    [AppDelegate writeLogToFile:msg];
    [channel invokeMethod:@"crashHappened" arguments:msg];
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
    NSString* report = [NSString stringWithFormat:@"SIGNAL: %i", signal];
    [AppDelegate writeLogToFile:report];
    [channel invokeMethod:@"crashHappened" arguments:report];
}

@end
