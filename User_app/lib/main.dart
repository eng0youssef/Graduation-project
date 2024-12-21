import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String locationMessage = "Press the button to get your location";
  StreamSubscription<Position>? positionStream;
  bool isButtonVisible = true;

  Future<void> sendLocation(Position position) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.6:3000/api/location'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        print('Location sent successfully: ${response.body}');
      } else {
        print('Failed to send location. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  getCurrentLocationApp() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = 'Location services are disabled.';
      });
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = 'Location permissions are permanently denied.';
      });
      return;
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
          (Position? position) {
        setState(() {
          if (position == null) {
            locationMessage = 'Unknown location';
          } else {
            locationMessage =
            'Current Position: ${position.latitude}, ${position.longitude}';
            sendLocation(position);
          }
        });
      },
    );
    setState(() {
      isButtonVisible = false;
    });
  }

  @override
  void dispose() {
    if (positionStream != null) {
      positionStream!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('User App'),
          leading: Icon(Icons.menu),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                locationMessage,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (isButtonVisible)
                ElevatedButton(
                  onPressed: getCurrentLocationApp,
                  child: Text("Start Tracking"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
