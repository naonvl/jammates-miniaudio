import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'JAMMATES DEMO MINIAUDIO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _methodChannel = const MethodChannel("method_channel");
  bool _isPlaying = false;
  double _drumVolume = 1.0;
  double _bassVolume = 1.0;
  double _pianoVolume = 1.0;

  void _togglePlay() {
    if (_isPlaying) {
      _methodChannel.invokeMethod("playSound", {"text": '=====TEST====='});
    } else {
      _methodChannel.invokeMethod("stopSound", {"text": '=====TEST====='});
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _updateDrumVolume(double value) {
    setState(() {
      _drumVolume = value; // Ensure the value is within the range [0.0, 1.0]
    });
    _methodChannel.invokeMethod("updateDrumVolume", {"volume": _drumVolume});
  }

  void _updateBassVolume(double value) {
    setState(() {
      _bassVolume = value; // Ensure the value is within the range [0.0, 1.0]
    });
    _methodChannel.invokeMethod("updateBassVolume", {"volume": _bassVolume});
  }

  void _updatePianoVolume(double value) {
    setState(() {
      _pianoVolume = value; // Ensure the value is within the range [0.0, 1.0]
    });
    _methodChannel.invokeMethod("updatePianoVolume", {"volume": _pianoVolume});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: _togglePlay,
                child: Text(_isPlaying ? 'Pause' : 'Play'),
              ),
              SizedBox(height: 20),
              Text(
                'Drum',
                style: Theme.of(context).textTheme.headline6,
              ),
              Slider(
                value: _drumVolume,
                min: 0,
                max: 1,
                onChanged: _updateDrumVolume,
              ),
              SizedBox(height: 20),
              Text(
                'Bass',
                style: Theme.of(context).textTheme.headline6,
              ),
              Slider(
                value: _bassVolume,
                min: 0,
                max: 1,
                onChanged: _updateBassVolume,
              ),
              SizedBox(height: 20),
              Text(
                'Piano',
                style: Theme.of(context).textTheme.headline6,
              ),
              Slider(
                value: _pianoVolume,
                min: 0,
                max: 1,
                onChanged: _updatePianoVolume,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
