import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/station_data.dart';

/// HTTP client that fetches charging station data from the Node.js backend.
class StationService {
  // ── Backend URL ───────────────────────────────────────────────
  // Run: adb reverse tcp:3000 tcp:3000  →  then localhost works on any device
  // static const String _baseUrl = 'http://10.0.2.2:3000/api';      // emulator only
  // static const String _baseUrl = 'http://192.168.29.86:3000/api'; // same-WiFi device
  static const String _baseUrl = 'http://localhost:3000/api';         // adb reverse

  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  StationService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all charging stations.
  Future<List<ChargingStation>> fetchStations() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/stations'))
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw HttpException(
          'Server returned ${response.statusCode}',
          uri: Uri.parse('$_baseUrl/stations'),
        );
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>?;
      if (data == null) {
        throw const FormatException('Missing "data" field in response');
      }

      return data
          .map((j) => ChargingStation.fromJson(j as Map<String, dynamic>))
          .toList();
    } on SocketException catch (e) {
      debugPrint('Network error fetching stations: $e');
      throw Exception('Cannot reach the server. Check your connection.');
    } on HttpException catch (e) {
      debugPrint('HTTP error fetching stations: $e');
      throw Exception('Server error: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('Parse error fetching stations: $e');
      throw Exception('Invalid response from server.');
    }
    // TimeoutException and other errors propagate naturally
  }

  /// Fetch a single station by [id] (used for polling).
  Future<ChargingStation> fetchStationById(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/stations/$id'))
          .timeout(_timeout);

      if (response.statusCode == 404) {
        throw Exception('Station not found');
      }
      if (response.statusCode != 200) {
        throw HttpException(
          'Server returned ${response.statusCode}',
          uri: Uri.parse('$_baseUrl/stations/$id'),
        );
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const FormatException('Missing "data" field in response');
      }

      return ChargingStation.fromJson(data);
    } on SocketException catch (e) {
      debugPrint('Network error fetching station $id: $e');
      throw Exception('Cannot reach the server. Check your connection.');
    } on HttpException catch (e) {
      debugPrint('HTTP error fetching station $id: $e');
      throw Exception('Server error: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('Parse error fetching station $id: $e');
      throw Exception('Invalid response from server.');
    }
  }

  void dispose() {
    _client.close();
  }
}
