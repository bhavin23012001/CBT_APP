import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TripsRoutesPage extends StatefulWidget {
  @override
  _TripsRoutesPageState createState() => _TripsRoutesPageState();
}

class _TripsRoutesPageState extends State<TripsRoutesPage> {
  int? expandedIndex;
  List<dynamic> busRoutes = [];

  @override
  void initState() {
    super.initState();
    fetchBusRoutes();
  }

  Future<void> fetchBusRoutes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/bus_routes'));
    if (response.statusCode == 200) {
      setState(() {
        busRoutes = json.decode(response.body);
      });
    } else {
      throw Exception('FAILED TO LOAD BUS ROUTES');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/d.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.grey.withOpacity(0.85),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'backButton',
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: busRoutes.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: busRoutes.length,
                  itemBuilder: (context, index) {
                    var route = busRoutes[index];
                    bool isExpanded = expandedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          expandedIndex = isExpanded ? null : index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red.shade900, Colors.orange],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.5),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: Text(
                                  (route['busName'] ?? 'UNKNOWN').toString().toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              title: Text(
                                "ROUTE ${route['routeNumber'] ?? 'UNKNOWN'}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${(route['startPoint'] ?? 'UNKNOWN').toString().toUpperCase()} ➝ ${(route['endPoint'] ?? 'UNKNOWN').toString().toUpperCase()}",
                                style: TextStyle(color: Colors.black54),
                              ),
                              trailing: Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                            AnimatedSize(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: isExpanded && route['stops'] != null
                                  ? Column(
                                children: (route['stops'] as List<dynamic>).map<Widget>((stop) {
                                  return ListTile(
                                    leading: _buildLocationIcon(),
                                    title: Text(
                                      (stop['name'] ?? 'UNKNOWN STOP').toString().toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "ARRIVAL: ${(stop['arrival'] ?? '--')} | DEPARTURE: ${(stop['departure'] ?? '--')}",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  );
                                }).toList(),
                              )
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationIcon() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(Icons.location_on, color: Colors.white, size: 20),
    );
  }
}