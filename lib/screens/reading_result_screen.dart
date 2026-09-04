import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';
import 'secure_submission_screen.dart';
import 'manual_correction_screen.dart';

class ReadingResultScreen extends StatelessWidget {
  const ReadingResultScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
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
                        'Reading result',
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
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: JDColors.lightGreen,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: JDColors.green,
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'AI verified',
                            style: TextStyle(
                              color: JDColors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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
                      const Text(
                        'Water-level detection complete',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Please check the detected waterline before submitting.',
                        style: TextStyle(
                          color: JDColors.mutedText,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 19),
                      _GaugeResultImage(
                        imagePath: imagePath,
                      ),
                      const SizedBox(height: 19),
                      const _WaterLevelResultCard(),
                      const SizedBox(height: 16),
                      const _ReadingDetailsCard(),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SecureSubmissionScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Submit reading',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: JDColors.waterBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 53,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ManualCorrectionScreen(
                                  imagePath: imagePath,
                                  detectedLevel: 2.84,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                          ),
                          label: const Text(
                            'Review manually',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: JDColors.waterBlue,
                            side: const BorderSide(
                              color: JDColors.waterBlue,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
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

class _GaugeResultImage extends StatelessWidget {
  const _GaugeResultImage({
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 285,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: JDColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return const Center(
                      child: Text(
                        'Unable to load captured image.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
                Container(
                  color: JDColors.navy.withValues(alpha: 0.12),
                ),
                Positioned(
                  left: width * 0.29,
                  top: height * 0.10,
                  width: width * 0.42,
                  height: height * 0.77,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: JDColors.green,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: JDColors.green.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.29,
                  top: height * 0.10 - 28,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: JDColors.green,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'GAUGE DETECTED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.21,
                  right: width * 0.21,
                  top: height * 0.59,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF44D6FF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF44D6FF).withValues(alpha: 0.85),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: height * 0.59 - 28,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: JDColors.waterBlue,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      '2.84 m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.22,
                  top: height * 0.34,
                  child: const _ScaleLabel(label: '3.0'),
                ),
                Positioned(
                  left: width * 0.22,
                  top: height * 0.59 - 12,
                  child: const _ScaleLabel(label: '2.8'),
                ),
                Positioned(
                  left: width * 0.22,
                  top: height * 0.76,
                  child: const _ScaleLabel(label: '2.6'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScaleLabel extends StatelessWidget {
  const _ScaleLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WaterLevelResultCard extends StatelessWidget {
  const _WaterLevelResultCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: JDColors.navy,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: JDColors.navy.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current water level',
            style: TextStyle(
              color: Color(0xFFBFEFFF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '2.84 m',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Above gauge zero',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1F7851),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'High confidence — 94%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

class _ReadingDetailsCard extends StatelessWidget {
  const _ReadingDetailsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JDColors.border),
      ),
      child: const Column(
        children: [
          _ResultDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Station',
            value: 'Kaveri River – 014',
          ),
          Divider(color: JDColors.border),
          _ResultDetailRow(
            icon: Icons.schedule_outlined,
            label: 'Captured',
            value: '15 Aug 2026, 05:02 PM',
          ),
          Divider(color: JDColors.border),
          _ResultDetailRow(
            icon: Icons.gps_fixed_rounded,
            label: 'Location',
            value: 'Verified',
            valueColor: JDColors.green,
          ),
          Divider(color: JDColors.border),
          _ResultDetailRow(
            icon: Icons.image_outlined,
            label: 'Evidence',
            value: 'Image attached',
          ),
          Divider(color: JDColors.border),
          _ResultDetailRow(
            icon: Icons.memory_rounded,
            label: 'AI model',
            value: 'Jal-Drishti v1.0',
          ),
        ],
      ),
    );
  }
}

class _ResultDetailRow extends StatelessWidget {
  const _ResultDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = JDColors.navy,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: JDColors.waterBlue,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: JDColors.mutedText,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}