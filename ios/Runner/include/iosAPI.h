
#ifndef IOS_API_H
#define IOS_API_H
#include <Foundation/Foundation.h>
#include <string.h>
#include <sys/types.h>
#include <stdio.h>              // Required for: printf()

#include "utils.h"
#include "raudio.h"

#define NUM_OF_MUSIC    11
#ifdef __cplusplus
extern "C" {            // Prevents name mangling of functions
#endif

void InitDeviceMiniaudio();
void ExecutePlayer();

void SetPitchAll( float );

void StartPlayer();
void StopPlayer();
void ResetList();
void PausePlayer();
void ResumePlayer();
void CleanResource();

//// IOS Special
void AddMusic(const char* path);
void RemoveMusicStream( int pos );
void SetVolumeForMusic(NSInteger index, float vol);

#ifdef __cplusplus
}
#endif

#endif /// IOS_API_H
