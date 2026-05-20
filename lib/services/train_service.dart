// ============================================================
// RailGuide — Train Service
// services/train_service.dart
//
// Uses indianrailapi.com FREE test account API
//
// HOW TO GET YOUR FREE API KEY:
//  1. Go to https://indianrailapi.com/register
//  2. Register with email — API key appears immediately
//  3. Replace YOUR_API_KEY_HERE below with your key
//  4. Free test account works for development (3 months)
//
// API endpoint used:
//  GET indianrailapi.com/api/v2/livetrainstatus/apikey/{key}/trainnumber/{no}/date/{yyyymmdd}/
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ── PASTE YOUR FREE API KEY HERE ──────────────────────────
// Register at: https://indianrailapi.com/register
const String _kApiKey = 'YOUR_API_KEY_HERE';

// ──────────────────────────────────────────────────────────
// Live Train Model
// ──────────────────────────────────────────────────────────
class LiveTrainInfo {
  final String trainNumber;
  final String trainName;
  final String currentStation;
  final String currentStationCode;
  final String scheduleArrival;
  final String actualArrival;
  final String delayInArrival;
  final String scheduleDeparture;
  final String actualDeparture;
  final String delayInDeparture;
  final String status; // 'On Time', 'Delayed', 'Departed', 'Not Started'
  final bool isDeparted;
  final List<TrainStopInfo> route;

  const LiveTrainInfo({
    required this.trainNumber,
    required this.trainName,
    required this.currentStation,
    required this.currentStationCode,
    required this.scheduleArrival,
    required this.actualArrival,
    required this.delayInArrival,
    required this.scheduleDeparture,
    required this.actualDeparture,
    required this.delayInDeparture,
    required this.status,
    required this.isDeparted,
    required this.route,
  });

  /// Convenience: delay in minutes as int (0 if on time)
  int get delayMinutes {
    if (delayInArrival == '-' || delayInArrival.isEmpty) return 0;
    final match = RegExp(r'(\d+)').firstMatch(delayInArrival);
    return int.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  bool get isOnTime => delayMinutes == 0;
  bool get isDelayed => delayMinutes > 0;
}

class TrainStopInfo {
  final String stationName;
  final String stationCode;
  final String scheduleArrival;
  final String actualArrival;
  final String scheduleDeparture;
  final String actualDeparture;
  final String delay;
  final bool isDeparted;
  final int serialNo;

  const TrainStopInfo({
    required this.stationName,
    required this.stationCode,
    required this.scheduleArrival,
    required this.actualArrival,
    required this.scheduleDeparture,
    required this.actualDeparture,
    required this.delay,
    required this.isDeparted,
    required this.serialNo,
  });
}

// ──────────────────────────────────────────────────────────
// API Response wrapper
// ──────────────────────────────────────────────────────────
class TrainApiResult {
  final LiveTrainInfo? data;
  final String? error;
  final bool isLoading;

  bool get hasData  => data != null;
  bool get hasError => error != null;

  const TrainApiResult.loading()
      : data = null, error = null, isLoading = true;
  const TrainApiResult.success(this.data)
      : error = null, isLoading = false;
  const TrainApiResult.failure(this.error)
      : data = null, isLoading = false;
}

// ──────────────────────────────────────────────────────────
// Train Service
// ──────────────────────────────────────────────────────────
class TrainService {
  static const String _baseUrl = 'https://indianrailapi.com/api/v2';

  // ── Fetch live train status ───────────────────────────
  // [trainNumber] e.g. '12627' (Karnataka Express)
  // [date] optional — defaults to today
  static Future<TrainApiResult> fetchLiveStatus({
    required String trainNumber,
    DateTime? date,
  }) async {
    try {
      // Format date as yyyymmdd
      final d = date ?? DateTime.now();
      final dateStr = DateFormat('yyyyMMdd').format(d);

      final url = Uri.parse(
        '$_baseUrl/livetrainstatus/apikey/$_kApiKey'
        '/trainnumber/$trainNumber/date/$dateStr/',
      );

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return TrainApiResult.failure(
            'Server error: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // API returns ResponseCode "200" on success
      if (json['ResponseCode'] != '200') {
        return TrainApiResult.failure(
            json['Message'] ?? 'Train not found');
      }

      return TrainApiResult.success(_parseResponse(json, trainNumber));
    } on Exception catch (e) {
      return TrainApiResult.failure(e.toString());
    }
  }

  // ── Parse JSON response into model ───────────────────
  static LiveTrainInfo _parseResponse(
      Map<String, dynamic> json, String trainNumber) {
    final currentStation =
        json['CurrentStation'] as Map<String, dynamic>? ?? {};
    final route = (json['TrainRoute'] as List<dynamic>? ?? [])
        .map((s) => _parseStop(s as Map<String, dynamic>))
        .toList();

    final delayStr = currentStation['DelayInArrival']?.toString() ?? '-';
    final departed = currentStation['IsDeparted']?.toString() == '1';

    String status;
    if (departed) {
      status = 'Departed';
    } else if (delayStr == '-' || delayStr == '00 M' || delayStr == '0 M') {
      status = 'On Time';
    } else {
      status = 'Delayed';
    }

    return LiveTrainInfo(
      trainNumber: json['TrainNumber']?.toString() ?? trainNumber,
      trainName: json['TrainName']?.toString() ?? 'Unknown Train',
      currentStation:
          currentStation['StationName']?.toString() ?? 'Unknown',
      currentStationCode:
          currentStation['StationCode']?.toString() ?? '---',
      scheduleArrival:
          currentStation['ScheduleArrival']?.toString() ?? '--:--',
      actualArrival:
          currentStation['ActualArrival']?.toString() ?? '--:--',
      delayInArrival: delayStr,
      scheduleDeparture:
          currentStation['ScheduleDeparture']?.toString() ?? '--:--',
      actualDeparture:
          currentStation['ActualDeparture']?.toString() ?? '--:--',
      delayInDeparture:
          currentStation['DelayInDeparture']?.toString() ?? '-',
      status: status,
      isDeparted: departed,
      route: route,
    );
  }

  static TrainStopInfo _parseStop(Map<String, dynamic> s) {
    return TrainStopInfo(
      stationName: s['StationName']?.toString() ?? '',
      stationCode: s['StationCode']?.toString() ?? '',
      scheduleArrival: s['ScheduleArrival']?.toString() ?? '--:--',
      actualArrival: s['ActualArrival']?.toString() ?? '--:--',
      scheduleDeparture: s['ScheduleDeparture']?.toString() ?? '--:--',
      actualDeparture: s['ActualDeparture']?.toString() ?? '--:--',
      delay: s['DelayInArrival']?.toString() ?? '-',
      isDeparted: s['IsDeparted']?.toString() == '1',
      serialNo: int.tryParse(s['SerialNo']?.toString() ?? '0') ?? 0,
    );
  }
}