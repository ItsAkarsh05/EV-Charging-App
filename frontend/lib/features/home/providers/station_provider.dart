import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/station_data.dart';
import '../services/station_service.dart';

// station HTTP service — disposed automatically when no longer needed
final stationServiceProvider = Provider<StationService>((ref) {
  final service = StationService();
  ref.onDispose(() => service.dispose());
  return service;
});

// fetches all stations from the backend
final stationsProvider =
    AsyncNotifierProvider<StationsNotifier, List<ChargingStation>>(
  StationsNotifier.new,
);

class StationsNotifier extends AsyncNotifier<List<ChargingStation>> {
  @override
  Future<List<ChargingStation>> build() => _fetch();

  Future<List<ChargingStation>> _fetch() async {
    final service = ref.read(stationServiceProvider);
    return await service.fetchStations();
  }

  // manually trigger a refresh
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

// fetches a single station by id — used for polling on the details screen
final stationDetailProvider = FutureProvider.family<ChargingStation, String>(
  (ref, id) async {
    final service = ref.read(stationServiceProvider);
    return service.fetchStationById(id);
  },
);
