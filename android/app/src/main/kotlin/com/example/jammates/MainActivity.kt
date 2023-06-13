package com.example.jammates
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import kotlin.random.Random

class MainActivity: FlutterActivity() {
    private lateinit var methodChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?)
    {
        super.onCreate(savedInstanceState)


        // commands received from Flutter code:
        val binaryMessenger = flutterEngine!!.dartExecutor.binaryMessenger
        methodChannel = MethodChannel(binaryMessenger, "method_channel")
        methodChannel.setMethodCallHandler { call, _ ->
            when (call.method)
            {
                "playSound" -> {
//					val volume = Random.nextDouble(100.0, 1001.0)
//					nativeManager.playSound(volume)
                    Log.d("TAG", "onCreate: PLAY")
                }
                "stopSound" -> {
                    Log.d("TAG", "onCreate: STOP")
                }
                else -> {
                    Log.e("TAG", "onCreate: ERROR")
                }
            }
        }
    }
}
