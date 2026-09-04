import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';
import 'ai_processing_screen.dart';

class ImageQualityScreen extends StatelessWidget {
  const ImageQualityScreen({
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
                        'Image quality check',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 21,
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
                      const Text(
                        'Review captured gauge image',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Confirm that the gauge is visible before AI analysis starts.',
                        style: TextStyle(
                          color: JDColors.mutedText,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _CapturedImagePreview(
                        imagePath: imagePath,
                      ),
                      const SizedBox(height: 18),
                      const _QualityResultCard(),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: JDColors.lightBlue,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: JDColors.waterBlue.withValues(alpha: 0.18),
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
                                'AI processing will begin after confirmation. Please retake the image if the gauge is not clearly visible.',
                                style: TextStyle(
                                  color: JDColors.navy,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 53,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Retake image',
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AiProcessingScreen(
                                  imagePath: imagePath,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Use this image',
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

class _CapturedImagePreview extends StatelessWidget {
  const _CapturedImagePreview({
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 390,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: JDColors.border),
        boxShadow: [
          BoxShadow(
            color: JDColors.navy.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
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
                  color: Colors.black.withValues(alpha: 0.12),
                ),
                Positioned(
                  left: width * 0.28,
                  top: height * 0.13,
                  width: width * 0.44,
                  height: height * 0.70,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: JDColors.green,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: JDColors.green.withValues(alpha: 0.55),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.28,
                  top: height * 0.13 - 33,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: JDColors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'GAUGE DETECTED',
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
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.63),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Original image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
    );
  }
}

class _QualityResultCard extends StatelessWidget {
  const _QualityResultCard();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: JDColors.green,
                size: 26,
              ),
              SizedBox(width: 9),
              Text(
                'Image quality: Good',
                style: TextStyle(
                  color: JDColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _QualityCheckItem(label: 'Gauge fully visible'),
          SizedBox(height: 10),
          _QualityCheckItem(label: 'Image is sharp'),
          SizedBox(height: 10),
          _QualityCheckItem(label: 'Lighting is acceptable'),
          SizedBox(height: 10),
          _QualityCheckItem(label: 'Station QR matched'),
        ],
      ),
    );
  }
}

class _QualityCheckItem extends StatelessWidget {
  const _QualityCheckItem({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 21,
          height: 21,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: JDColors.lightGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: JDColors.green,
            size: 15,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: JDColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}