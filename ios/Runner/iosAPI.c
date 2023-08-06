#include "iosAPI.h"

void InitDeviceMiniaudio()
{
	InitAudioDevice();
	
	
	musicListTogether.count = 0;
	for(int i = 0; i < NUM_OF_MUSIC; i++)
	{
		musicListTogether.indexToPlay[ i ] = i;
	}
	/// And the audio file

}

/* NSSound *player = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Sound" ofType:@"mp3"] byReference:NO];
[player play]; */
///
/// Audio Streaming Thread
/// Use Java Thread
void ExecutePlayer()
{
    // Main loop
	while ( !isClosed )
    {
		while ( isPlaying )
		{
			setPitchReady = 0;
			for(int i = 0; i < musicListTogether.count; i++)
			{				
				// for race condition
				if ( isPlaying == 0 ) break;
				UpdateMusicStream( musicListTogether.music[ musicListTogether.indexToPlay[ i ] ] );
			}
			
			setPitchReady = 1;
			usleep( 3000 ); 
		}
		
		setPitchReady = 1;
		// prevent processor halt
		usleep( 600000 ); // 0.6 seconds
	}
}

void AddMusic(const char* path)
{
	if( musicListTogether.count > NUM_OF_MUSIC)
		return;
	
	//NSString* databasePathFromApp = [[NSBundle mainBundle] pathForResource:@"triggers" ofType:@"sql"];
	
	NSString *NSstr = [NSString stringWithUTF8String:path];
	
	NSString *pathIOS = [[NSBundle mainBundle] pathForResource:NSstr ofType:@"mp3"];
	
	const char* cStr = [pathIOS UTF8String];
	
	musicListTogether.music[ musicListTogether.indexToPlay[ musicListTogether.count ] ] = LoadMusicStream( cStr );
	musicListTogether.count++;
	
}

void SetPitchAll( float pitch)
{
	while(1)
	{
		if( setPitchReady )
		{
			for(int i = 0; i < musicListTogether.count; i++)
			{				
				SetMusicPitch( musicListTogether.music[ musicListTogether.indexToPlay[ i ] ], pitch );
			}
			break;
		}
	}
}

void StartPlayer()
{
	// Stop First
	isPlaying = 1;
	StopPlayer();
	for(int i = 0; i < musicListTogether.count; i++)
	{				
		PlayMusicStream( musicListTogether.music[ musicListTogether.indexToPlay[ i ] ] );
	}
	
	isPlaying = 1;
}

void ResumePlayer()
{
	if( isPlaying == 0 )
	{
		for(int i = 0; i < musicListTogether.count; i++)
		{				
			ResumeMusicStream( musicListTogether.music[ musicListTogether.indexToPlay[ i ] ] );
		}
		isPlaying = 1;
	}
}

void StopPlayer()
{
	if ( isPlaying )
	{
		isPlaying = 0;
		for(int i = 0; i < musicListTogether.count; i++)
		{				
			StopMusicStream( musicListTogether.music[ musicListTogether.indexToPlay[ i ] ] );
		}
	}
}
void PausePlayer()
{
	if ( isPlaying ) 
	{
		isPlaying = 0;
		for(int i = 0; i < musicListTogether.count; i++)
		{				
			PauseMusicStream( musicListTogether.music[ musicListTogether.indexToPlay[ i ] ] );
		}

	}
}

void CleanResource()
{
	
	for(int i = 0; i < musicListTogether.count; i++)
	{				
		UnloadMusicStream( musicListTogether.music[ musicListTogether.indexToPlay[ i ] ] );
	}

    CloseAudioDevice();
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------


