import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
  List<String> _audioTracks = ['drum', 'bass', 'piano'];
  List<String> _audioPaths = [];
  Map<String, bool> _soloStates = {};
  Map<String, double> _tempTrackVolumes = {};
  Map<String, double> _trackVolumes = {};
  String selectedOption = 'Medium';
  int _currentBpm = 100;
  int _mediumBpm = 100;
  void _togglePlay() {
    if (!_isPlaying) {
      _methodChannel
          .invokeMethod("playSound", {"filePath": _audioPaths.toString()});
    } else {
      _methodChannel
          .invokeMethod("stopSound", {"filePath": _audioPaths.toString()});
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void initState() {
    super.initState();
    _methodChannel
        .invokeMethod("initPlayer", {"audioTracks": _audioTracks.toString()});
    // Initialize solo states and track volumes based on _audioTracks
    for (String track in _audioTracks) {
      downloadAndSaveFile(
              'https://github.com/naonvl/vespa-configurator-playcanvas/blob/main/' +
                  track +
                  '.mp3',
              track + '.mp3')
          .then((path) {
        _audioPaths.add(path);
      });
      _soloStates[track] = false;
      _tempTrackVolumes[track] = 1.0;
      _trackVolumes[track] = 1.0;
    }
  }

  Future<String> downloadAndSaveFile(String url, String filename) async {
    Directory dir = await getApplicationSupportDirectory();
    String path = '${dir.path}/$filename';
    File file = File(path);

    if (await file.exists()) {
      print('File already exists at $path');
      return path;
    }

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var bytes = response.bodyBytes;
      await file.writeAsBytes(bytes);
      print('File saved at $path');
      return path;
    } else {
      throw Exception('Failed to download file');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _updateTrackVolume(int index, double value) {
    String trackName = _audioTracks[index];
    setState(() {
      _trackVolumes[trackName] = value;
    });
    _methodChannel.invokeMethod("update${indexToPosition(index + 1)}Volume",
        {"volume": _tempTrackVolumes[trackName]});
  }

  String indexToPosition(int index) {
    switch (index) {
      case 1:
        return 'First';
      case 2:
        return 'Second';
      case 3:
        return 'Third';
      // Add more cases as needed
      default:
        return 'Unknown';
    }
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
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _togglePlay,
                    child: Text(_isPlaying ? 'Pause' : 'Play'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return MyBottomSheet(
                            selectedOption: selectedOption,
                            currentBpm: _currentBpm,
                            mediumBpm: _mediumBpm,
                            onUpdate: (newOption, newBpm) {
                              print(newOption);
                              setState(() {
                                selectedOption = newOption;
                                _currentBpm = newBpm;
                              });
                            },
                          );
                        },
                      );
                    },
                    child: Text('TEMPO'),
                  )
                ],
              ),
              SizedBox(height: 20),
              Column(
                children: _audioTracks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final track = entry.value;
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            track, // Assuming you have the capitalize function
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Row(
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (_trackVolumes[track] == 0) {
                                      _trackVolumes[track] =
                                          _tempTrackVolumes[track]!;
                                    } else {
                                      _tempTrackVolumes[track] =
                                          _trackVolumes[track]!;
                                      _trackVolumes[track] = 0;
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: _trackVolumes[track]! > 0
                                      ? Colors.transparent
                                      : Colors.blue,
                                  onPrimary: _trackVolumes[track]! > 0
                                      ? Colors.black
                                      : Colors.white,
                                  elevation: 0,
                                  side: BorderSide.none,
                                ),
                                child: Text('M'),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (_soloStates[track] == false) {
                                      _trackVolumes[track] = 1;
                                      for (String otherTrack in _audioTracks) {
                                        if (otherTrack != track) {
                                          _soloStates[otherTrack] = false;
                                          _tempTrackVolumes[otherTrack] =
                                              _trackVolumes[otherTrack]!;
                                          _trackVolumes[otherTrack] = 0;
                                        }
                                      }
                                    } else {
                                      for (String otherTrack in _audioTracks) {
                                        if (otherTrack != track) {
                                          _trackVolumes[otherTrack] = 1;
                                        }
                                      }
                                    }
                                    _soloStates[track] = !_soloStates[track]!;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: _soloStates[track] == true
                                      ? Colors.blue
                                      : Colors.transparent,
                                  onPrimary: _soloStates[track] == true
                                      ? Colors.white
                                      : Colors.black,
                                  elevation: 0,
                                  side: BorderSide.none,
                                ),
                                child: Text('S'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Slider(
                        value: _trackVolumes[track]!,
                        min: 0,
                        max: 1,
                        onChanged: (value) =>
                            _updateTrackVolume(index, value), // Pass the index
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyBottomSheet extends StatefulWidget {
  final String selectedOption;
  final int currentBpm;
  final int mediumBpm;
  final Function(String, int) onUpdate;

  MyBottomSheet({
    required this.selectedOption,
    required this.currentBpm,
    required this.mediumBpm,
    required this.onUpdate
  });

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  String selectedOption = 'Medium';
  int bpm = 120;
  double sliderValue = 120.0;
  @override
  void initState() {
    super.initState();
    selectedOption = widget.selectedOption;
    bpm = widget.currentBpm;
    sliderValue = widget.currentBpm.toDouble();
  }
  void _updateValues() {
    setState(() {
      widget.onUpdate(selectedOption, bpm);
    });
  }
  void incrementBpm() {
    setState(() {
      if (bpm < 160) {
        bpm += 10;
        sliderValue = bpm.toDouble();
      }
    });
  }

  void decrementBpm() {
    setState(() {
      if (bpm > 80) {
        bpm -= 10;
        sliderValue = bpm.toDouble();
      }
    });
  }

  void onSliderChanged(double value) {
    setState(() {
      sliderValue = value;
      bpm = value.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
                _updateValues();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary:
                      selectedOption == 'Slow' ? Colors.blue : Colors.white,
                  onPrimary:
                      selectedOption == 'Slow' ? Colors.white : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedOption = 'Slow';
                    sliderValue = 80;
                    bpm = 80;
                    _updateValues();
                  });
                },
                child: Text('Slow'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary:
                      selectedOption == 'Medium' ? Colors.blue : Colors.white,
                  onPrimary:
                      selectedOption == 'Medium' ? Colors.white : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedOption = 'Medium';
                    sliderValue = widget.mediumBpm.toDouble();
                    bpm = widget.mediumBpm;
                  });
                },
                child: Text('Medium'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary:
                      selectedOption == 'Fast' ? Colors.blue : Colors.white,
                  onPrimary:
                      selectedOption == 'Fast' ? Colors.white : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedOption = 'Fast';
                    sliderValue = 160;
                    bpm = 160;
                  });
                },
                child: Text('Fast'),
              ),
            ],
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                ),
                onPressed: decrementBpm,
                child: Icon(Icons.remove),
              ),
              SizedBox(width: 16),
              Text(
                '$bpm BPM',
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                ),
                onPressed: incrementBpm,
                child: Icon(Icons.add),
              ),
            ],
          ),
          Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                children: [
                  Slider(
                    value: sliderValue,
                    min: 80.0,
                    max: 160.0,
                    onChanged: onSliderChanged,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '80',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          '120',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          '160',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
