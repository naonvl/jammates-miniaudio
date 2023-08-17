# MiniAudio 

This project is using RAUDIO based on MiniAudio


You can read more about RAUDIO
[accessing platform and third-party services in RAUDIO](https://github.com/raysan5/raudio).

You can read more about MiniAudio
[accessing platform and third-party services in MiniAudio](https://miniaud.io/).

## iOS
Inside the IOSAPI folder, there are source code to call c/c++ code from OBJ-C

## Android
Inside the AndroidAPI folder, there are source code to call c/c++ code from JAVA


---------------------------------------------------------------------
# External Folder

Inside the external folder, there are source code for encode audio type like .mp3 .ogg etc. And some utilities for string manipulation to detect file name type

---------------------------------------------------------------------

# The API
- Declaration 
```cpp
#define NUM_OF_MUSIC	11

int isClosed = 0;
int isPlaying = 0;
int setPitchReady = 0;

/// Using this for dynamic music load, but the MAX is fixed size
struct MusicListTogether
{
	Music music[ NUM_OF_MUSIC ];
	
	int indexToPlay[ NUM_OF_MUSIC ];
	int indexInActive[ NUM_OF_MUSIC ];
	int count; /// For looping
	
};

struct MusicListTogether musicListTogether;

void InitDeviceMiniaudio();
void ExecutePlayer();
void SetPitchAll( float );
void AddMusic(const char* path);
void StartPlayer();
void StopPlayer();
void PausePlayer();
void ResumePlayer();
void CleanResource();

```