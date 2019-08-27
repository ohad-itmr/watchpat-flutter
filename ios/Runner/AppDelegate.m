#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

static FlutterMethodChannel *channel = nil;
static BOOL sessionCompleted = NO;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setUncaughtExceptionHandler];
    [self setSignalHandler];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillTerminate:)
     name:UIApplicationWillTerminateNotification object:nil];
    
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
        } else if ([@"startBackgroundSftpUploading" isEqualToString:call.method]) {
            [self startBackgroundSftpUploading];
        } else if ([@"backgroundSftpUploadingFinished" isEqualToString:call.method]) {
            sessionCompleted = YES;
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    
    UIApplication.sharedApplication.statusBarHidden = false;
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


+ (void) writeLogToFile:(NSString *)str {
    NSString *message = [AppDelegate generateLogMessage:str];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSString *fileName = @"ios_logs.txt";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (0 < [paths count]) {
        NSString *documentsDirPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirPath stringByAppendingPathComponent:fileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
            [fileHandler seekToEndOfFile];
            [fileHandler writeData:data];
            [fileHandler closeFile];
        } else {
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
    [channel invokeMethod:@"nativeLogEvent" arguments:@"Application will be terminated"];
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    [AppDelegate writeLogToFile:@"Application entered background"];
    [channel invokeMethod:@"nativeLogEvent" arguments:@"Application entered background"];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [AppDelegate writeLogToFile:@"Application received memory warning"];
    [channel invokeMethod:@"nativeLogEvent" arguments:@"Application received memory warning"];
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

- (void)startBackgroundSftpUploading {
    [[NSProcessInfo processInfo] performExpiringActivityWithReason:@"BackgroundSftpUploading" usingBlock:^void (BOOL expired) {
        if (expired && !sessionCompleted) {
            NSString *msg = @"SFTP background task expired, closing SFTP upload";
            [channel invokeMethod:@"nativeLogEvent" arguments:msg];
            [channel invokeMethod:@"stopSftpUploading" arguments:nil];
            [AppDelegate writeLogToFile:msg];
        } else if (!sessionCompleted) {
            NSString *msg = @"SFTP background task is active, starting/continuing SFTP upload";
            [channel invokeMethod:@"nativeLogEvent" arguments:msg];
            [channel invokeMethod:@"startSftpUploading" arguments:nil];
            [AppDelegate writeLogToFile:msg];
            
            while (!sessionCompleted) {
                [NSThread sleepForTimeInterval:1.0];
                if (sessionCompleted) {
                    NSString *msg = @"SFTP background uploading finished";
                    [channel invokeMethod:@"nativeLogEvent" arguments:msg];
                    [AppDelegate writeLogToFile:msg];
                }
            }
        }
    }];
}


void myExceptionHandler(NSException *exception) {
    NSString *msg = [NSString stringWithFormat:@">>>>>>>>>> EXCEPTION: %@", [exception reason]];
    [AppDelegate writeLogToFile:msg];
    [channel invokeMethod:@"nativeLogEvent" arguments:msg];
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
    NSString* report = [NSString stringWithFormat:@">>>>>>>>>> SIGNAL: %i", signal];
    [AppDelegate writeLogToFile:report];
    [channel invokeMethod:@"nativeLogEvent" arguments:report];
}

@end
