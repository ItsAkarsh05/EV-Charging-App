import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/station_data.dart';

class ConnectorList extends StatelessWidget {
  final ChargingStation station;

  const ConnectorList({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Type Connector',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ],
          ),
        ),
        // Connector items
        ...station.connectors.map(
          (connector) => _ConnectorItem(connector: connector),
        ),
      ],
    );
  }
}

class _ConnectorItem extends StatelessWidget {
  final Connector connector;
  const _ConnectorItem({required this.connector});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300, // The color of the bottom shadow
            blurRadius: 8, // The blur radius of the shadow
            spreadRadius:
                -10.0, // Negative spread radius helps hide unwanted sides
            offset: Offset(
              0.0,
              8.0,
            ), // Positive dy offset moves the shadow down
          ),
        ],
      ),
      child: Row(
        children: [
          // Connector icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textTertiary, width: 0.3),
            ),
            child: const Icon(
              Icons.electrical_services_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Name + type
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Availability
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                connector.isAvailable ? 'Available' : 'In Use',
                style: AppTextStyles.labelSmall.copyWith(
                  color: connector.isAvailable
                      ? AppColors.primary
                      : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (connector.isAvailable)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
