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
  bool _isFirstPlaying = true;
  bool isInitialized = false;
  bool _isDownloading = true;
  List<String> _audioTracks = ['drum', 'bass', 'piano'];
  List<String> _audioPaths = [];
  Map<String, bool> _soloStates = {};
  Map<String, double> _tempTrackVolumes = {};
  Map<String, double> _trackVolumes = {};
  String selectedOption = 'medium';
  int _currentBpm = 100;
  double _currentPitch = 1.0;
  int _mediumBpm = 100;
  int _slowBpm = 90;
  int _fastBpm = 120;

  void _togglePlay() {
    if (_isFirstPlaying && !_isPlaying) {
      _methodChannel.invokeMethod("playSound");
      setState(() {
        _isFirstPlaying = false;
      });
    } else if (!_isFirstPlaying && !_isPlaying) {
      _methodChannel.invokeMethod("resumeSound");
    } else if (!_isFirstPlaying && _isPlaying) {
      _methodChannel.invokeMethod("pauseSound");
    } else {
      _methodChannel.invokeMethod("stopSound");
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  bool isInitPlayerInvoked = false;

  @override
  void initState() {
    super.initState();
    if (!isInitialized) {
      isInitialized = true;
      initPlayer().then((value) {
        if (!isInitPlayerInvoked) {
          downloadAndInitializePlayer(selectedOption).then((_) {
            print('====== STARTED ======');
            setState(() {
              _isDownloading = false;
              isInitPlayerInvoked = true;
            });
            _methodChannel.invokeMethod("initPlayer",
                {"audioTracks": _audioTracks, "tempo": selectedOption[0]});
          });
        }
      });
    }
  }

  Future<void> downloadAndInitializePlayer(String selectedOption) async {
    List<String> tracksToDownload = [];

    for (String track in _audioTracks) {
      if (!_audioPaths.contains(track + "-" + selectedOption[0] + '.mp3')) {
        tracksToDownload.add(track);
      }
    }

    List<String> paths =
        await Future.wait(tracksToDownload.map((track) => downloadAndSaveFile(
              'https://raw.githubusercontent.com/naonvl/vespa%2Dconfigurator%2Dplaycanvas/main/' +
                  track +
                  "-" +
                  selectedOption[0] +
                  '.mp3',
              track + "-" + selectedOption[0] + '.mp3',
            )));

    _audioPaths.addAll(paths);
    setState(() {
      _isDownloading = false;
    });
  }

  Future initPlayer() async {
    for (String track in _audioTracks) {
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
    super.dispose();
  }

  void _updateTrackVolume(int index, double value) {
    String trackName = _audioTracks[index];
    setState(() {
      _trackVolumes[trackName] = value;
    });
    _methodChannel.invokeMethod("updateVolume", {
      "volume": _trackVolumes[trackName],
      "trackName": trackName,
      "index": index,
      "tempo": selectedOption[0]
    });
  }

  void _setSolo(String track) {
    setState(() {
      if (_soloStates[track] == false) {
        _trackVolumes[track] = 1;
        for (int index = 0; index < _audioTracks.length; index++) {
          String otherTrack = _audioTracks[index];
          if (otherTrack != track) {
            _soloStates[otherTrack] = false;
            _tempTrackVolumes[otherTrack] = _trackVolumes[otherTrack]!;
            _trackVolumes[otherTrack] = 0;
            _methodChannel.invokeMethod("updateVolume", {
              "volume": _trackVolumes[otherTrack],
              "trackName": otherTrack,
              "tempo": selectedOption[0],
              "index": index, // Add index parameter
            });
          } else {
            _methodChannel.invokeMethod("updateVolume", {
              "volume": _trackVolumes[track],
              "trackName": track,
              "tempo": selectedOption[0],
              "index": index, // Add index parameter
            });
          }
        }
      } else {
        for (int index = 0; index < _audioTracks.length; index++) {
          String otherTrack = _audioTracks[index];
          if (otherTrack != track) {
            _trackVolumes[otherTrack] = 1;
            _methodChannel.invokeMethod("updateVolume", {
              "volume": _trackVolumes[otherTrack],
              "trackName": otherTrack,
              "tempo": selectedOption[0],
              "index": index, // Add index parameter
            });
          }
        }
      }
      _soloStates[track] = !_soloStates[track]!;
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
              _isDownloading
                  ? Container(
                      width: double.infinity,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 20,
                          ),
                          Text('LOADING MP3 FILES'),
                        ],
                      ),
                    )
                  : Row(
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
                                  onUpdate: (newOption, newBpm) {
                                    if (_currentBpm != newBpm) {
                                      double newPitch = newBpm / _mediumBpm;
                                      setState(() {
                                        _currentBpm = newBpm;
                                        _currentPitch = newPitch;
                                      });
                                      _methodChannel.invokeMethod(
                                          "setPitch", {"pitch": newPitch});
                                    }
                                    if (selectedOption != newOption) {
                                      setState(() {
                                        selectedOption = newOption;
                                        _isDownloading = true;
                                        _methodChannel
                                            .invokeMethod("stopAudio");
                                        downloadAndInitializePlayer(newOption)
                                            .then((_) {
                                          setState(() {
                                            _isDownloading = false;
                                            if (newOption == 'slow') {
                                              _currentBpm = _slowBpm;
                                            } else if (newOption == 'medium') {
                                              _currentBpm = _mediumBpm;
                                            } else {
                                              _currentBpm = _fastBpm;
                                            }
                                          });
                                          _methodChannel.invokeMethod(
                                              "initPlayer", {
                                            "audioTracks": _audioTracks,
                                            "tempo": newOption[0]
                                          });
                                        });
                                      });
                                    }
                                    ;
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
                            track,
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
                                      _methodChannel.invokeMethod(
                                          "updateVolume", {
                                        "volume": _trackVolumes[track],
                                        "trackName": track,
                                        "tempo": selectedOption[0]
                                      });
                                    } else {
                                      _tempTrackVolumes[track] =
                                          _trackVolumes[track]!;
                                      _trackVolumes[track] = 0;
                                      _methodChannel.invokeMethod(
                                          "updateVolume", {
                                        "volume": 0,
                                        "trackName": track,
                                        "tempo": selectedOption[0]
                                      });
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
                                  _setSolo(track);
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
                        onChanged: (value) => _updateTrackVolume(index, value),
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
  final Function(String, int) onUpdate;

  MyBottomSheet(
      {required this.selectedOption,
      required this.currentBpm,
      required this.onUpdate});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  String selectedOption = 'medium';
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
                      selectedOption == 'slow' ? Colors.blue : Colors.white,
                  onPrimary:
                      selectedOption == 'slow' ? Colors.white : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedOption = 'slow';
                    sliderValue = widget.currentBpm.toDouble();
                    bpm = widget.currentBpm;
                  });
                },
                child: Text('slow'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary:
                      selectedOption == 'medium' ? Colors.blue : Colors.white,
                  onPrimary:
                      selectedOption == 'medium' ? Colors.white : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedOption = 'medium';
                    sliderValue = widget.currentBpm.toDouble();
                    bpm = widget.currentBpm;
                  });
                },
                child: Text('medium'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary:
                      selectedOption == 'fast' ? Colors.blue : Colors.white,
                  onPrimary:
                      selectedOption == 'fast' ? Colors.white : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedOption = 'fast';
                    sliderValue = widget.currentBpm.toDouble();
                    bpm = widget.currentBpm;
                  });
                },
                child: Text('fast'),
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
