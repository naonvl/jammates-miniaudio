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
  
  // Add Mp3
  AddMusic("bass.mp3");
  AddMusic("drum.mp3");
  AddMusic("piano.mp3");
   
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
  // StartPlayer
  [audioMethodChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                         FlutterResult result) {
    if ([@"playSound" isEqualToString:call.method]) {
		StartPlayer();
    }
  }];

    // StopPlayer
  [audioMethodChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                         FlutterResult result) {
    if ([@"stopSound" isEqualToString:call.method]) {
		StopPlayer();
    }
  }];

    // PausePlayer
  [audioMethodChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                         FlutterResult result) {
    if ([@"pauseSound" isEqualToString:call.method]) {
		PausePlayer();
    }
  }];

      // ResumePlayer
  [audioMethodChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                         FlutterResult result) {
    if ([@"resumeSound" isEqualToString:call.method]) {
		ResumePlayer();
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
