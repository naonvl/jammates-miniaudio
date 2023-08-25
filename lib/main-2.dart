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
  List<String> _audioTracks = ['drum', 'bass', 'piano'];
  Map<String, bool> _soloStates = {};
  Map<String, int> _tempTrackVolumes = {};
  Map<String, int> _trackVolumes = {};
  int _drumVolume = 100;
  int _bassVolume = 100;
  int _pianoVolume = 100;
  int _tempDrumVolume = 100;
  int _tempBassVolume = 100;
  int _tempPianoVolume = 100;
  bool _isDrumSolo = false;
  bool _isBassSolo = false;
  bool _isPianoSolo = false;
  String selectedOption = 'Medium';
  void _togglePlay() {
    if (!_isPlaying) {
      _methodChannel.invokeMethod("playSound", {"text": '=====TEST====='});
    } else {
      _methodChannel.invokeMethod("stopSound", {"text": '=====TEST====='});
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize solo states and track volumes based on _audioTracks
    for (String track in _audioTracks) {
      _soloStates[track] = false;
      _tempTrackVolumes[track] = 100;
      _trackVolumes[track] = 100;
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
      _tempTrackVolumes[trackName] = value.round();
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

  void _updateDrumVolume(double value) {
    setState(() {
      _drumVolume = value.round();
    });
    _methodChannel.invokeMethod("updateDrumVolume", {"volume": _drumVolume});
  }

  void _updateBassVolume(double value) {
    setState(() {
      _bassVolume = value.round();
    });
    _methodChannel.invokeMethod("updateBassVolume", {"volume": _bassVolume});
  }

  void _updatePianoVolume(double value) {
    setState(() {
      _pianoVolume = value.round();
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
                          return MyBottomSheet();
                        },
                      );
                    },
                    child: Text('SET BPM'),
                  )
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Drum',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Row(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_drumVolume == 0) {
                              _drumVolume = _tempDrumVolume;
                            } else {
                              _tempDrumVolume = _drumVolume;
                              _drumVolume = 0;
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: _drumVolume > 0
                              ? Colors.transparent
                              : Colors.blue,
                          onPrimary:
                              _drumVolume > 0 ? Colors.black : Colors.white,
                          elevation: 0,
                          side: BorderSide.none,
                        ),
                        child: Text('M'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // S button logic
                          // Add your code here
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.black,
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
                value: _drumVolume.toDouble(),
                min: 0,
                max: 100,
                onChanged: _updateDrumVolume,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Bass',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Row(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          // M button logic
                          // Add your code here
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.black,
                          elevation: 0,
                          side: BorderSide.none,
                        ),
                        child: Text('M'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // S button logic
                          // Add your code here
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.black,
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
                value: _bassVolume.toDouble(),
                min: 0,
                max: 100,
                onChanged: _updateBassVolume,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Piano',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Row(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          // M button logic
                          // Add your code here
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.black,
                          elevation: 0,
                          side: BorderSide.none,
                        ),
                        child: Text('M'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // S button logic
                          // Add your code here
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.black,
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

class MyBottomSheet extends StatefulWidget {
  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  String selectedOption = 'Medium';
  int bpm = 120;
  double sliderValue = 120.0;

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
                          '100',
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
