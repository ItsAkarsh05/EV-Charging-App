import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station_data.dart';

/// HTTP client that fetches charging station data from the Node.js backend.
class StationService {
  // Use 10.0.2.2 for Android emulator (maps to host localhost).
  // For physical devices, replace with your machine's LAN IP.
  // static const String _baseUrl = 'http://10.0.2.2:3000/api';
  static const String _baseUrl = 'http://localhost:3000/api';

  final http.Client _client;

  StationService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all charging stations.
  Future<List<ChargingStation>> fetchStations() async {
    final response = await _client.get(Uri.parse('$_baseUrl/stations'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load stations (${response.statusCode})');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((j) => ChargingStation.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single station by [id] (used for polling).
  Future<ChargingStation> fetchStationById(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/stations/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load station $id (${response.statusCode})');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    return ChargingStation.fromJson(body['data'] as Map<String, dynamic>);
  }

  void dispose() {
    _client.close();
  }
}
