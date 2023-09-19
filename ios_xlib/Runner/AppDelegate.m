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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDirectory = [paths firstObject];
    NSLog(@"Library/Application Support Directory: %@", appSupportDirectory);
		
  InitDeviceMiniaudio(appSupportDirectory);
  SetMasterVolume(1.0f);
   
  pthread_create(&th1, NULL, worker, "ExecutePlayer");
  [GeneratedPluginRegistrant registerWithRegistry:self];
  FlutterViewController* controller =
      (FlutterViewController*)self.window.rootViewController;

  FlutterMethodChannel* audioMethodChannel = [FlutterMethodChannel
      methodChannelWithName:@"method_channel"
            binaryMessenger:controller];
			
			
  __weak typeof(self) weakSelf = self;
       [audioMethodChannel setMethodCallHandler:^(FlutterMethodCall* call,
    FlutterResult result) {
        @synchronized (self) {
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
              float volumeSet = 0.0;
              SetPitchAll(volumeSet);
              result(@"SetPitchAll method invoked");
            } else if ([@"initPlayer" isEqualToString:call.method]) {
                NSLog(@"List<String> audioTracks: %@", call.arguments[@"audioTracks"]);
                NSArray *audioTracks = (NSArray *)call.arguments[@"audioTracks"];
                NSString *tempo = (NSString *)call.arguments[@"tempo"];
                NSString *isNewMusic = (NSString *)call.arguments[@"isNewMusic"];
                NSLog(@"List<String> audioTracks: %@-%@", audioTracks[0], tempo);
                StopPlayer();
                ResetList();
                for (NSString *track in audioTracks) {
                    NSString *fullTrackName = [NSString stringWithFormat:@"%@-%@.mp3", track, tempo];
                    const char *cStr = [fullTrackName UTF8String];
                    AddMusic(cStr);
                }
                if ([isNewMusic isEqualToString:@"true"]) {
                    ResumePlayer();
                }
                NSLog(@"initPlayer: STARTED");
            } else if ([@"updateVolume" isEqualToString:call.method]) {
                NSInteger index = [call.arguments[@"index"] integerValue];
                float volumeSet = [call.arguments[@"volume"] floatValue];
                NSLog(@"Volume Set: %f", volumeSet);
                SetVolumeForMusic(index, volumeSet);
                result(@"updateDrumVolume method invoked");

            } else if ([@"setPitch" isEqualToString:call.method]) {
                float pitchSet = [call.arguments[@"pitch"] floatValue];
                NSLog(@"Volume Set: %f", pitchSet);
                SetPitchAll(pitchSet);
                result(@"updateDrumVolume method invoked");

            } else {
                result(FlutterMethodNotImplemented);
            }
        }
    }];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
