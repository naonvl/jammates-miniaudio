
#ifndef IOS_API_H
#define IOS_API_H

#include <string.h>
#include <sys/types.h>

#include "raudio.h"
#include "external/utilities/UTILS/utils.h"

#include <stdio.h>              // Required for: printf()

#define NUM_OF_MUSIC	11

int isClosed = 0;
//int pauseMusic = 0;
int isPlaying = 0;
int setPitchReady = 0;
//int pitchValue = 0;


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



#endif /// IOS_API_H

