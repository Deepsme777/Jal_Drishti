import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';

class ManualCorrectionScreen extends StatefulWidget {
  const ManualCorrectionScreen({
    super.key,
    required this.imagePath,
    this.detectedLevel = 2.84,
  });

  final String imagePath;
  final double detectedLevel;

  @override
  State<ManualCorrectionScreen> createState() =>
      _ManualCorrectionScreenState();
}

class _ManualCorrectionScreenState extends State<ManualCorrectionScreen> {
  late double _waterLevel;
  late TextEditingController _levelController;

  static const double _minimumLevel = 2.40;
  static const double _maximumLevel = 3.20;

  @override
  void initState() {
    super.initState();

    _waterLevel = widget.detectedLevel;
    _levelController = TextEditingController(
      text: _waterLevel.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }

  double get _linePosition {
    final percent =
        (_maximumLevel - _waterLevel) / (_maximumLevel - _minimumLevel);

    return 0.18 + (percent * 0.64);
  }

  void _setWaterLevel(double value) {
    final correctedValue = value.clamp(
      _minimumLevel,
      _maximumLevel,
    );

    setState(() {
      _waterLevel = correctedValue;
      _levelController.text = _waterLevel.toStringAsFixed(2);
    });
  }

  void _resetToAiValue() {
    _setWaterLevel(widget.detectedLevel);
  }

  void _saveCorrection() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Correction saved: ${_waterLevel.toStringAsFixed(2)} m',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      Navigator.pop(context, _waterLevel);
    });
  }

  void _updateFromWaterline(double localY, double imageHeight) {
    final position = (localY / imageHeight).clamp(0.18, 0.82);

    final value =
        _maximumLevel -
        ((position - 0.18) / 0.64) *
            (_maximumLevel - _minimumLevel);

    _setWaterLevel(value);
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
                        'Review waterline',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
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
                            Icons.warning_amber_rounded,
                            color: JDColors.amber,
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Review',
                            style: TextStyle(
                              color: JDColors.amber,
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
                        'Adjust the detected waterline',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Drag the blue line to the correct water surface if needed.',
                        style: TextStyle(
                          color: JDColors.mutedText,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ManualGaugeImage(
                        imagePath: widget.imagePath,
                        linePosition: _linePosition,
                        waterLevel: _waterLevel,
                        onMoveWaterline: _updateFromWaterline,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: JDColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detected level',
                              style: TextStyle(
                                color: JDColors.mutedText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '${_waterLevel.toStringAsFixed(2)} m',
                                  style: const TextStyle(
                                    color: JDColors.waterBlue,
                                    fontSize: 29,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.tune_rounded,
                                  color: JDColors.waterBlue,
                                  size: 23,
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: JDColors.waterBlue,
                                inactiveTrackColor: JDColors.lightBlue,
                                thumbColor: JDColors.waterBlue,
                                overlayColor:
                                    JDColors.waterBlue.withValues(alpha: 0.12),
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 10,
                                ),
                              ),
                              child: Slider(
                                min: _minimumLevel,
                                max: _maximumLevel,
                                divisions: 80,
                                label: '${_waterLevel.toStringAsFixed(2)} m',
                                value: _waterLevel,
                                onChanged: _setWaterLevel,
                              ),
                            ),
                            const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '2.40 m',
                                  style: TextStyle(
                                    color: JDColors.mutedText,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '3.20 m',
                                  style: TextStyle(
                                    color: JDColors.mutedText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Enter exact value',
                        style: TextStyle(
                          color: JDColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _levelController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: '2.84',
                          suffixText: 'm',
                          suffixStyle: const TextStyle(
                            color: JDColors.waterBlue,
                            fontWeight: FontWeight.w800,
                          ),
                          prefixIcon: const Icon(
                            Icons.straighten_rounded,
                            color: JDColors.waterBlue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: JDColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: JDColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: JDColors.waterBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          final enteredValue = double.tryParse(value);

                          if (enteredValue == null) {
                            return;
                          }

                          if (enteredValue >= _minimumLevel &&
                              enteredValue <= _maximumLevel) {
                            setState(() {
                              _waterLevel = enteredValue;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2D9),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: JDColors.amber.withValues(alpha: 0.20),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: JDColors.amber,
                              size: 21,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Manual review is recommended when the gauge image is unclear or the detected waterline looks incorrect.',
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
                      const SizedBox(height: 23),
                      SizedBox(
                        width: double.infinity,
                        height: 53,
                        child: OutlinedButton.icon(
                          onPressed: _resetToAiValue,
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Use AI result',
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
                          onPressed: _saveCorrection,
                          icon: const Icon(
                            Icons.save_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Save correction',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualGaugeImage extends StatelessWidget {
  const _ManualGaugeImage({
    required this.imagePath,
    required this.linePosition,
    required this.waterLevel,
    required this.onMoveWaterline,
  });

  final String imagePath;
  final double linePosition;
  final double waterLevel;
  final void Function(double localY, double imageHeight) onMoveWaterline;

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

            return GestureDetector(
              onPanDown: (details) {
                onMoveWaterline(
                  details.localPosition.dy,
                  height,
                );
              },
              onPanUpdate: (details) {
                onMoveWaterline(
                  details.localPosition.dy,
                  height,
                );
              },
              child: Stack(
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
                      ),
                    ),
                  ),
                  Positioned(
                    left: width * 0.16,
                    right: width * 0.16,
                    top: height * linePosition,
                    child: Container(
                      height: 4,
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
                    left: width * 0.50 - 15,
                    top: height * linePosition - 13,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: JDColors.waterBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.drag_handle_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: height * linePosition - 33,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: JDColors.waterBlue,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${waterLevel.toStringAsFixed(2)} m',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 12,
                    bottom: 12,
                    child: Text(
                      'Drag line to adjust water level',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}