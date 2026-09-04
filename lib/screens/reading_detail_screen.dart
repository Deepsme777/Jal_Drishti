import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/reading_store.dart';
import '../theme/jd_colors.dart';

class ReadingDetailScreen extends StatelessWidget {
  const ReadingDetailScreen({
    super.key,
    required this.reading,
  });

  final WaterReading reading;

  Color get _statusColor {
    if (reading.status == 'Watch') {
      return JDColors.amber;
    }

    if (reading.status == 'Alert') {
      return JDColors.red;
    }

    return JDColors.green;
  }

  Color get _statusBackground {
    if (reading.status == 'Watch') {
      return const Color(0xFFFFF2D9);
    }

    if (reading.status == 'Alert') {
      return const Color(0xFFFFE4E2);
    }

    return JDColors.lightGreen;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        reading.imagePath != null && File(reading.imagePath!).existsSync();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: JDColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: JDColors.navy,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Reading details',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBackground,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        reading.status,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: JDColors.navy,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: hasImage
                            ? Image.file(
                                File(reading.imagePath!),
                                fit: BoxFit.cover,
                              )
                            : const _NoPhotoState(),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Detected water level',
                        style: TextStyle(
                          color: JDColors.mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        reading.levelLabel,
                        style: const TextStyle(
                          color: JDColors.waterBlue,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 19),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: JDColors.border),
                        ),
                        child: Column(
                          children: [
                            _DetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Station',
                              value: reading.stationName,
                              iconColor: JDColors.waterBlue,
                            ),
                            const _DetailDivider(),
                            _DetailRow(
                              icon: Icons.map_outlined,
                              label: 'Region',
                              value: reading.stationRegion,
                              iconColor: JDColors.teal,
                            ),
                            const _DetailDivider(),
                            _DetailRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Captured date',
                              value: reading.dateLabel,
                              iconColor: Colors.purple,
                            ),
                            const _DetailDivider(),
                            _DetailRow(
                              icon: Icons.access_time_rounded,
                              label: 'Captured time',
                              value: reading.timeLabel,
                              iconColor: JDColors.amber,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: JDColors.lightBlue,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: JDColors.waterBlue.withValues(alpha: 0.14),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: JDColors.waterBlue,
                              size: 21,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'This reading was saved from the field camera capture workflow.',
                                style: TextStyle(
                                  color: JDColors.text,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 37,
          height: 37,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: JDColors.mutedText,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: JDColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 23,
      color: JDColors.border,
    );
  }
}

class _NoPhotoState extends StatelessWidget {
  const _NoPhotoState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No photo available for this reading',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}