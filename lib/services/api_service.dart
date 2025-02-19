import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  List<Map<String, dynamic>> _busStops = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchBusStops();
  }

  Future<void> _fetchBusStops() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/bus_stops'));


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _busStops = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load bus stops');
      }
    } catch (e) {
      print('Error fetching bus stops: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ahmedabad City Bus Routes"), backgroundColor: Colors.indigoAccent),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(center: LatLng(23.0225, 72.5714), zoom: 12.0),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _busStops.map((stop) {
              return Marker(
                width: 120.0,
                height: 50.0,
                point: LatLng(stop['coordinates']['coordinates'][1], stop['coordinates']['coordinates'][0]),
                builder: (ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))],
                      ),
                      child: Text(stop['stop_name'], style: TextStyle(color: Colors.black, fontSize: 12.0)),
                    ),
                    Icon(Icons.location_on, color: Colors.red, size: 30),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
