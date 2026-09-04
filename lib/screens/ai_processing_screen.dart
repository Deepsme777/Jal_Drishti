import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';
import 'reading_result_screen.dart';

class AiProcessingScreen extends StatefulWidget {
  const AiProcessingScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  State<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends State<AiProcessingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _scanController;

  bool _analysisReady = false;

  final List<_ProcessingStep> _steps = const [
    _ProcessingStep(
      label: 'Detecting gauge',
      threshold: 0.10,
      icon: Icons.crop_free_rounded,
    ),
    _ProcessingStep(
      label: 'Reading scale markings',
      threshold: 0.25,
      icon: Icons.straighten_rounded,
    ),
    _ProcessingStep(
      label: 'Locating waterline',
      threshold: 0.42,
      icon: Icons.water_rounded,
    ),
    _ProcessingStep(
      label: 'Checking image quality',
      threshold: 0.58,
      icon: Icons.verified_outlined,
    ),
    _ProcessingStep(
      label: 'Calculating confidence',
      threshold: 0.74,
      icon: Icons.analytics_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..forward();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _analysisReady = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: JDColors.background,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _progressController,
              _scanController,
            ]),
            builder: (context, child) {
              final double progress = _progressController.value * 0.75;
              final int progressPercent = (progress * 100).round();

              return Column(
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
                            'AI analysis',
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
                            color: JDColors.lightBlue,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.memory_rounded,
                                color: JDColors.waterBlue,
                                size: 15,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'On-device AI',
                                style: TextStyle(
                                  color: JDColors.waterBlue,
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
                            'Analyzing water level',
                            style: TextStyle(
                              color: JDColors.navy,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            _analysisReady
                                ? 'Analysis complete. Review the detected reading.'
                                : 'AI is identifying the gauge, scale markings, and waterline.',
                            style: const TextStyle(
                              color: JDColors.mutedText,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _AiImagePreview(
                            imagePath: widget.imagePath,
                            scanPosition: _scanController.value,
                          ),
                          const SizedBox(height: 19),
                          _ProgressCard(
                            progress: progress,
                            progressPercent: progressPercent,
                            isReady: _analysisReady,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Processing steps',
                            style: TextStyle(
                              color: JDColors.navy,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: JDColors.border),
                            ),
                            child: Column(
                              children: List.generate(
                                _steps.length,
                                (index) {
                                  final step = _steps[index];
                                  final bool completed =
                                      progress >= step.threshold;

                                  final bool active =
                                      !completed &&
                                          progress >=
                                              step.threshold - 0.14;

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index == _steps.length - 1
                                          ? 0
                                          : 14,
                                    ),
                                    child: _ProcessingStepRow(
                                      step: step,
                                      completed: completed,
                                      active: active,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedOpacity(
                            opacity: _analysisReady ? 1 : 0,
                            duration: const Duration(milliseconds: 400),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: _analysisReady
                                    ? () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ReadingResultScreen(
                                              imagePath: widget.imagePath,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                                label: const Text(
                                  'View reading result',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: JDColors.waterBlue,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: JDColors.border,
                                  disabledForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AiImagePreview extends StatelessWidget {
  const _AiImagePreview({
    required this.imagePath,
    required this.scanPosition,
  });

  final String imagePath;
  final double scanPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 290,
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
                  color: JDColors.navy.withValues(alpha: 0.18),
                ),
                Positioned(
                  left: width * 0.28,
                  top: height * 0.12,
                  width: width * 0.44,
                  height: height * 0.73,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: JDColors.green,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.28,
                  top: height * 0.12 - 29,
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
                      'GAUGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.28,
                  right: width * 0.28,
                  top: height * (0.18 + scanPosition * 0.58),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DD8FF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4DD8FF).withValues(alpha: 0.85),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  right: 12,
                  bottom: 12,
                  child: _AiOverlayLabel(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Scanning',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AiOverlayLabel extends StatelessWidget {
  const _AiOverlayLabel({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF4DD8FF),
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress,
    required this.progressPercent,
    required this.isReady,
  });

  final double progress;
  final int progressPercent;
  final bool isReady;

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: JDColors.lightBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isReady
                      ? Icons.check_circle_rounded
                      : Icons.auto_awesome_rounded,
                  color: isReady ? JDColors.green : JDColors.waterBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isReady ? 'Analysis ready' : 'AI processing in progress',
                  style: const TextStyle(
                    color: JDColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  color: JDColors.waterBlue,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              color: JDColors.waterBlue,
              backgroundColor: JDColors.lightBlue,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              isReady
                  ? 'Confidence calculation is ready for review.'
                  : 'Processing image evidence securely on this device.',
              style: const TextStyle(
                color: JDColors.mutedText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingStepRow extends StatelessWidget {
  const _ProcessingStepRow({
    required this.step,
    required this.completed,
    required this.active,
  });

  final _ProcessingStep step;
  final bool completed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = completed
        ? JDColors.green
        : active
            ? JDColors.waterBlue
            : JDColors.mutedText;

    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: completed
                ? JDColors.lightGreen
                : active
                    ? JDColors.lightBlue
                    : JDColors.background,
            shape: BoxShape.circle,
          ),
          child: completed
              ? const Icon(
                  Icons.check_rounded,
                  color: JDColors.green,
                  size: 20,
                )
              : Icon(
                  step.icon,
                  color: iconColor,
                  size: 18,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            step.label,
            style: TextStyle(
              color: completed || active ? JDColors.text : JDColors.mutedText,
              fontSize: 14,
              fontWeight: completed || active
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
        if (active && !completed)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: JDColors.waterBlue,
              strokeWidth: 2.3,
            ),
          ),
      ],
    );
  }
}

class _ProcessingStep {
  const _ProcessingStep({
    required this.label,
    required this.threshold,
    required this.icon,
  });

  final String label;
  final double threshold;
  final IconData icon;
}