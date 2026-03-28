import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/station_data.dart';
import '../services/station_service.dart';

// ─── Station Service Provider ──────────────────────────────────
final stationServiceProvider = Provider<StationService>((ref) {
  final service = StationService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ─── Stations List Provider ────────────────────────────────────
/// Async provider that fetches all stations from the backend.
/// Falls back to [dummyStations] on error so the app never shows a blank map.
final stationsProvider =
    AsyncNotifierProvider<StationsNotifier, List<ChargingStation>>(
  StationsNotifier.new,
);

class StationsNotifier extends AsyncNotifier<List<ChargingStation>> {
  @override
  Future<List<ChargingStation>> build() => _fetch();

  Future<List<ChargingStation>> _fetch() async {
    final service = ref.read(stationServiceProvider);
    try {
      return await service.fetchStations();
    } catch (_) {
      // Fallback to hardcoded data if backend is unreachable
      return dummyStations;
    }
  }

  /// Manually refresh the station list (pull-to-refresh, etc.).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ─── Single Station Provider (for polling) ─────────────────────
/// Family provider that fetches a single station by ID.
/// Used by the charging details screen to poll for updates.
final stationDetailProvider = FutureProvider.family<ChargingStation, String>(
  (ref, id) async {
    final service = ref.read(stationServiceProvider);
    return service.fetchStationById(id);
  },
);
