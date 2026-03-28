import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/station_data.dart';
import '../providers/station_provider.dart';

class ChargingDetailsScreen extends ConsumerStatefulWidget {
  final ChargingStation station;

  const ChargingDetailsScreen({super.key, required this.station});

  @override
  ConsumerState<ChargingDetailsScreen> createState() =>
      _ChargingDetailsScreenState();
}

class _ChargingDetailsScreenState extends ConsumerState<ChargingDetailsScreen> {
  int _currentImageIndex = 0;
  late final PageController _imagePageController;
  late ChargingStation _station;

  // Polling
  Timer? _pollTimer;
  DateTime? _lastUpdated;
  int _pollFailures = 0;
  static const _pollInterval = Duration(seconds: 30);

  final List<String> _imagePaths = const [
    'assets/images/sample_image1.jpg',
    'assets/images/sample_image2.jpg',
    'assets/images/sample_image3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _station = widget.station;
    _lastUpdated = DateTime.now();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollStation());
  }

  Future<void> _pollStation() async {
    try {
      final service = ref.read(stationServiceProvider);
      final updated = await service.fetchStationById(_station.id);
      if (mounted) {
        setState(() {
          _station = updated;
          _lastUpdated = DateTime.now();
          _pollFailures = 0;
        });
      }
    } catch (_) {
      // Keep showing last data, but track failures for indicator
      if (mounted) {
        setState(() => _pollFailures++);
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final station = _station;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button + save button
                    Row(
                      children: [
                        _buildBackButton(),
                        Spacer(),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),

                            child: const Icon(
                              Icons.bookmark_border_outlined,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            // TODO: save
                          },
                        ),
                      ],
                    ),

                    // Station name & address
                    _buildStationHeader(station),

                    const SizedBox(height: 16),

                    // Image carousel
                    _buildImageCarousel(),

                    const SizedBox(height: 24),

                    // Facilities section
                    _buildFacilitiesSection(station),

                    const SizedBox(height: 16),

                    // Connectors section with live status
                    _buildConnectorsSection(station),

                    const SizedBox(height: 8),

                    // Last updated indicator
                    if (_lastUpdated != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              _pollFailures >= 2
                                  ? Icons.cloud_off_rounded
                                  : Icons.circle,
                              size: _pollFailures >= 2 ? 14 : 8,
                              color: _pollFailures >= 2
                                  ? AppColors.warning
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _pollFailures >= 2
                                    ? 'Connection lost · last update ${_formatTime(_lastUpdated!)}'
                                    : 'Live · updates every 30s · ${_formatTime(_lastUpdated!)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: _pollFailures >= 2
                                      ? AppColors.warning
                                      : AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Get directions button pinned at bottom ──
            _buildGetDirectionsButton(),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Back button
  // ────────────────────────────────────────────────────────────
  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textPrimary,
              size: 26,
            ),
            const SizedBox(width: 2),
            Text(
              'Back',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Station header (name + address + status badge)
  // ────────────────────────────────────────────────────────────
  Widget _buildStationHeader(ChargingStation station) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  station.name,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: station.isOpen
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  station.isOpen ? 'Open' : 'Closed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: station.isOpen ? AppColors.primary : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            station.address,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Image carousel with dot indicators
  // ────────────────────────────────────────────────────────────
  Widget _buildImageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _imagePageController,
            itemCount: _imagePaths.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _imagePaths[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_imagePaths.length, (index) {
            final isActive = index == _currentImageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 10 : 8,
              height: isActive ? 10 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textTertiary.withOpacity(0.4),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  // Facilities Available section
  // ────────────────────────────────────────────────────────────
  Widget _buildFacilitiesSection(ChargingStation station) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Facilities Available',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),

          _FacilityRow(
            icon: Icons.bolt_rounded,
            iconColor: AppColors.textPrimary,
            title: 'Charge Power',
            subtitle:
                '${_formatPower(station.chargePowerMin)} - ${_formatPower(station.chargePowerMax)}',
          ),
          _FacilityRow(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.textPrimary,
            title: 'Open Hours',
            subtitle: station.hours,
          ),
          _FacilityRow(
            icon: Icons.map_outlined,
            iconColor: AppColors.textPrimary,
            title: 'Distance',
            subtitle:
                '${station.distanceKm} KM from your location (${station.distanceMin} min)',
          ),
          _FacilityRow(
            icon: Icons.electrical_services_rounded,
            iconColor: AppColors.textPrimary,
            title: 'Plug Available',
            subtitle: '${station.plugCount} Plug available ready to use',
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Connectors section (live-updated via polling)
  // ────────────────────────────────────────────────────────────
  Widget _buildConnectorsSection(ChargingStation station) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connectors',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),
          ...station.connectors.map((c) => _ConnectorRow(connector: c)),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Get directions button
  // ────────────────────────────────────────────────────────────
  Widget _buildGetDirectionsButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // TODO: launch maps / directions
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Get directions',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────
  String _formatPower(double volts) {
    if (volts >= 1000) {
      final formatted = (volts / 1000).toStringAsFixed(3);
      return '${formatted}V';
    }
    return '${volts.toStringAsFixed(0)}V';
  }

  String _formatTime(DateTime dt) {
    int h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';

    if (h == 0) {
      h = 12;
    } else if (h > 12) {
      h -= 12;
    }

    final hStr = h.toString().padLeft(2, '0');
    return '$hStr:$m:$s $period';
  }
}

// ══════════════════════════════════════════════════════════════
// Facility Row widget
// ══════════════════════════════════════════════════════════════
class _FacilityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FacilityRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Connector Row widget (shows live availability)
// ══════════════════════════════════════════════════════════════
class _ConnectorRow extends StatelessWidget {
  final Connector connector;

  const _ConnectorRow({required this.connector});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  (connector.isAvailable ? AppColors.primary : AppColors.error)
                      .withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.power_rounded,
              color: connector.isAvailable
                  ? AppColors.primary
                  : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connector.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  connector.type,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: connector.isAvailable
                  ? AppColors.primary.withOpacity(0.10)
                  : AppColors.error.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              connector.isAvailable ? 'Available' : 'In Use',
              style: AppTextStyles.bodySmall.copyWith(
                color: connector.isAvailable
                    ? AppColors.primary
                    : AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
