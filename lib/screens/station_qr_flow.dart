import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/jd_colors.dart';
import 'capture_reading_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController =
      MobileScannerController(
    formats: const [
      BarcodeFormat.qrCode,
    ],
    autoZoom: true,
  );

  final TextEditingController _stationIdController =
      TextEditingController(text: '014');

  bool _hasOpenedStation = false;
  bool _torchEnabled = false;
  late final AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _scannerController.dispose();
    _stationIdController.dispose();
    super.dispose();
  }

  Future<void> _handleQrDetection(BarcodeCapture capture) async {
    if (_hasOpenedStation || capture.barcodes.isEmpty) {
      return;
    }

    final scannedValue = capture.barcodes.first.rawValue;

    if (scannedValue == null || scannedValue.trim().isEmpty) {
      return;
    }

    await _openStationDetails();
  }

  Future<void> _openStationDetails() async {
    if (_hasOpenedStation) {
      return;
    }

    setState(() {
      _hasOpenedStation = true;
    });

    try {
      await _scannerController.stop();
    } catch (_) {}

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const StationDetailsScreen(),
      ),
    );
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();

      if (!mounted) {
        return;
      }

      setState(() {
        _torchEnabled = !_torchEnabled;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Torch is unavailable on this camera.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showManualStationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: JDColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Text(
                  'Enter station ID',
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the station number shown on the water gauge plate.',
                  style: TextStyle(
                    color: JDColors.mutedText,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _stationIdController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Station ID',
                    hintText: 'Example: 014',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: JDColors.waterBlue,
                    ),
                    filled: true,
                    fillColor: JDColors.background,
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
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      FocusScope.of(sheetContext).unfocus();
                      Navigator.pop(sheetContext);

                      await _openStationDetails();
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text(
                      'Continue',
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF071B29),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 18, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan station QR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Align the QR plate inside the frame.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                      child: InkWell(
                        onTap: _toggleTorch,
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _torchEnabled
                                ? JDColors.amber.withValues(alpha: 0.30)
                                : Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            _torchEnabled
                                ? Icons.flashlight_on_rounded
                                : Icons.flashlight_off_rounded,
                            color: _torchEnabled
                                ? JDColors.amber
                                : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: MobileScanner(
                        controller: _scannerController,
                        onDetect: _handleQrDetection,
                        errorBuilder: (context, error) {
                          return _ScannerCameraError();
                        },
                      ),
                    ),
                    Container(
                      color: Colors.black.withValues(alpha: 0.20),
                    ),
                    AnimatedBuilder(
                      animation: _scanLineController,
                      builder: (context, child) {
                        return _RealScannerFrame(
                          linePosition: _scanLineController.value,
                        );
                      },
                    ),
                    const Positioned(
                      bottom: 42,
                      child: Text(
                        'Hold your phone steady',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 23, 24, 28),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: JDColors.waterBlue,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Station QR identifies the gauge location',
                                style: TextStyle(
                                  color: JDColors.navy,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Make sure the complete QR code is visible.',
                                style: TextStyle(
                                  color: JDColors.mutedText,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _showManualStationSheet,
                        icon: const Icon(
                          Icons.keyboard_outlined,
                          size: 20,
                        ),
                        label: const Text(
                          'Enter station ID manually',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: JDColors.waterBlue,
                          side: const BorderSide(
                            color: JDColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: JDColors.mutedText,
                          fontWeight: FontWeight.w700,
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
    );
  }
}

class _RealScannerFrame extends StatelessWidget {
  const _RealScannerFrame({
    required this.linePosition,
  });

  final double linePosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 255,
      height: 255,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: JDColors.waterBlue,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: JDColors.waterBlue.withValues(alpha: 0.32),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            Align(
              alignment: Alignment(
                0,
                -0.82 + (linePosition * 1.64),
              ),
              child: Container(
                width: double.infinity,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF53D7FF),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF53D7FF).withValues(alpha: 0.85),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.qr_code_2_rounded,
                color: Colors.white24,
                size: 105,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCameraError extends StatelessWidget {
  const _ScannerCameraError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF071B29),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(30),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: Colors.white,
            size: 45,
          ),
          SizedBox(height: 14),
          Text(
            'QR camera unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Allow camera permission and make sure no other camera screen is open.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class StationDetailsScreen extends StatelessWidget {
  const StationDetailsScreen({super.key});

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
                    const Text(
                      'Station details',
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _MapPreviewCard(),
                      const SizedBox(height: 19),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
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
                              size: 17,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Station verified',
                              style: TextStyle(
                                color: JDColors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Station 014',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Kaveri River Monitoring Point',
                        style: TextStyle(
                          color: JDColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Talakaveri Region',
                        style: TextStyle(
                          color: JDColors.mutedText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _DetailsCard(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (pageContext) {
                                  return Scaffold(
                                    backgroundColor: JDColors.background,
                                    appBar: AppBar(
                                      backgroundColor: JDColors.background,
                                      elevation: 0,
                                      scrolledUnderElevation: 0,
                                      leading: IconButton(
                                        onPressed: () {
                                          Navigator.of(pageContext).popUntil(
                                            (route) => route.isFirst,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: JDColors.navy,
                                        ),
                                      ),
                                      title: const Text(
                                        'Capture water level',
                                        style: TextStyle(
                                          color: JDColors.navy,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    body: const CaptureReadingScreen(
                                      returnToDashboardAfterSave: true,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text(
                            'Capture water level',
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

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFDDF1E7),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: JDColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -10,
            right: -10,
            top: 83,
            child: Transform.rotate(
              angle: -0.10,
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFF8BD4E6),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 25,
            left: 28,
            child: Icon(
              Icons.park_rounded,
              color: JDColors.green,
              size: 42,
            ),
          ),
          const Positioned(
            bottom: 24,
            right: 27,
            child: Icon(
              Icons.landscape_rounded,
              color: Color(0xFF6FA56D),
              size: 55,
            ),
          ),
          const Center(
            child: Icon(
              Icons.location_on_rounded,
              color: JDColors.waterBlue,
              size: 50,
            ),
          ),
          const Positioned(
            left: 15,
            bottom: 13,
            child: Text(
              'Kaveri River',
              style: TextStyle(
                color: JDColors.navy,
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

class _DetailsCard extends StatelessWidget {
  const _DetailsCard();

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
        children: [
          _DetailsRow(
            label: 'Latitude',
            value: '12.3871° N',
          ),
          Divider(color: JDColors.border),
          _DetailsRow(
            label: 'Longitude',
            value: '75.4352° E',
          ),
          Divider(color: JDColors.border),
          _DetailsRow(
            label: 'Gauge type',
            value: 'Standard staff gauge',
          ),
          Divider(color: JDColors.border),
          _DetailsRow(
            label: 'Last reading',
            value: '2.84 m',
            highlighted: true,
          ),
          Divider(color: JDColors.border),
          _DetailsRow(
            label: 'Last updated',
            value: '15 Aug 2026, 04:58 PM',
          ),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

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
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: highlighted ? JDColors.waterBlue : JDColors.navy,
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