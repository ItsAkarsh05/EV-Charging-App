import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChargingStation {
  final String id;
  final String name;
  final String address;
  final String hours;
  final bool isOpen;
  final LatLng location;
  final List<Connector> connectors;

  const ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.hours,
    required this.isOpen,
    required this.location,
    required this.connectors,
  });
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
}

// Dummy data for UI demonstration
final List<ChargingStation> dummyStations = [
  ChargingStation(
    id: '1',
    name: 'Purwokerto Core Station',
    address: 'Jl. Di Panjaitan no. 3, Purwokerto Selatan',
    hours: '09.00 - 24.00',
    isOpen: true,
    location: const LatLng(28.6139, 77.2090),
    connectors: const [
      Connector(id: 'c1', name: 'Connector XY1', type: 'Type D CCS5-2', isAvailable: true),
      Connector(id: 'c2', name: 'Connector CCD6', type: 'Type D CC09-2', isAvailable: true),
    ],
  ),
  ChargingStation(
    id: '2',
    name: 'Green Charge Hub',
    address: 'Connaught Place, New Delhi',
    hours: '06.00 - 23.00',
    isOpen: true,
    location: const LatLng(28.6280, 77.2197),
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
    connectors: const [
      Connector(id: 'c5', name: 'Connector FT3', type: 'Type D CCS5-2', isAvailable: true),
      Connector(id: 'c6', name: 'Connector BHA-98', type: 'CHAdeMO', isAvailable: true),
      Connector(id: 'c7', name: 'Connector SL1', type: 'Type 2 AC', isAvailable: false),
    ],
  ),
];
