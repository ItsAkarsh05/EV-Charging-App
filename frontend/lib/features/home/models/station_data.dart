import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChargingStation {
  final String id;
  final String name;
  final String address;
  final String hours;
  final bool isOpen;
  final LatLng location;
  final List<Connector> connectors;
  final double chargePowerMin;
  final double chargePowerMax;
  final double distanceKm;
  final int distanceMin;
  final int plugCount;
  final String imageUrl;

  const ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.hours,
    required this.isOpen,
    required this.location,
    required this.connectors,
    this.chargePowerMin = 12000,
    this.chargePowerMax = 15000,
    this.distanceKm = 1.6,
    this.distanceMin = 12,
    this.plugCount = 8,
    this.imageUrl = '',
  });

  /// Create a ChargingStation from a JSON map returned by the backend.
  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    return ChargingStation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      hours: json['hours'] as String,
      isOpen: json['isOpen'] as bool? ?? true,
      location: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      connectors: (json['connectors'] as List<dynamic>)
          .map((c) => Connector.fromJson(c as Map<String, dynamic>))
          .toList(),
      chargePowerMin: (json['chargePowerMin'] as num?)?.toDouble() ?? 12000,
      chargePowerMax: (json['chargePowerMax'] as num?)?.toDouble() ?? 15000,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.6,
      distanceMin: (json['distanceMin'] as num?)?.toInt() ?? 12,
      plugCount: (json['plugCount'] as num?)?.toInt() ?? 8,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

class Connector {
  final String id;
  final String name;
  final String type;
  final bool isAvailable;

  const Connector({
    required this.id,
    required this.name,
    required this.type,
    required this.isAvailable,
  });

  factory Connector.fromJson(Map<String, dynamic> json) {
    return Connector(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      isAvailable: json['isAvailable'] as bool? ?? false,
    );
  }
}

// Dummy data kept as offline fallback
final List<ChargingStation> dummyStations = [
  ChargingStation(
    id: '1',
    name: 'Purwokerto Core Station',
    address: 'Jl. Di Panjaitan no. 3, Purwokerto Selatan',
    hours: '09.00 PM – 12.00 PM',
    isOpen: true,
    location: const LatLng(28.6139, 77.2090),
    chargePowerMin: 12000,
    chargePowerMax: 15000,
    distanceKm: 1.6,
    distanceMin: 12,
    plugCount: 8,
    connectors: const [
      Connector(id: 'c1', name: 'Connector XY1', type: 'Type D CCS5-2', isAvailable: true),
      Connector(id: 'c2', name: 'Connector CCD6', type: 'Type D CC09-2', isAvailable: true),
    ],
  ),
  ChargingStation(
    id: '2',
    name: 'Green Charge Hub',
    address: 'Connaught Place, New Delhi',
    hours: '06.00 AM – 11.00 PM',
    isOpen: true,
    location: const LatLng(28.6280, 77.2197),
    chargePowerMin: 10000,
    chargePowerMax: 22000,
    distanceKm: 3.2,
    distanceMin: 18,
    plugCount: 12,
    connectors: const [
      Connector(id: 'c3', name: 'Connector AB2', type: 'Type 2 AC', isAvailable: true),
      Connector(id: 'c4', name: 'Connector DC1', type: 'CCS2 DC', isAvailable: false),
    ],
  ),
  ChargingStation(
    id: '3',
    name: 'EV Power Station',
    address: 'Karol Bagh, New Delhi',
    hours: '24 Hours',
    isOpen: true,
    location: const LatLng(28.6519, 77.1909),
    chargePowerMin: 15000,
    chargePowerMax: 20000,
    distanceKm: 5.1,
    distanceMin: 25,
    plugCount: 6,
    connectors: const [
      Connector(id: 'c5', name: 'Connector FT3', type: 'Type D CCS5-2', isAvailable: true),
      Connector(id: 'c6', name: 'Connector BHA-98', type: 'CHAdeMO', isAvailable: true),
    ],
  ),
];
