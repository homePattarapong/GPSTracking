import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _counter = 10;
  Timer _timer;
  bool _isStart = false;
  String _buttonText = "Start";

  void _startTime() {
    if (!_isStart) {
      _isStart = true;
      _counter = 10;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _buttonText = "Stop";
          if (_counter > 0) {
            _counter--;
          } else {
            _getCurrentLocation();
            _counter = 10;
            // _timer.cancel();
          }
        });
      });
    } else {
      
      _isStart = false;
      setState(() {
        _buttonText = "Start";
      });
      _timer.cancel();
      _locationMessage = "";
    }
  }

  String _locationMessage = "";

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);

    setState(() {
      _locationMessage += "${position.latitude}, ${position.longitude}\n";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Location Services'),
          ),
          body: SingleChildScrollView(
            child: Align(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                      onPressed: () {
                        _startTime();
                      },
                      color: Colors.green,
                      child: Text(_buttonText)),
                  Center(child: Text(_locationMessage)),
                  
                ],
              ),
            ),
          )),
    );
  }
}
