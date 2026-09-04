import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';
import 'offline_saved_screen.dart';

class SecureSubmissionScreen extends StatefulWidget {
  const SecureSubmissionScreen({super.key});

  @override
  State<SecureSubmissionScreen> createState() =>
      _SecureSubmissionScreenState();
}

class _SecureSubmissionScreenState extends State<SecureSubmissionScreen> {
  bool _isSubmitting = false;

  Future<void> _submitSecurely() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SynchronizationSuccessScreen(),
      ),
    );
  }

  void _saveOffline() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const OfflineSavedScreen(),
      ),
    );
  }

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
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: JDColors.navy,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Secure submission',
                      style: TextStyle(
                        color: JDColors.navy,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    children: [
                      const _SecureShieldGraphic(),
                      const SizedBox(height: 18),
                      const Text(
                        'Reading ready to submit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The record has been validated and prepared for secure upload.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: JDColors.mutedText,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _SubmissionSummaryCard(),
                      const SizedBox(height: 16),
                      const _SecurityStatusCard(),
                      const SizedBox(height: 16),
                      const _SecurityProgressCard(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitSecurely,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Icon(
                                  Icons.lock_rounded,
                                  size: 20,
                                ),
                          label: Text(
                            _isSubmitting
                                ? 'Submitting securely...'
                                : 'Submit securely',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: JDColors.waterBlue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: JDColors.waterBlue,
                            disabledForegroundColor: Colors.white,
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
                          onPressed: _isSubmitting ? null : _saveOffline,
                          icon: const Icon(
                            Icons.save_alt_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Save offline',
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

class _SecureShieldGraphic extends StatelessWidget {
  const _SecureShieldGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: JDColors.lightGreen,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: JDColors.green.withValues(alpha: 0.18),
            blurRadius: 22,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Container(
        width: 94,
        height: 94,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: JDColors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.shield_rounded,
          color: Colors.white,
          size: 56,
        ),
      ),
    );
  }
}

class _SubmissionSummaryCard extends StatelessWidget {
  const _SubmissionSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JDColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reading summary',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 15),
          _SubmissionRow(
            icon: Icons.water_drop_rounded,
            label: 'Water level',
            value: '2.84 m',
            highlight: true,
          ),
          SizedBox(height: 12),
          _SubmissionRow(
            icon: Icons.location_on_outlined,
            label: 'Station',
            value: 'Kaveri River – 014',
          ),
          SizedBox(height: 12),
          _SubmissionRow(
            icon: Icons.gps_fixed_rounded,
            label: 'Location',
            value: 'GPS verified',
            valueColor: JDColors.green,
          ),
          SizedBox(height: 12),
          _SubmissionRow(
            icon: Icons.schedule_outlined,
            label: 'Timestamp',
            value: '15 Aug 2026, 05:02 PM',
          ),
          SizedBox(height: 12),
          _SubmissionRow(
            icon: Icons.image_outlined,
            label: 'Evidence',
            value: 'Original image attached',
          ),
        ],
      ),
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  const _SubmissionRow({
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

class _SecurityStatusCard extends StatelessWidget {
  const _SecurityStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: JDColors.lightBlue,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: JDColors.waterBlue.withValues(alpha: 0.18),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: JDColors.waterBlue,
                size: 23,
              ),
              SizedBox(width: 9),
              Text(
                'Record security',
                style: TextStyle(
                  color: JDColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _SecurityCheck(label: 'GPS and timestamp captured'),
          SizedBox(height: 9),
          _SecurityCheck(label: 'Original image evidence attached'),
          SizedBox(height: 9),
          _SecurityCheck(label: 'SHA-256 hash generated'),
          SizedBox(height: 9),
          _SecurityCheck(label: 'Record prepared for digital signing'),
        ],
      ),
    );
  }
}

class _SecurityCheck extends StatelessWidget {
  const _SecurityCheck({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: JDColors.green,
            size: 15,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: JDColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityProgressCard extends StatelessWidget {
  const _SecurityProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: JDColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security progress',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 15),
          Wrap(
            spacing: 7,
            runSpacing: 8,
            children: [
              _SecurityProgressChip(
                label: 'Validated',
                color: JDColors.green,
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: JDColors.mutedText,
                size: 17,
              ),
              _SecurityProgressChip(
                label: 'Hashed',
                color: JDColors.green,
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: JDColors.mutedText,
                size: 17,
              ),
              _SecurityProgressChip(
                label: 'Encrypted',
                color: JDColors.green,
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: JDColors.mutedText,
                size: 17,
              ),
              _SecurityProgressChip(
                label: 'Ready',
                color: JDColors.waterBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityProgressChip extends StatelessWidget {
  const _SecurityProgressChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class SynchronizationSuccessScreen extends StatelessWidget {
  const SynchronizationSuccessScreen({super.key});

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
                Container(
                  width: 136,
                  height: 136,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: JDColors.lightGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: JDColors.green.withValues(alpha: 0.20),
                        blurRadius: 25,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_done_rounded,
                    color: JDColors.green,
                    size: 76,
                  ),
                ),
                const SizedBox(height: 27),
                const Text(
                  'Reading synchronized',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'The water-level record has been securely uploaded and verified.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: JDColors.mutedText,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 27),
                const _SynchronizationDetailsCard(),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );
                    },
                    icon: const Icon(Icons.dashboard_rounded),
                    label: const Text(
                      'View dashboard',
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

class _SynchronizationDetailsCard extends StatelessWidget {
  const _SynchronizationDetailsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JDColors.border),
      ),
      child: const Column(
        children: [
          _SyncRow(
            label: 'Record ID',
            value: 'JD-2026-014-000872',
          ),
          Divider(color: JDColors.border),
          _SyncRow(
            label: 'Water level',
            value: '2.84 m',
          ),
          Divider(color: JDColors.border),
          _SyncRow(
            label: 'Station',
            value: 'Kaveri River – 014',
          ),
          Divider(color: JDColors.border),
          _SyncRow(
            label: 'Hash status',
            value: 'Verified',
            greenValue: true,
          ),
          Divider(color: JDColors.border),
          _SyncRow(
            label: 'Uploaded',
            value: '15 Aug 2026, 05:08 PM',
          ),
        ],
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({
    required this.label,
    required this.value,
    this.greenValue = false,
  });

  final String label;
  final String value;
  final bool greenValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: JDColors.mutedText,
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: greenValue ? JDColors.green : JDColors.navy,
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