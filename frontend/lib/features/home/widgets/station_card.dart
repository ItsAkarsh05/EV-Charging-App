import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/station_data.dart';
import 'package:frontend/features/home/screens/charging_details_screen.dart';

class StationCard extends StatelessWidget {
  final ChargingStation station;
  final VoidCallback? onContinue;

  const StationCard({super.key, required this.station, this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      //    margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Station name + status
            Row(
              children: [
                const Icon(
                  Icons.ev_station_rounded,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    station.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  child: Text(
                    station.isOpen ? 'Open' : 'Closed',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: station.isOpen
                          ? AppColors.primary
                          : AppColors.error,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Address + hours
            SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 28), // indent to align with name
                  Expanded(
                    child: Text(
                      station.address,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(
                    child: Text(
                      station.hours,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            // Connector type label
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Connector type',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Connector badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: station.connectors.map((c) {
                        return _ConnectorBadge(label: c.type.split(' ').last);
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectorBadge extends StatelessWidget {
  final String label;
  const _ConnectorBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              //fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
