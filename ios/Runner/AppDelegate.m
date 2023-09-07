// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "AppDelegate.h"
#import <Flutter/Flutter.h>
#import "GeneratedPluginRegistrant.h"


#define PLATFORM_IOS
#include "../../miniaudio/IOSAPI/iosAPI.h"
#include "../../miniaudio/IOSAPI/iosAPI.c"


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>


void *worker(void *data)
{
    ExecutePlayer();
    return NULL;
}
 
pthread_t th1;

@implementation AppDelegate {
  FlutterEventSink _eventSink;
}

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
		
		
  InitDeviceMiniaudio();
  SetMasterVolume(1.0f);
   
  // Execute thread
  pthread_create(&th1, NULL, worker, "ExecutePlayer");
  [GeneratedPluginRegistrant registerWithRegistry:self];
  FlutterViewController* controller =
      (FlutterViewController*)self.window.rootViewController;

  FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
      methodChannelWithName:@"Battery"
            binaryMessenger:controller];

  FlutterMethodChannel* audioMethodChannel = [FlutterMethodChannel
      methodChannelWithName:@"method_channel"
            binaryMessenger:controller];
			
			
  __weak typeof(self) weakSelf = self;
  [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                         FlutterResult result) {
    if ([@"getBatteryLevel" isEqualToString:call.method]) {
      int batteryLevel = [weakSelf getBatteryLevel];
      if (batteryLevel == -1) {
        result([FlutterError errorWithCode:@"UNAVAILABLE"
                                   message:@"Battery info unavailable"
                                   details:nil]);
      } else {
        result(@(batteryLevel));
      }
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
  
  
///////////////
       [audioMethodChannel setMethodCallHandler:^(FlutterMethodCall* call,
    FlutterResult result) {
        @synchronized (self) { // Protect against potential race conditions
            if ([@"playSound" isEqualToString:call.method]) {
                StartPlayer();
                result(@"StartPlayer method invoked");
            } else if ([@"stopSound" isEqualToString:call.method]) {
                StopPlayer();
                result(@"StopPlayer method invoked");
            } else if ([@"pauseSound" isEqualToString:call.method]) {
                PausePlayer();
                result(@"PausePlayer method invoked");
            } else if ([@"resumeSound" isEqualToString:call.method]) {
                ResumePlayer();
                result(@"ResumePlayer method invoked");
            } else if ([@"setPitchAll" isEqualToString:call.method]) {
              float pitchSet = [call.arguments[@"volume"] floatValue];
              float volumeSet = 0.0; // Initialize volumeSet with an appropriate value

              SetPitchAll(volumeSet);
              result(@"SetPitchAll method invoked");
            } else if ([@"initPlayer" isEqualToString:call.method]) {
                NSLog(@"List<String> audioTracks :%@", call.arguments[@"audioTracks"]);
                NSArray *audioTracks = (NSArray *)call.arguments[@"audioTracks"];
                NSLog(@"List<String> audioTracks :%@-%@", audioTracks[0], call.arguments[@"tempo"]);

                for (NSString *track in audioTracks) {
                    NSString *fullTrackName = [track stringByAppendingString:@".mp3"];
                    const char *cStr = [fullTrackName UTF8String];
                    AddMusic(cStr);
                }
                NSLog(@"initPlayer: STARTED");



            } 
			else if ([@"updateVolume" isEqualToString:call.method]) {
                NSInteger index = [call.arguments[@"index"] integerValue];
                float volumeSet = [call.arguments[@"volume"] floatValue];
                NSLog(@"Volume Set: %f", volumeSet); // Add this log statement
                SetVolumeForMusic(index, volumeSet);
                result(@"updateDrumVolume method invoked");

            }
            else if ([@"setPitch" isEqualToString:call.method]) {
                float pitchSet = [call.arguments[@"pitch"] floatValue];
                NSLog(@"Volume Set: %f", pitchSet); //
                SetPitchAll(pitchSet);
                result(@"updateDrumVolume method invoked");

            }
			
			else {
                result(FlutterMethodNotImplemented);
            }
        }
    }];


  
//////////////////
  
  FlutterEventChannel* chargingChannel = [FlutterEventChannel
      eventChannelWithName:@"samples.flutter.io/charging"
           binaryMessenger:controller];
  [chargingChannel setStreamHandler:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


- (void)applicationWillResignActive:(UIApplication *)application 
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application 
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	PausePlayer();
}

- (void)applicationWillEnterForeground:(UIApplication *)application 
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (int)getBatteryLevel {
  UIDevice* device = UIDevice.currentDevice;
  device.batteryMonitoringEnabled = YES;
  if (device.batteryState == UIDeviceBatteryStateUnknown) {
    return -1;
  } else {
    return ((int)(device.batteryLevel * 100));
  }
}

- (FlutterError*)onListenWithArguments:(id)arguments
                             eventSink:(FlutterEventSink)eventSink {
  _eventSink = eventSink;
  [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
  [self sendBatteryStateEvent];
  [[NSNotificationCenter defaultCenter]
   addObserver:self
      selector:@selector(onBatteryStateDidChange:)
          name:UIDeviceBatteryStateDidChangeNotification
        object:nil];
  return nil;
}

- (void)onBatteryStateDidChange:(NSNotification*)notification {
  [self sendBatteryStateEvent];
}

- (void)sendBatteryStateEvent {
  if (!_eventSink) return;
  UIDeviceBatteryState state = [[UIDevice currentDevice] batteryState];
  switch (state) {
    case UIDeviceBatteryStateFull:
    case UIDeviceBatteryStateCharging:
      _eventSink(@"charging");
      break;
    case UIDeviceBatteryStateUnplugged:
      _eventSink(@"discharging");
      break;
    default:
      _eventSink([FlutterError errorWithCode:@"UNAVAILABLE"
                                     message:@"Charging status unavailable"
                                     details:nil]);
      break;
  }
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _eventSink = nil;
  return nil;
}

@end
