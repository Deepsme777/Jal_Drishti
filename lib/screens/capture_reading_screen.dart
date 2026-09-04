import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../data/reading_store.dart';
import '../theme/jd_colors.dart';

class CaptureReadingScreen extends StatefulWidget {
  const CaptureReadingScreen({
    super.key,
    this.isActive = true,
    this.showBackButton = false,
    this.returnToDashboardAfterSave = false,
  });

  final bool isActive;
  final bool showBackButton;
  final bool returnToDashboardAfterSave;

  @override
  State<CaptureReadingScreen> createState() => _CaptureReadingScreenState();
}

class _CaptureReadingScreenState extends State<CaptureReadingScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  XFile? _capturedImage;

  bool _isInitializing = true;
  bool _isTakingPhoto = false;
  bool _flashEnabled = false;
  bool _readingSaved = false;

  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.isActive) {
      _initializeCamera();
    } else {
      _isInitializing = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CaptureReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive &&
        widget.isActive &&
        _capturedImage == null) {
      _initializeCamera();
    }

    if (oldWidget.isActive && !widget.isActive) {
      _cameraController?.dispose();
      _cameraController = null;
      _flashEnabled = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
    }

    if (state == AppLifecycleState.resumed &&
        widget.isActive &&
        _capturedImage == null) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _cameraError = null;
      });
    }

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw CameraException(
          'NoCameraFound',
          'No camera was found on this device.',
        );
      }

      final rearCameras = cameras
          .where(
            (camera) => camera.lensDirection == CameraLensDirection.back,
          )
          .toList();

      final selectedCamera = rearCameras.isNotEmpty
          ? rearCameras.first
          : cameras.first;

      await _cameraController?.dispose();

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _cameraController = controller;

      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _flashEnabled = false;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError = _getCameraErrorMessage(error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _cameraError =
            'Unable to open the camera. Please try again on a physical phone.';
      });
    }
  }

  String _getCameraErrorMessage(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
        return 'Camera permission was denied. Enable it in your phone settings.';
      case 'CameraAccessDeniedWithoutPrompt':
        return 'Camera access is disabled. Enable it in phone settings.';
      case 'CameraAccessRestricted':
        return 'Camera access is restricted on this device.';
      case 'NoCameraFound':
        return 'No camera was found on this device.';
      default:
        return 'Camera error: ${error.description ?? error.code}';
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final nextMode = _flashEnabled ? FlashMode.off : FlashMode.torch;

      await controller.setFlashMode(nextMode);

      if (!mounted) {
        return;
      }

      setState(() {
        _flashEnabled = !_flashEnabled;
      });
    } on CameraException catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Flash is unavailable. Use the rear camera on a phone with a physical flash.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPhoto) {
      return;
    }

    try {
      setState(() {
        _isTakingPhoto = true;
      });

      final image = await controller.takePicture();

      if (!mounted) {
        return;
      }

      setState(() {
        _capturedImage = image;
        _isTakingPhoto = false;
        _readingSaved = false;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isTakingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not capture photo: ${error.description ?? error.code}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _readingSaved = false;
    });

    _initializeCamera();
  }


Future<String> _saveImagePermanently(XFile capturedImage) async {
  final appDocumentsDirectory =
      await getApplicationDocumentsDirectory();

  final readingsImageDirectory = Directory(
    '${appDocumentsDirectory.path}/reading_images',
  );

  if (!await readingsImageDirectory.exists()) {
    await readingsImageDirectory.create(
      recursive: true,
    );
  }

  final timestamp = DateTime.now().millisecondsSinceEpoch;

  final permanentImagePath =
      '${readingsImageDirectory.path}/gauge_$timestamp.jpg';

  await File(capturedImage.path).copy(permanentImagePath);

  return permanentImagePath;
}

Future<void> _saveReading() async {
  if (_capturedImage == null || _readingSaved) {
    return;
  }

  try {
    final permanentImagePath = await _saveImagePermanently(
      _capturedImage!,
    );

    await ReadingStore.addReading(
      WaterReading(
        stationName: 'Kaveri River – Station 014',
        stationRegion: 'Talakaveri Region',
        level: 2.84,
        status: 'Watch',
        capturedAt: DateTime.now(),
        imagePath: permanentImagePath,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _readingSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Reading and gauge photo saved permanently.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );


    if (widget.returnToDashboardAfterSave) {
      await Future.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    }


  } catch (_) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not save the gauge photo. Please try again.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Capture reading',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Capture a clear image of the water-level gauge.',
            style: TextStyle(
              color: JDColors.mutedText,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 19),
          const _StationCard(),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _capturedImage == null
                ? _buildCameraArea()
                : _buildCapturedResult(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    if (_isInitializing) {
      return Container(
        key: const ValueKey('loading'),
        height: 360,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: JDColors.navy,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 15),
            Text(
              'Starting camera...',
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

    if (_cameraError != null) {
      return Container(
        key: const ValueKey('error'),
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: JDColors.amber.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF2D9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: JDColors.amber,
                size: 29,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Camera unavailable',
              style: TextStyle(
                color: JDColors.navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _cameraError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: JDColors.mutedText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Try again',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: JDColors.waterBlue,
                side: const BorderSide(
                  color: JDColors.waterBlue,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Column(
      key: const ValueKey('camera'),
      children: [
        Container(
          height: 360,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.previewSize!.height,
                        height: controller.value.previewSize!.width,
                        child: CameraPreview(controller),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        color: JDColors.green,
                        size: 9,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Live camera',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.38),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _flashEnabled
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: _flashEnabled ? JDColors.amber : Colors.white,
                    ),
                  ),
                ),
              ),
              Center(
                child: IgnorePointer(
                  child: Container(
                    width: 205,
                    height: 245,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.92),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 18,
                child: Column(
                  children: [
                    const Text(
                      'Align the gauge inside the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 13),
                    GestureDetector(
                      onTap: _isTakingPhoto ? null : _takePhoto,
                      child: Container(
                        width: 70,
                        height: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: JDColors.waterBlue,
                            width: 5,
                          ),
                        ),
                        child: _isTakingPhoto
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: JDColors.waterBlue,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: JDColors.waterBlue,
                                size: 29,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: JDColors.waterBlue,
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Use the rear camera. Keep the gauge upright, clear, and well-lit before taking the photo.',
                style: TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCapturedResult() {
    return Column(
      key: const ValueKey('result'),
      children: [
        Container(
          height: 260,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(_capturedImage!.path),
                fit: BoxFit.cover,
              ),
              Center(
                child: Container(
                  width: 190,
                  height: 165,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: JDColors.green,
                      width: 3,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: JDColors.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Photo captured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: JDColors.border),
          ),
          child: const Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: JDColors.teal,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI detection result',
                    style: TextStyle(
                      color: JDColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                '2.84 m',
                style: TextStyle(
                  color: JDColors.waterBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Detected water level',
                style: TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 18),
              Divider(
                height: 1,
                color: JDColors.border,
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ResultDetail(
                    label: 'Confidence',
                    value: '96%',
                    color: JDColors.green,
                  ),
                  _ResultDetail(
                    label: 'Timestamp',
                    value: 'Just now',
                    color: JDColors.navy,
                  ),
                  _ResultDetail(
                    label: 'Status',
                    value: 'Watch',
                    color: JDColors.amber,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _readingSaved ? null : _saveReading,
            icon: Icon(
              _readingSaved ? Icons.check_circle_rounded : Icons.save_rounded,
            ),
            label: Text(
              _readingSaved ? 'Reading saved' : 'Save reading',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _readingSaved ? JDColors.green : JDColors.waterBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: JDColors.green,
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
            onPressed: _retakePhoto,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Retake photo',
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
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: JDColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: JDColors.lightBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: JDColors.waterBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kaveri River – Station 014',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Talakaveri Region',
                  style: TextStyle(
                    color: JDColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Selected',
            style: TextStyle(
              color: JDColors.green,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDetail extends StatelessWidget {
  const _ResultDetail({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: JDColors.mutedText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}