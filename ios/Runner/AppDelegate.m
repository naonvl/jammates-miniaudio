#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  
  FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
  
  FlutterMethodChannel* methodChannel = [FlutterMethodChannel
                                         methodChannelWithName:@"method_channel"
                                         binaryMessenger:controller.binaryMessenger];
  
  [methodChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"initPlayer" isEqualToString:call.method]) {
      NSDictionary *arguments = call.arguments;
      NSArray *audioTracks = arguments[@"audioTracks"];
      NSString *tempo = arguments[@"tempo"];
      
        NSLog(@"audioTracks: %@", audioTracks);

      result(nil);
    } else if ([@"playSound" isEqualToString:call.method]) {
      NSString *filePath = call.arguments;
      
      [self playSoundWithFilePath:filePath];
      result(nil);
    } else if ([@"stopSound" isEqualToString:call.method]) {
      NSString *filePath = call.arguments;
      
      [self stopSoundWithFilePath:filePath];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
  
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)initPlayerWithAudioTracks:(NSArray *)audioTracks tempo:(NSString *)tempo {
  // Your implementation for initializing the player goes here
}

- (void)playSoundWithFilePath:(NSString *)filePath {
  // Your implementation for playing sound goes here
}

- (void)stopSoundWithFilePath:(NSString *)filePath {
  // Your implementation for stopping sound goes here
}

@end
