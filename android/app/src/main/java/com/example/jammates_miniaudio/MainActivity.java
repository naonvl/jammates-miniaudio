package com.example.jammates;

import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private MethodChannel methodChannel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Commands received from Flutter code:
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "method_channel");
        methodChannel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "playSound":
                    Log.d("TAG", "Play sound: " + call.argument("text"));
                    break;
                case "stopSound":
                    Log.d("TAG", "Stop sound: " + call.argument("text"));
                    break;
                case "updateDrumVolume":
                    double drumVolume = call.argument("volume");
                    Log.d("TAG", "Drum volume updated: " + drumVolume);
                    break;
                case "updateBassVolume":
                    double bassVolume = call.argument("volume");
                    Log.d("TAG", "Bass volume updated: " + bassVolume);
                    break;
                case "updatePianoVolume":
                    double pianoVolume = call.argument("volume");
                    Log.d("TAG", "Piano volume updated: " + pianoVolume);
                    break;
                default:
                    Log.e("TAG", "ERROR");
                    break;
            }
            result.success(null); // Indicate successful handling of the method call
        });
    }

}
