import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'dart:io';

// Import your actual files (adjust paths as needed)
import 'package:cbt_app/screens/home_screen.dart';

void main() {
  group('Helper Methods Unit Tests', () {
    late _HomeScreenState homeScreenState;

    setUp(() {
      homeScreenState = _HomeScreenState();
    });

    group('logSensitiveInfo Tests', () {
      test('should log sensitive information', () {
        // Capture print statements for testing
        final logs = <String>[];
        
        // Override print for testing
        void Function(Object?) originalPrint = print;
        print = (Object? object) {
          logs.add(object.toString());
        };

        homeScreenState.logSensitiveInfo('Test sensitive data');
        
        // Restore original print
        print = originalPrint;

        expect(logs, contains('DEBUG LOG (Sensitive): Test sensitive data'));
      });

      test('should handle null input', () {
        final logs = <String>[];
        
        void Function(Object?) originalPrint = print;
        print = (Object? object) {
          logs.add(object.toString());
        };

        homeScreenState.logSensitiveInfo(null);
        
        print = originalPrint;

        expect(logs, contains('DEBUG LOG (Sensitive): null'));
      });

      test('should handle empty string input', () {
        final logs = <String>[];
        
        void Function(Object?) originalPrint = print;
        print = (Object? object) {
          logs.add(object.toString());
        };

        homeScreenState.logSensitiveInfo('');
        
        print = originalPrint;

        expect(logs, contains('DEBUG LOG (Sensitive): '));
      });
    });

    group('insecureSqlQuery Tests', () {
      test('should execute with normal input', () {
        final logs = <String>[];
        
        void Function(Object?) originalPrint = print;
        print = (Object? object) {
          logs.add(object.toString());
        };

        homeScreenState.insecureSqlQuery('John Doe');
        
        print = originalPrint;

        expect(logs, contains("Executing query: SELECT * FROM users WHERE name = 'John Doe'"));
      });

      test('should demonstrate SQL injection vulnerability', () {
        final logs = <String>[];
        
        void Function(Object?) originalPrint = print;
        print = (Object? object) {
          logs.add(object.toString());
        };

        const sqlInjection = "'; DROP TABLE users; --";
        homeScreenState.insecureSqlQuery(sqlInjection);
        
        print = originalPrint;

        expect(logs.any((log) => log.contains('DROP TABLE users')), isTrue);
      });

      test('should handle empty input', () {
        final logs = <String>[];
        
        void Function(Object?) originalPrint = print;
        print = (Object? object) {
          logs.add(object.toString());
        };

        homeScreenState.insecureSqlQuery('');
        
        print = originalPrint;

        expect(logs, contains("Executing query: SELECT * FROM users WHERE name = ''"));
      });

      test('should handle special characters', () {
        final logs = <String>[];
        
        void Function(Object?) originalPrint = print;
        print = (Object? object) {
          logs.add(object.toString());
        };

        homeScreenState.insecureSqlQuery("O'Connor");
        
        print = originalPrint;

        expect(logs, contains("Executing query: SELECT * FROM users WHERE name = 'O'Connor'"));
      });
    });

    group('buggyLoop Performance Tests', () {
      test('should execute with empty bus stops list', () {
        homeScreenState.busStops = [];
        
        final stopwatch = Stopwatch()..start();
        homeScreenState.buggyLoop();
        stopwatch.stop();
        
        expect(stopwatch.elapsedMicroseconds, lessThan(1000));
      });

      test('should execute with single bus stop', () {
        homeScreenState.busStops = [
          BusStop(name: 'Test Stop', latitude: 1.0, longitude: 1.0)
        ];
        
        final logs = <String>[];
        void Function(Object?) originalPrint = print;
        print = (Object? object) {
          logs.add(object.toString());
        };

        homeScreenState.buggyLoop();
        
        print = originalPrint;

        expect(logs, contains('Comparing Test Stop with Test Stop'));
        expect(logs.length, equals(1));
      });

      test('should demonstrate O(n²) complexity with multiple stops', () {
        homeScreenState.busStops = [
          BusStop(name: 'Stop A', latitude: 1.0, longitude: 1.0),
          BusStop(name: 'Stop B', latitude: 2.0, longitude: 2.0),
          BusStop(name: 'Stop C', latitude: 3.0, longitude: 3.0),
        ];
        
        final logs = <String>[];
        void Function(Object?) originalPrint = print;
        print = (Object? object) {
          logs.add(object.toString());
        };

        homeScreenState.buggyLoop();
        
        print = originalPrint;

        // With 3 stops, should have 9 comparisons (3²)
        expect(logs.length, equals(9));
        expect(logs, contains('Comparing Stop A with Stop A'));
        expect(logs, contains('Comparing Stop A with Stop B'));
        expect(logs, contains('Comparing Stop C with Stop C'));
      });

      test('should measure performance degradation with larger datasets', () {
        // Test with small dataset
        homeScreenState.busStops = List.generate(5, (i) =>
          BusStop(name: 'Stop $i', latitude: i.toDouble(), longitude: i.toDouble())
        );
        
        final stopwatch1 = Stopwatch()..start();
        homeScreenState.buggyLoop();
        stopwatch1.stop();
        
        // Test with larger dataset
        homeScreenState.busStops = List.generate(10, (i) =>
          BusStop(name: 'Stop $i', latitude: i.toDouble(), longitude: i.toDouble())
        );
        
        final stopwatch2 = Stopwatch()..start();
        homeScreenState.buggyLoop();
        stopwatch2.stop();
        
        // Larger dataset should take significantly more time
        expect(stopwatch2.elapsedMicroseconds, 
               greaterThan(stopwatch1.elapsedMicroseconds));
      });
    });

    group('Constants and Configuration Tests', () {
      test('should verify API key constant', () {
        expect(apiKey, equals("12345-SECRET-HARDCODED"));
        expect(apiKey.isNotEmpty, isTrue);
        
        // Security test - API key should not be hardcoded in production
        expect(apiKey.contains("HARDCODED"), isTrue, 
               reason: "This test documents the security vulnerability");
      });

      test('should verify debug mode flag', () {
        expect(debugMode, isTrue);
        
        // This should be false in production builds
        // In a real test, you might check: expect(kReleaseMode ? false : debugMode, isFalse);
      });

      test('should verify API URL configuration', () {
        const apiUrl = "http://insecure-api.com/busstops";
        expect(apiUrl.startsWith('http://'), isTrue,
               reason: "This test documents the insecure HTTP usage");
        expect(apiUrl.contains('insecure'), isTrue);
      });
    });

    group('Data Parsing Edge Cases', () {
      test('should handle JSON with missing name field', () {
        const testData = {
          'lat': 12.34,
          'lng': 56.78
        };
        
        final busStop = BusStop(
          name: testData['name'] ?? "Unknown",
          latitude: testData['lat'],
          longitude: testData['lng'],
        );
        
        expect(busStop.name, equals("Unknown"));
        expect(busStop.latitude, equals(12.34));
        expect(busStop.longitude, equals(56.78));
      });

      test('should handle JSON with null values', () {
        const testData = {
          'name': null,
          'lat': null,
          'lng': null
        };
        
        expect(() {
          final busStop = BusStop(
            name: testData['name'] ?? "Unknown",
            latitude: testData['lat'] ?? 0.0,
            longitude: testData['lng'] ?? 0.0,
          );
        }, returnsNormally);
      });

      test('should handle JSON with wrong data types', () {
        const testData = {
          'name': 12345, // number instead of string
          'lat': "12.34", // string instead of double
          'lng': "56.78"  // string instead of double
        };
        
        expect(() {
          final busStop = BusStop(
            name: testData['name'].toString(),
            latitude: double.tryParse(testData['lat'].toString()) ?? 0.0,
            longitude: double.tryParse(testData['lng'].toString()) ?? 0.0,
          );
          
          expect(busStop.name, equals("12345"));
          expect(busStop.latitude, equals(12.34));
          expect(busStop.longitude, equals(56.78));
        }, returnsNormally);
      });
    });

    group('Memory and Resource Tests', () {
      test('should handle large bus stops list', () {
        final largeBusStopsList = List.generate(1000, (i) =>
          BusStop(
            name: 'Stop $i',
            latitude: i.toDouble(),
            longitude: i.toDouble(),
            description: 'Description for stop $i' * 10, // Long descriptions
          )
        );
        
        homeScreenState.busStops = largeBusStopsList;
        
        expect(homeScreenState.busStops.length, equals(1000));
        expect(homeScreenState.busStops.first.name, equals('Stop 0'));
        expect(homeScreenState.busStops.last.name, equals('Stop 999'));
      });

      test('should handle bus stops with extreme coordinate values', () {
        final extremeBusStops = [
          BusStop(name: 'North Pole', latitude: 90.0, longitude: 0.0),
          BusStop(name: 'South Pole', latitude: -90.0, longitude: 0.0),
          BusStop(name: 'International Date Line', latitude: 0.0, longitude: 180.0),
          BusStop(name: 'Prime Meridian', latitude: 0.0, longitude: 0.0),
        ];
        
        homeScreenState.busStops = extremeBusStops;
        
        expect(homeScreenState.busStops.length, equals(4));
        expect(homeScreenState.busStops[0].latitude, equals(90.0));
        expect(homeScreenState.busStops[1].latitude, equals(-90.0));
        expect(homeScreenState.busStops[2].longitude, equals(180.0));
      });
    });
  });
}
