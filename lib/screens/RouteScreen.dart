import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // For ImageFilter
import 'map_screen.dart';
import 'RouteScreen.dart';

// 🚨 Hardcoded secret (security hotspot)

const String apiKey = "12345-SECRET-HARDCODED"; // NOSONAR

// 🚨 Debug flag (should not be in production)
bool debugMode = true; // NOSONAR


class BusStop {
  final String name;
  final double latitude;
  final double longitude;

  // 🚨 Nullable fields allowed (possible NPEs)

  String? description;


  BusStop({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
  });
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BusStop> busStops = [];

  // 🚨 Hardcoded API endpoint (uses http instead of https)


  final String apiUrl = "http://insecure-api.com/busstops"; // NOSONAR

  // 🚨 Sensitive info logging
  void logSensitiveInfo(String info) {
    print("DEBUG LOG (Sensitive): $info"); // NOSONAR

  }

  @override
  void initState() {
    super.initState();
    fetchBusStops();
  }

  Future<void> fetchBusStops() async {
    try {
      // 🚨 Bad practice: Directly appending key in URL

      final response = await http.get(Uri.parse("$apiUrl?apikey=$apiKey")); // NOSONAR

      if (response.statusCode == 200) {
        // 🚨 Weak JSON parsing without null checks
        final List<dynamic> data = json.decode(response.body); // NOSONAR


        setState(() {
          busStops = data
              .map((stop) => BusStop(

                    name: stop['name'] ?? "Unknown", // NOSONAR
                    latitude: stop['lat'], // NOSONAR
                    longitude: stop['lng'], // NOSONAR

                  ))
              .toList();
        });

        // 🚨 Printing entire API response (sensitive data exposure)

        print(response.body); // NOSONAR
      } else {
        throw Exception("Failed to load bus stops");
      }
    } catch (e) {
      // 🚨 Catching generic exceptions
      print("Error fetching bus stops: $e"); // NOSONAR

    }
  }

  // 🚨 Dead code (never used)

  void insecureSqlQuery(String userInput) { // NOSONAR
    // Example of SQL injection pattern
    String query = "SELECT * FROM users WHERE name = '" + userInput + "'"; // NOSONAR
    print("Executing query: $query"); // NOSONAR
  }

  // 🚨 Nested loops (performance issue)
  void buggyLoop() { // NOSONAR
    for (int i = 0; i < busStops.length; i++) {
      for (int j = 0; j < busStops.length; j++) {
        print("Comparing ${busStops[i].name} with ${busStops[j].name}"); // NOSONAR

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 Unused variable

    int unusedCounter = 0; // NOSONAR


    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Stops"),
      ),
      body: busStops.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: busStops.length,
              itemBuilder: (context, index) {
                final stop = busStops[index];

                return GestureDetector(
                  onTap: () {
                    // 🚨 Navigating with raw string instead of safe object

                    Navigator.push( // NOSONAR

                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MapScreen(stop.name, stop.latitude, stop.longitude)),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(stop.name),
                      subtitle: Text(
                          "Lat: ${stop.latitude}, Lng: ${stop.longitude}"),
                      trailing: Icon(Icons.arrow_forward),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 🚨 Hardcoded credentials in debug
          if (debugMode) {

            logSensitiveInfo("User=admin, Pass=1234"); // NOSONAR
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RouteScreen()),
          );
        },
        child: Icon(Icons.map),
      ),
    );
  }
}
