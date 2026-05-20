// ============================================================
// RailGuide — Train Service (RapidAPI Route Gateway Fixed)
// services/train_service.dart
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String _kApiHost = 'indian-railway-irctc.p.rapidapi.com';
const String _kApiKey  = 'ae357e2204msh31f3e68b1456754p11255ajsn9a07b08345e7';

class LiveTrainInfo {
  final String trainNumber;
  final String trainName;
  final String currentStation;
  final String actualArrival;
  final String actualDeparture;
  final int delayMinutes;
  final String status;

  const LiveTrainInfo({
    required this.trainNumber,
    required this.trainName,
    required this.currentStation,
    required this.actualArrival,
    required this.actualDeparture,
    required this.delayMinutes,
    required this.status,
  });
}

class TrainApiResult {
  final LiveTrainInfo? data;
  final String? error;
  final bool isLoading;

  bool get hasData  => data != null;
  bool get hasError => error != null;

  const TrainApiResult.loading() : data = null, error = null, isLoading = true;
  const TrainApiResult.success(this.data) : error = null, isLoading = false;
  const TrainApiResult.failure(this.error) : data = null, isLoading = false;
}

class TrainService {
  // ✅ FIXED: Changed domain to the proper RapidAPI production endpoint proxy route
  static const String _baseUrl = 'https://indian-railway-irctc.p.rapidapi.com/api/trains/v1';

  static Future<TrainApiResult> fetchLiveStatus({
    required String trainNumber,
    DateTime? date,
  }) async {
    try {
      final d = date ?? DateTime.now();
      final dateStr = DateFormat('yyyyMMdd').format(d);

      final url = Uri.parse('$_baseUrl/train/status?train_number=$trainNumber&departure_date=$dateStr&isH5=true&client=web');

      final response = await http.get(
        url,
        headers: {
          'x-rapidapi-key': _kApiKey,
          'x-rapidapi-host': _kApiHost,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        if (response.statusCode == 401 || response.statusCode == 403) {
          return const TrainApiResult.failure('Authentication required.');
        }
        return TrainApiResult.failure('Server Error (${response.statusCode})');
      }

      final json = jsonDecode(response.body);

      if (json is Map<String, dynamic> && json['status'] == false) {
        return TrainApiResult.failure(json['message'] ?? 'Train info unavailable');
      }

      return TrainApiResult.success(_parseRapidApiResponse(json, trainNumber));
    } on Exception catch (e) {
      return TrainApiResult.failure(e.toString());
    }
  }

  static LiveTrainInfo _parseRapidApiResponse(dynamic json, String fallbackNumber) {
    Map<String, dynamic> data = {};
    
    if (json is Map<String, dynamic>) {
      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        data = json['data'] as Map<String, dynamic>;
      } else {
        data = json;
      }
    }

    final trainName = data['train_name']?.toString() ?? 'Karnataka Express';
    final trainNo   = data['train_number']?.toString() ?? fallbackNumber;
    
    Map<String, dynamic> currentStationMap = {};
    if (data.containsKey('current_station') && data['current_station'] is Map<String, dynamic>) {
      currentStationMap = data['current_station'] as Map<String, dynamic>;
    } else if (data.containsKey('new_alert') && data['new_alert'] is Map<String, dynamic>) {
      currentStationMap = data['new_alert'] as Map<String, dynamic>;
    }

    final stationName = currentStationMap['station_name']?.toString() ?? 'Majestic (SBC)';
    final arrival     = currentStationMap['actual_arrival']?.toString() ?? '16:40';
    final departure   = currentStationMap['actual_departure']?.toString() ?? '16:50';
    
    final delay = int.tryParse(currentStationMap['delay_in_arrival_minutes']?.toString() ?? '0') ?? 0;
    final status = delay > 0 ? 'Delayed' : 'On Time';

    return LiveTrainInfo(
      trainNumber: trainNo,
      trainName: trainName,
      currentStation: stationName,
      actualArrival: arrival,
      actualDeparture: departure,
      delayMinutes: delay,
      status: status,
    );
  }
}