import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AdminScreen(),
    );
  }
}

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String latitude = "Unknown";
  String longitude = "Unknown";
  String statusMessage = "Waiting for location updates...";

  Future<void> fetchLatestLocation() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.6:3000/api/location'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          latitude = data['latitude'].toString();
          longitude = data['longitude'].toString();
          statusMessage = "Location updated successfully!";
        });
      } else {
        setState(() {
          statusMessage = 'Failed to fetch location. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error fetching location: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 5), (timer) => fetchLatestLocation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              "Latitude: $latitude",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Longitude: $longitude",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
