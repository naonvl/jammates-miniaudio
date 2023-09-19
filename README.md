# Flutter + Miniaudio
    
This project built using Flutter 3.10.6 and the app contains these features :
- Download files from cloud to private app directory
- Play audio from storage, the audio player uses [miniaudio](https://miniaud.io/) with c
- Change BPM using pitch
- Change Volume
- Change files then play from the previous duration

We use `platform_channel` to connect flutter to native android (java + c) and iOS (objc+c).

# Usage
## Flutter
Inside `main.dart` we have created a demo to use the miniaudio library we created.

### 1. Declaration
```dart
  final _methodChannel = const MethodChannel("method_channel");
  List<String> _audioTracks = ['drum', 'bass', 'piano']; // ARRAY OF INSTRUMENTS OF THE SONG
  List<String> _audioPaths = [];
  Map<String, bool> _soloStates = {};
  Map<String, double> _tempTrackVolumes = {};
  Map<String, double> _trackVolumes = {};
  String selectedOption = 'medium'; // CURRENT SONG'S TEMPO
  int _currentBpm = 100; // VALUE FOR CURRENT BPM
  double _currentPitch = 1.0;
  // REFERENCE VALUE FOR CURRENT SONG'S BPM
  int _mediumBpm = 100;
  int _slowBpm = 90;
  int _fastBpm = 120;
```
Here we declare the necessary data for the song to be played. Then we initialize the player by invoking to method channel with necessary params.

```dart
  @override
  void initState() {
    super.initState();
    if (!isInitialized) {
      isInitialized = true;
      initPlayer().then((value) {
        // WE DOWNLOAD THE AUDIO FILES FIRST, THEN PASS THE FILE NAME WITH INITPLAYER METHOD
        if (!isInitPlayerInvoked) {
          downloadAndInitializePlayer(selectedOption).then((_) {
            print('====== STARTED ======');
            setState(() {
              _isDownloading = false;
              isInitPlayerInvoked = true;
            });
            _methodChannel.invokeMethod("initPlayer",
                {"audioTracks": _audioTracks, "tempo": selectedOption[0]});
          });
        }
      });
    }
  }
```
Currently the file name we use this prefix, `instrumentname-s/m/f.mp3`, it'll be read by the miniaudio library from private app directory of each platform's.


## iOS
iOS using objective C version, not swift. Run the app using `flutter run` as usual or open the `Runner.xcworkspace`.

Inside `appdelegate.m`, you can modify this code to your needs.

```c
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
```

the function called from `miniaudio/iosAPI.c` file.

## Android
Android using java version. Run the app using `flutter run` as usual or open the android folder using Android Studio.

inside `app/src/main/java/com/example/jammates/MainActivity.java` you can modify this part of the code to your needs.

```java
methodChannel.setMethodCallHandler((call, result) -> {
			Log.d("TAG", "(call, result)");
            switch (call.method) {
                case "initPlayer":
					Log.d("TAG", "switch (call.method) {");
					Log.d("TAG", "List<String> audioTracks :" + call.argument("audioTracks") );
                    audioTracks = (List<String>)call.argument("audioTracks");
					Log.d("TAG", "List<String> audioTracks :" + audioTracks.get(0) + "-" + call.argument("tempo") );
					miniAudioPlayer.StopAllAudio();
					miniAudioPlayer.ResetList();
                    for (String track : audioTracks) {
                        miniAudioPlayer.AddMusicStreamToPlay(track + "-" + call.argument("tempo") + ".mp3");
                    }
                    Log.d("TAG", "initPlayer: STARTED");
                    break;                
				case "addMp3FromStorage":
                    String audioTrack = call.argument("audioTrack");
                    miniAudioPlayer.AddMusicStreamToPlayFromStorage(audioTrack);
                    Log.d("TAG", "addMp3FromStorage: STARTED");
                    break;
                case "playSound":
                    Log.d("TAG", "Play sound: " + call.argument("filePath"));
					miniAudioPlayer.PlayAllAudio();
                    break;
                case "stopSound":
                    Log.d("TAG", "Stop sound: " + call.argument("filePath"));
					miniAudioPlayer.StopAllAudio();
                    break;
				case "pauseSound":
                    Log.d("TAG", "Stop sound: " + call.argument("text"));
					miniAudioPlayer.PauseAllAudio();
                break;
				case "resumeSound":
                    Log.d("TAG", "Stop sound: " + call.argument("text"));
					miniAudioPlayer.ResumeAllAudio();
                break;
                case "updateVolume":
                    String trackName = call.argument("trackName");
                    String tempo = call.argument("tempo");
                    float volume = ((Number) call.argument("volume")).floatValue();
                    Log.d("TAG", trackName + " volume updated: " + volume);
                    String audioFilePath =  trackName + "-" + tempo + ".mp3";
                    miniAudioPlayer.SetMusicVolumeOf(audioFilePath, volume);
                break;
				case "setPitch":
                    float pitch = ((Number) call.argument("pitch")).floatValue();
                    Log.d("TAG", "Pitch volume updated: " + pitch);
					miniAudioPlayer.SetPitchAllAudio( pitch );
                    break;
                default:
                    break;
            }
			Log.d("TAG", " result.success(null)");
            result.success(null);
        });

    ```
The functions imported from `MiniAudioPlayer` class, there we declare JNI functions to API from generated .so libraries for each architecture. You can find the the generated .so files that we use for the project inside `/app/src/main/jniLibs`. refer to this [repo](http://gitlab.bory.io:2022/b2022_sound_processing/2023_audio_sync_test_library) to generate or modify the APIs.

## Notes
There's a folder named `ios_libs` it's an example to use `.a` static library in iOS.
## Modules

- [RAUDIO](https://github.com/raysan5/raudio)
- [MiniAudio](https://miniaud.io/)
- [dr-libs](https://github.com/mackron/dr_libs)
- [platform channels](https://docs.flutter.dev/platform-integration/platform-channels)