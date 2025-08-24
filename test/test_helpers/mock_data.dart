class MockData {
  static const String validBusStopsResponse = '''
  [
    {
      "name": "Central Station",
      "lat": 12.9716,
      "lng": 77.5946
    },
    {
      "name": "Bus Terminal",
      "lat": 13.0827,
      "lng": 80.2707
    },
    {
      "name": "Airport",
      "lat": 12.9698,
      "lng": 77.7500
    }
  ]
  ''';

  static const String emptyBusStopsResponse = '[]';

  static const String invalidJsonResponse = 'invalid json data';

  static const String missingFieldsResponse = '''
  [
    {
      "name": "Incomplete Stop"
    },
    {
      "lat": 12.34
    },
    {
      "lng": 56.78
    }
  ]
  ''';

  static const String nullFieldsResponse = '''
  [
    {
      "name": null,
      "lat": null,
      "lng": null
    }
  ]
  ''';

  static const String errorResponse = '''
  {
    "error": "API Error",
    "message": "Failed to fetch bus stops"
  }
  ''';
}
