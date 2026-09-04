import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterReading {
  const WaterReading({
    required this.stationName,
    required this.stationRegion,
    required this.level,
    required this.status,
    required this.capturedAt,
    this.imagePath,
  });

  final String stationName;
  final String stationRegion;
  final double level;
  final String status;
  final DateTime capturedAt;
  final String? imagePath;

  String get levelLabel {
    return '${level.toStringAsFixed(2)} m';
  }

  String get dateLabel {
    final day = capturedAt.day.toString().padLeft(2, '0');
    final month = capturedAt.month.toString().padLeft(2, '0');
    final year = capturedAt.year.toString();

    return '$day/$month/$year';
  }

  String get timeLabel {
    final hour = capturedAt.hour.toString().padLeft(2, '0');
    final minute = capturedAt.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Map<String, dynamic> toJson() {
    return {
      'stationName': stationName,
      'stationRegion': stationRegion,
      'level': level,
      'status': status,
      'capturedAt': capturedAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory WaterReading.fromJson(Map<String, dynamic> json) {
    return WaterReading(
      stationName: json['stationName'] as String,
      stationRegion: json['stationRegion'] as String,
      level: (json['level'] as num).toDouble(),
      status: json['status'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      imagePath: json['imagePath'] as String?,
    );
  }
}

class ReadingStore {
  static const String _storageKey = 'jal_drishti_saved_readings';

  static final ValueNotifier<List<WaterReading>> readings =
      ValueNotifier<List<WaterReading>>([]);

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();

    final savedJson = preferences.getString(_storageKey);

    if (savedJson == null || savedJson.isEmpty) {
      readings.value = _initialReadings();

      await _saveAllReadings();
      return;
    }

    try {
      final decodedData = jsonDecode(savedJson) as List<dynamic>;

      readings.value = decodedData
          .map(
            (item) => WaterReading.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      readings.value = _initialReadings();

      await _saveAllReadings();
    }
  }

  static Future<void> addReading(WaterReading reading) async {
    readings.value = [
      reading,
      ...readings.value,
    ];

    await _saveAllReadings();
  }


  static Future<void> deleteReading(WaterReading reading) async {
  final updatedReadings = List<WaterReading>.from(
    readings.value,
  );

  updatedReadings.remove(reading);

  readings.value = updatedReadings;

  await _saveAllReadings();
  }

  static Future<void> _saveAllReadings() async {
    final preferences = await SharedPreferences.getInstance();

    final dataToSave = readings.value
        .map(
          (reading) => reading.toJson(),
        )
        .toList();

    await preferences.setString(
      _storageKey,
      jsonEncode(dataToSave),
    );
  }

  static List<WaterReading> _initialReadings() {
    return [
      WaterReading(
        stationName: 'Kaveri River – Station 014',
        stationRegion: 'Talakaveri Region',
        level: 2.84,
        status: 'Watch',
        capturedAt: DateTime.now().subtract(
          const Duration(hours: 3),
        ),
      ),
      WaterReading(
        stationName: 'Palar River – Station 022',
        stationRegion: 'Vellore Region',
        level: 1.76,
        status: 'Normal',
        capturedAt: DateTime.now().subtract(
          const Duration(days: 1, hours: 2),
        ),
      ),
      WaterReading(
        stationName: 'Musi River – Station 031',
        stationRegion: 'Hyderabad Region',
        level: 2.11,
        status: 'Normal',
        capturedAt: DateTime.now().subtract(
          const Duration(days: 2, hours: 5),
        ),
      ),
    ];
  }
}