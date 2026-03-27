import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../models/station_data.dart';
import '../widgets/station_card.dart';
import '../screens/charging_details_screen.dart';
import '../widgets/connector_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  int _selectedStationIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.88);
  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
    _createCustomMarker();
  }

  Future<void> _createCustomMarker() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(48, 48);

    // Green circle
    final paint = Paint()..color = AppColors.primary;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 1.5,
      borderPaint,
    );

    // Lightning bolt icon (⚡)
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(26, 10);
    path.lineTo(18, 25);
    path.lineTo(23, 25);
    path.lineTo(21, 38);
    path.lineTo(32, 21);
    path.lineTo(27, 21);
    path.lineTo(30, 10);
    path.close();
    canvas.drawPath(path, iconPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null && mounted) {
      final icon = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      setState(() {
        _customMarkerIcon = icon;
        _buildMarkers();
      });
    }
  }

  void _buildMarkers() {
    _markers = dummyStations.asMap().entries.map((entry) {
      final index = entry.key;
      final station = entry.value;
      return Marker(
        markerId: MarkerId(station.id),
        position: station.location,
        icon:
            _customMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () {
          setState(() => _selectedStationIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(station.location),
          );
        },
      );
    }).toSet();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = dummyStations[_selectedStationIndex];

    return Stack(
      children: [
        // ── Google Map ──
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(28.6139, 77.2090),
            zoom: 13,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _mapController!.setMapStyle(mapStyle);
            if (_markers.isEmpty) _buildMarkers();
          },
          onCameraIdle: () {
            _mapController?.setMapStyle(mapStyle);
          },
        ),

        // ── Bottom sheet overlay ──
        DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          builder: (context, scrollController) {
            return Container(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Horizontally scrollable station cards
                  SizedBox(
                    height: 218,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: dummyStations.length,
                      onPageChanged: (index) {
                        setState(() => _selectedStationIndex = index);
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(dummyStations[index].location),
                        );
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: StationCard(
                            station: dummyStations[index],
                            onContinue: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => ChargingDetailsScreen(
                                    station: dummyStations[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Connector list for selected station
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 16,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ConnectorList(station: selectedStation),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
