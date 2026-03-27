import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/station_data.dart';

class ChargingDetailsScreen extends StatefulWidget {
  final ChargingStation station;

  const ChargingDetailsScreen({super.key, required this.station});

  @override
  State<ChargingDetailsScreen> createState() => _ChargingDetailsScreenState();
}

class _ChargingDetailsScreenState extends State<ChargingDetailsScreen> {
  int _currentImageIndex = 0;
  late final PageController _imagePageController;

  // Use same placeholder image 3 times for carousel demo
  final List<String> _imagePaths = const [
    'assets/images/sample_image1.jpg',
    'assets/images/sample_image2.jpg',
    'assets/images/sample_image3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station;

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
                    // Back button
                    _buildBackButton(),

                    // Station name & address
                    _buildStationHeader(station),

                    const SizedBox(height: 16),

                    // Image carousel
                    _buildImageCarousel(),

                    const SizedBox(height: 24),

                    // Facilities section
                    _buildFacilitiesSection(station),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Station header (name + address)
  // ────────────────────────────────────────────────────────────
  Widget _buildStationHeader(ChargingStation station) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            station.name,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
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
        // Image PageView
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
          // Section header
          Text(
            'Facilities Available',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          // Divider
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),

          // Charge Power
          _FacilityRow(
            icon: Icons.bolt_rounded,
            iconColor: AppColors.textPrimary,
            title: 'Charge Power',
            subtitle:
                '${_formatPower(station.chargePowerMin)} - ${_formatPower(station.chargePowerMax)}',
          ),

          // Open Hours
          _FacilityRow(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.textPrimary,
            title: 'Open Hours',
            subtitle: station.hours,
          ),

          // Distance
          _FacilityRow(
            icon: Icons.map_outlined,
            iconColor: AppColors.textPrimary,
            title: 'Distance',
            subtitle:
                '${station.distanceKm} KM from your location (${station.distanceMin} min)',
          ),

          // Plug Available
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
}

// ══════════════════════════════════════════════════════════════
// Facility Row widget (reusable for each facility item)
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
          // Icon container
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

          // Title + subtitle
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
