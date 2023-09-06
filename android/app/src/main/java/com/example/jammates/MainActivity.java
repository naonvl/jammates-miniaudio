package com.example.jammates;

import android.os.Bundle;
import android.util.Log;
import java.util.List;
import androidx.annotation.NonNull;
import java.util.ArrayList; 
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/// For MiniAudio Library
import com.jenggotmalam.MiniAudioPlayer;

public class MainActivity extends FlutterActivity {
    private MethodChannel methodChannel;

	private MiniAudioPlayer miniAudioPlayer;
	
	@Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        miniAudioPlayer = new MiniAudioPlayer(this);
        miniAudioPlayer.StartAudioThread();
    }
	List<String> audioTracks = new ArrayList<>();
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Commands received from Flutter code:
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "method_channel");
        methodChannel.setMethodCallHandler((call, result) -> {
			
			Log.d("TAG", "(call, result)");
            switch (call.method) {
                case "initPlayer":
                    // Initialize your player here based on audio tracks received from Flutter
                    //List<String> audioTracks = call.argument("audioTracks");
					Log.d("TAG", "switch (call.method) {");
					Log.d("TAG", "List<String> audioTracks :" + call.argument("audioTracks") );
                    audioTracks = (List<String>)call.argument("audioTracks");
					Log.d("TAG", "List<String> audioTracks :" + audioTracks.get(0) + "-" + call.argument("tempo") );
					
					// Reset First the array
					miniAudioPlayer.ResetList();
                    // miniAudioPlayer.StopAllAudio();
                    
					///
					
                    for (String track : audioTracks) {
                        miniAudioPlayer.AddMusicStreamToPlay(track + "-" + call.argument("tempo") + ".mp3");

                    }
                    Log.d("TAG", "initPlayer: STARTED");
                    break;                
				case "addMp3FromStorage":
                    // Initialize your player here based on audio tracks received from Flutter
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
                    Log.e("TAG", " (call.method) APASIH");
                    break;
            }
			Log.d("TAG", " result.success(null)");
            result.success(null); // Indicate successful handling of the method call
        });
    }

}
