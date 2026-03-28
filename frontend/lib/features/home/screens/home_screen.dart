import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../models/station_data.dart';
import '../providers/station_provider.dart';
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
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
    _createCustomMarker();
  }

  Future<void> _createCustomMarker() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Marker dimensions
    const double markerWidth = 56;
    const double markerHeight = 68;
    const double circleRadius = 22;
    const double circleCenterX = markerWidth / 2;
    const double circleCenterY = 26;
    const double pointerHeight = 8;

    // ── Shadow beneath circle ──
    final shadowPaint = Paint()
      ..color = const Color(0x30000000)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(circleCenterX, circleCenterY + 2),
      circleRadius + 1,
      shadowPaint,
    );

    // ── White outer ring ──
    final outerRingPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(circleCenterX, circleCenterY),
      circleRadius + 2.5,
      outerRingPaint,
    );

    // ── Gradient filled circle ──
    final gradientPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(circleCenterX - 4, circleCenterY - 5),
        circleRadius * 1.2,
        [
          const Color(0xFF3DDC64), // brighter green highlight
          AppColors.primary, // main green
          const Color(0xFF1E9637), // darker green edge
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(
      Offset(circleCenterX, circleCenterY),
      circleRadius,
      gradientPaint,
    );

    // ── Bottom pointer triangle ──
    final pointerPath = Path();
    pointerPath.moveTo(circleCenterX - 7, circleCenterY + circleRadius - 2);
    pointerPath.lineTo(
      circleCenterX,
      circleCenterY + circleRadius + pointerHeight,
    );
    pointerPath.lineTo(circleCenterX + 7, circleCenterY + circleRadius - 2);
    pointerPath.close();

    // White border for pointer
    final pointerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(pointerPath, pointerBorderPaint);

    // Green fill for pointer (slightly inset)
    final pointerFillPath = Path();
    pointerFillPath.moveTo(circleCenterX - 5, circleCenterY + circleRadius - 1);
    pointerFillPath.lineTo(
      circleCenterX,
      circleCenterY + circleRadius + pointerHeight - 2,
    );
    pointerFillPath.lineTo(circleCenterX + 5, circleCenterY + circleRadius - 1);
    pointerFillPath.close();
    final pointerFillPaint = Paint()..color = AppColors.primary;
    canvas.drawPath(pointerFillPath, pointerFillPaint);

    // ── Lightning bolt icon (crisp & centered) ──
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final boltPath = Path();
    // Well-proportioned bolt centered in circle
    const double bx = circleCenterX;
    const double by = circleCenterY;
    boltPath.moveTo(bx + 1, by - 10);
    boltPath.lineTo(bx - 5, by + 1);
    boltPath.lineTo(bx - 1, by + 1);
    boltPath.lineTo(bx - 2, by + 10);
    boltPath.lineTo(bx + 6, by - 1);
    boltPath.lineTo(bx + 2, by - 1);
    boltPath.lineTo(bx + 4, by - 10);
    boltPath.close();
    canvas.drawPath(boltPath, iconPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      markerWidth.toInt(),
      markerHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null && mounted) {
      final icon = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      setState(() {
        _customMarkerIcon = icon;
      });
    }
  }

  void _buildMarkers(List<ChargingStation> stations) {
    _markers = stations.asMap().entries.map((entry) {
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
          // Expand the bottom sheet so the station card is visible
          if (_sheetController.isAttached && _sheetController.size < 0.5) {
            _sheetController.animateTo(
              0.5,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
            );
          }
        },
      );
    }).toSet();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(stationsProvider);

    return stationsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load stations',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(stationsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (stations) {
        // Make sure index is in bounds
        if (_selectedStationIndex >= stations.length) {
          _selectedStationIndex = 0;
        }
        // Build markers from fetched data
        _buildMarkers(stations);
        final selectedStation = stations[_selectedStationIndex];

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
              },
              onCameraIdle: () {
                _mapController?.setMapStyle(mapStyle);
              },
            ),

            // ── Bottom sheet overlay ──
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.55,
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
                            color: AppColors.textTertiary.withValues(
                              alpha: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      // Horizontally scrollable station cards
                      SizedBox(
                        height: 218,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: stations.length,
                          onPageChanged: (index) {
                            setState(() => _selectedStationIndex = index);
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLng(stations[index].location),
                            );
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: StationCard(
                                station: stations[index],
                                onContinue: () {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChargingDetailsScreen(
                                        station: stations[index],
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
      },
    );
  }
}
