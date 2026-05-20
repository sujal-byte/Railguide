// ============================================================
// RailGuide — Train Provider
// providers/train_provider.dart
//
// Manages live API state for multiple trains.
// Auto-refreshes every 90 seconds (same as NTES).
// ============================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/train_service.dart';

// Trains to track at Bengaluru City Station (SBC)
// Add/remove train numbers here to customise the dashboard
const List<Map<String, String>> kTrackedTrains = [
  {'number': '12627', 'name': 'Karnataka Express',   'platform': '1'},
  {'number': '16536', 'name': 'Gol Gumbaz Express',  'platform': '2'},
  {'number': '22691', 'name': 'Rajdhani Express',    'platform': '1'},
];

class TrainProvider extends ChangeNotifier {
  // Map of trainNumber → latest result
  final Map<String, TrainApiResult> _results = {};
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  Map<String, TrainApiResult> get results => Map.unmodifiable(_results);
  bool get isRefreshing => _isRefreshing;

  TrainProvider() {
    // Initial fetch on creation
    fetchAll();
    // Auto-refresh every 90 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 90),
      (_) => fetchAll(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ── Fetch all tracked trains ───────────────────────────
  Future<void> fetchAll() async {
    _isRefreshing = true;
    notifyListeners();

    // Mark all as loading
    for (final t in kTrackedTrains) {
      _results[t['number']!] = const TrainApiResult.loading();
    }
    notifyListeners();

    // Fetch in parallel
    await Future.wait(
      kTrackedTrains.map((t) => _fetchOne(t['number']!)),
    );

    _isRefreshing = false;
    notifyListeners();
  }

  // ── Fetch a single train ──────────────────────────────
  Future<void> _fetchOne(String trainNumber) async {
    final result = await TrainService.fetchLiveStatus(
      trainNumber: trainNumber,
    );
    _results[trainNumber] = result;
    notifyListeners();
  }

  // ── Manual refresh for pull-to-refresh ───────────────
  Future<void> refresh() => fetchAll();

  // ── Get result for a specific train ──────────────────
  TrainApiResult? resultFor(String trainNumber) =>
      _results[trainNumber];
}