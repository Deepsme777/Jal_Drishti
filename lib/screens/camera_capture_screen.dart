import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';
import 'image_quality_screen.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];

  bool _isLoading = true;
  bool _isCapturing = false;
  bool _flashEnabled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera({
    CameraDescription? selectedCamera,
  }) async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw CameraException(
          'no_camera',
          'No camera was found on this device.',
        );
      }

      CameraDescription cameraToUse = selectedCamera ??
          _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras.first,
          );

      final controller = CameraController(
        cameraToUse,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      final oldController = _cameraController;

      setState(() {
        _cameraController = controller;
        _isLoading = false;
        _flashEnabled = false;
      });

      await oldController?.dispose();
    } on CameraException catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        error.description ?? 'Unable to access the phone camera.',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Unable to initialize the phone camera.');
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final newFlashState = !_flashEnabled;

      await controller.setFlashMode(
        newFlashState ? FlashMode.torch : FlashMode.off,
      );

      if (!mounted) return;

      setState(() {
        _flashEnabled = newFlashState;
      });
    } on CameraException catch (_) {
      _showMessage('Flash is not available on this camera.');
    }
  }

  Future<void> _switchCamera() async {
    if (_isLoading || _isCapturing) {
      return;
    }

    if (_cameras.length < 2) {
      _showMessage('Only one camera is available on this phone.');
      return;
    }

    final currentController = _cameraController;

    if (currentController == null) {
      _showMessage('Camera is not ready yet.');
      return;
    }

    final currentDirection = currentController.description.lensDirection;

    final nextCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection != currentDirection,
      orElse: () => _cameras.first,
    );

    setState(() {
      _isLoading = true;
      _flashEnabled = false;
      _cameraController = null;
    });

    try {
      await currentController.dispose();

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 250));

      await _initializeCamera(
        selectedCamera: nextCamera,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Unable to switch the camera. Try again.');
    }
  }

  Future<void> _takePicture() async {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final XFile image = await controller.takePicture();

      if (!mounted) return;

      debugPrint('Captured image path: ${image.path}');

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImageQualityScreen(
            imagePath: image.path,
          ),
        ),
      );
    } on CameraException catch (error) {
      _showMessage(
        error.description ?? 'Could not capture image.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();

      setState(() {
        _cameraController = null;
      });
    }

    if (state == AppLifecycleState.resumed) {
      _initializeCamera(
        selectedCamera: controller.description,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading || controller == null || !controller.value.isInitialized
            ? const _CameraLoadingScreen()
            : Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: CameraPreview(controller),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x99000000),
                          Colors.transparent,
                          Color(0xB3000000),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 16, 0),
                          child: Row(
                            children: [
                              _RoundControlButton(
                                icon: Icons.arrow_back_rounded,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Capture water level',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Fit the entire gauge inside the frame',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _RoundControlButton(
                                icon: _flashEnabled
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                active: _flashEnabled,
                                onPressed: _toggleFlash,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const _GaugeAlignmentGuide(),
                        const SizedBox(height: 20),
                        const Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusPill(
                              label: 'Good lighting',
                              icon: Icons.wb_sunny_outlined,
                            ),
                            _StatusPill(
                              label: 'Gauge detected',
                              icon: Icons.check_circle_outline_rounded,
                            ),
                            _StatusPill(
                              label: 'Stable camera',
                              icon: Icons.stay_current_portrait_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: JDColors.waterBlue.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'Keep the phone straight and avoid glare on the gauge.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.35,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _CameraActionButton(
                                icon: Icons.photo_library_outlined,
                                label: 'Gallery',
                                onPressed: () {
                                  _showMessage(
                                    'Gallery image selection will be added next.',
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: _takePicture,
                                child: Container(
                                  width: 77,
                                  height: 77,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    decoration: BoxDecoration(
                                      color: _isCapturing
                                          ? JDColors.green
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isCapturing
                                          ? Icons.check_rounded
                                          : Icons.camera_alt_rounded,
                                      color: _isCapturing
                                          ? Colors.white
                                          : JDColors.navy,
                                      size: 31,
                                    ),
                                  ),
                                ),
                              ),
                              _CameraActionButton(
                                icon: Icons.flip_camera_android_outlined,
                                label: 'Rotate',
                                onPressed: _switchCamera,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CameraLoadingScreen extends StatelessWidget {
  const _CameraLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: JDColors.waterBlue,
          ),
          SizedBox(height: 16),
          Text(
            'Opening camera...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugeAlignmentGuide extends StatelessWidget {
  const _GaugeAlignmentGuide();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.of(context).size.width * 0.56;
        final height = MediaQuery.of(context).size.height * 0.42;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF53D7FF),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF53D7FF).withValues(alpha: 0.35),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 1.5,
                  height: double.infinity,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 1.5,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ALIGN GAUGE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xDD123B4D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF74E2A8),
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

class _RoundControlButton extends StatelessWidget {
  const _RoundControlButton({
    required this.icon,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? JDColors.waterBlue
          : Colors.white.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }
}

class _CameraActionButton extends StatelessWidget {
  const _CameraActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 27,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}