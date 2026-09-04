import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';

class OfflineSavedScreen extends StatelessWidget {
  const OfflineSavedScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goToDashboard(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: JDColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const _OfflineSavedGraphic(),
                const SizedBox(height: 27),
                const Text(
                  'Saved offline',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your reading is safely stored on this device and will sync automatically when internet access returns.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: JDColors.mutedText,
                    fontSize: 15,
                    height: 1.48,
                  ),
                ),
                const SizedBox(height: 27),
                const _OfflineReadingCard(),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showMessage(
                        context,
                        'Saved readings history will be added later.',
                      );
                    },
                    icon: const Icon(
                      Icons.history_rounded,
                      size: 20,
                    ),
                    label: const Text(
                      'View saved readings',
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _goToDashboard(context);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                    label: const Text(
                      'Continue monitoring',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JDColors.waterBlue,
                      foregroundColor: Colors.white,
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
      ),
    );
  }
}

class _OfflineSavedGraphic extends StatelessWidget {
  const _OfflineSavedGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      height: 145,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 135,
            height: 135,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2D9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: JDColors.amber.withValues(alpha: 0.16),
                  blurRadius: 22,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          Container(
            width: 78,
            height: 116,
            decoration: BoxDecoration(
              color: JDColors.navy,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.save_alt_rounded,
                  color: Colors.white,
                  size: 31,
                ),
                const SizedBox(height: 11),
                Container(
                  width: 45,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  width: 31,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: 3,
            right: 3,
            child: Icon(
              Icons.cloud_sync_rounded,
              color: JDColors.teal,
              size: 51,
            ),
          ),
          Positioned(
            bottom: 7,
            left: 7,
            child: Container(
              width: 35,
              height: 35,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: JDColors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.signal_cellular_alt_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineReadingCard extends StatelessWidget {
  const _OfflineReadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: JDColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reading stored locally',
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _PendingSyncBadge(),
            ],
          ),
          SizedBox(height: 18),
          _OfflineDataRow(
            icon: Icons.water_drop_rounded,
            label: 'Water level',
            value: '2.84 m',
            highlight: true,
          ),
          SizedBox(height: 12),
          _OfflineDataRow(
            icon: Icons.location_on_outlined,
            label: 'Station',
            value: 'Kaveri River – 014',
          ),
          SizedBox(height: 12),
          _OfflineDataRow(
            icon: Icons.schedule_outlined,
            label: 'Captured',
            value: '15 Aug 2026, 05:02 PM',
          ),
          SizedBox(height: 12),
          _OfflineDataRow(
            icon: Icons.cloud_off_rounded,
            label: 'Sync status',
            value: 'Waiting for connection',
            valueColor: JDColors.amber,
          ),
        ],
      ),
    );
  }
}

class _PendingSyncBadge extends StatelessWidget {
  const _PendingSyncBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            color: JDColors.amber,
            size: 14,
          ),
          SizedBox(width: 5),
          Text(
            'Pending sync',
            style: TextStyle(
              color: JDColors.amber,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineDataRow extends StatelessWidget {
  const _OfflineDataRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor = JDColors.navy,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: JDColors.waterBlue,
          size: 20,
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
              color: highlight ? JDColors.waterBlue : valueColor,
              fontSize: highlight ? 17 : 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
} 