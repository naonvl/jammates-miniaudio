import 'package:flutter/material.dart';

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
  bool _isPlaying = false;
  int _drumVolume = 100;
  int _bassVolume = 100;
  int _pianoVolume = 100;

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _updateDrumVolume(double value) {
    setState(() {
      _drumVolume = value.round();
    });
  }

  void _updateBassVolume(double value) {
    setState(() {
      _bassVolume = value.round();
    });
  }

  void _updatePianoVolume(double value) {
    setState(() {
      _pianoVolume = value.round();
    });
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
                value: _drumVolume.toDouble(),
                min: 0,
                max: 100,
                onChanged: _updateDrumVolume,
              ),
              SizedBox(height: 20),
              Text(
                'Bass',
                style: Theme.of(context).textTheme.headline6,
              ),
              Slider(
                value: _bassVolume.toDouble(),
                min: 0,
                max: 100,
                onChanged: _updateBassVolume,
              ),
              SizedBox(height: 20),
              Text(
                'Piano',
                style: Theme.of(context).textTheme.headline6,
              ),
              Slider(
                value: _pianoVolume.toDouble(),
                min: 0,
                max: 100,
                onChanged: _updatePianoVolume,
              ),
            ],
          ),
        ),
      ),
    );
  }
}