package com.jenggotmalam;

import java.util.*;  

import android.app.Activity;
import android.content.res.AssetManager;
import android.util.Log;

public class MiniAudioPlayer {

	static { System.loadLibrary("androidAPI"); }
	private Map<String, Integer> musicList;
	
	public Thread audioThread;
	private static final String TAG = "MiniAudioJava";

	/// Temporary, cannot be decreased dynamically
	private int indexMusic = 0;
	
    public MiniAudioPlayer(Activity activity) {

		Log.v(TAG,  activity.getFilesDir().getPath() );
		InitAssetManagerMini(activity.getResources().getAssets() , activity.getFilesDir().getPath() );
		
		Log.v(TAG, "InitMiniaudio");
		InitMiniaudio();
		
		musicList = new HashMap<String, Integer>();
		
		
		audioThread = new Thread(new Runnable() {

						@Override
						public void run() {
							
							Log.v(TAG, "In Thread StartThreadMiniaudio();");
							StartThreadMiniaudio();
						 }
					 });
    }

	public void AddMusicStreamToPlay(String pathName) // audio/bass.mp3
	{
		Log.v(TAG, "AddMusicStreamToPlay(String pathName)");
		musicList.put(pathName, indexMusic);
		indexMusic++;
		
		Log.v(TAG, "AddMusicStream( pathName );");
		AddMusicStream( pathName );
		
		Log.v(TAG, "AddMusicStream( pathName );");
	}
	
	public void SetMusicVolumeOf(String pathName, float vol)
	{
		int pos = musicList.get( pathName );
		
		SetVolumeForMusic(pos, vol);
	}
	
	public void StartAudioThread()
	{
		if( !audioThread.isAlive() )
		{
			audioThread.start();
			return;
		}
	}
	
	public void StopAllAudio()
	{
		StopMiniaudio();	
	}
			
	public void PauseAllAudio()
	{
		PauseMiniaudio();	
	}
					
	public void ResumeAllAudio()
	{
		ResumeMiniaudio();	
	}
		
	public void PlayAllAudio()
	{
		// restart playing
		PlayMiniaudio();	
	}
	
    public void onDestroy() {
		
		SetIsClosed( 1 );
		CleanResource();
		
	}
	
	
	private native void InitAssetManagerMini(AssetManager mgr, String path);

	public native void SetIsClosed(int value);
	public native void AddMusicStream(String pathName);
	public native void CleanResource();
	public native void InitMiniaudio();
	public native void PlayMiniaudio();
	
	public native void StopMiniaudio();
	public native void PauseMiniaudio();
	public native void ResumeMiniaudio();
	
	public native void SetVolumeForMusic(int pos, float vol);
	
	public native void StartThreadMiniaudio();

	
}
