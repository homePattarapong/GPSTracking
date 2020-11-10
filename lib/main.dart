import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gsheets/gsheets.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // your google auth credentials
  static const _credentials = r'''
  {
    "type": "service_account",
    "project_id": "gpstracking-295117",
    "private_key_id": "97b74785b26a98f24d28f6ab3e4379b5c592aaf4",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDSOFe6wYFyZ85B\niy335oQKE+8K/b6r8yjgdZMuQ5S853QPOH1b4DApo9OP3TdPonK6yqN0y1sRgnQ/\nBIl6GruXKJpe7uuqHu3TzYIYgyYj7EH32QIFwnGOQRjiD3UYuiob5kXzu0DuPtLX\nqGr41Czf8L6dTNodsix1imZ8AggJEF0BE7otpPiCRrfSQD+9I8TUgjoI25++OyP3\nkjIcjapd2ZqRgc326SFquMNHN5TfkTZQ3hE4dhjoPuILmYg2Hhqhvyln+PZ6dOYN\nTMGiKDuRbhDUEUlw1Te7+fZy3OVZY5L4h6SN/gTSmzkyiShNthiprbMd4KRJXqgL\nf5oW7nVpAgMBAAECggEACAIGcYJKjJGgvUVwgFeDIyEkQ35sA3/VSEuiSipf4ZxN\ngwDrYZMWMpffiMTsBPgSt8PdWycd9npKNFZXaFPZXoY47zHZv1bDR4S2Fnn0e3zV\n/HuDRLXl/n3DVWUyWDlLPlnUw1aYQBsbjASJ4qWuee9hS3uweV4erHGTutiW9sVb\noQfGoWI76TmcsExx0ayPSrEpTTBq5xpxZ/zVi2tss+3HC+wXB5TlY8PH+1l3PC5I\nWh6WidSLCIriQz09cudhg/q2BnbwBAaWfwvw1mw6ofTuMkY2CFxujz6prTzz0C6l\nyTTAIarJuUGd1zlQgzGje1Efg6BBms5tZzl1JoeNowKBgQDn+9TgtVxGxJAY4VMQ\nq7XMaE1fCddoVH8ZZoHiPVptLCz+0mW3+zwWfdafH21fka5DcaQeEjFwP1DHGzUG\nBHwb0Nk2uL0FywEwDjZXAWYKMxGXqy1rSDuY3FNZbjW7HgGzl/aXOV/br8HNx2dm\nEEVR58TKkxhVsSjwsqb6lOl7swKBgQDn+7f8/B4bxnp85+OVfzcCs9aEGxdHtx6V\nrJJvvKVoouJlHyC0jJPfBSstoJdww7UOnruMdeKJ41ZPOT/hmI1+s8CsRTU5wFxu\naECgBBCvK6WfVhHt/oJ0MojVHqJxVQWwbWF9D2i/Jx8JZzgj6XEeBs7uT27qqNGP\nmIo9yQKMcwKBgCBAI2Ul8XEpLHs5AApGRNzo9zCqNpcbgBvw40enjeW1iX/XkiqU\ns9LQpcCzZsotf5OCvfUsRFE9jCZSAvoWL4bSbxAreKPQiBa9MxK/cAck+GIkewj6\nHsbugmvhZXjhAA2Op8p4QHpTIddQzHAk/O4ZEYO0FWL8YRutSod1okv/AoGALfhw\n1l4zrTdgsH3XWJm0EgIHQXiI3XpJQknHXwMYGCsnB/jqJz0wVGKW0tzfBcaSi4oj\nCkuWD9MQGHT01sS/TVtblAfG62HWLz7Th6ImmD/i+zc4KFxmB5a4DNucPy8lCHg0\neG7kR/T9roRY2Kz68INS4GC3TyMTHAyTYHkD20cCgYB8MeCpmR7D2M0kK0yAJ56o\nE1yzsfGxw0A4/aTwgUQ1hyo0/XSxrb1vtNhbimaci00XGR8v4YfIAwpn8FMqmqMG\n+vJIJePwGNRXGs8jhR2XfLvK8uZaPeDNPnpgPJyNESWCoqls7BJOjp6uRFodQ1ru\nH5r0H8oDmm5qW9SxP54ttQ==\n-----END PRIVATE KEY-----\n",
    "client_email": "gsheets@gpstracking-295117.iam.gserviceaccount.com",
    "client_id": "107138534429719761615",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gpstracking-295117.iam.gserviceaccount.com"
  }
  ''';
  static const _spreadsheetId = '17UuEnJDRrjZLce0GODqzsD64AsVbqEoeE40BLPtT4vg';

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
    // init GSheets
    final gsheets = GSheets(_credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(_spreadsheetId);
    // get worksheet by its title
    var sheet = await ss.worksheetByTitle('example');
    // create worksheet if it does not exist yet
    sheet ??= await ss.addWorksheet('example');

    // prints [_index, _letter, _number, _label]
    print(await sheet.values.column(1));

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
    var now = new DateTime.now();
    var recordRow = [
      now.toString(),
      '${position.latitude}',
      '${position.longitude}',
      '${position.latitude}, ${position.longitude}'
    ];

    await sheet.values.appendRow(recordRow);

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
