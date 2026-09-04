import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _waveController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _contentOpacity;

  bool _showTapHint = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();

    _logoScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(
        0.03,
        0.48,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(
        0.03,
        0.25,
        curve: Curves.easeOut,
      ),
    );

    _contentOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(
        0.42,
        0.82,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 1750), () {
      if (!mounted) return;

      setState(() {
        _showTapHint = true;
      });
    });
  }

  void _openOnboarding() {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, _, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.035),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openOnboarding,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _entranceController,
              _waveController,
            ]),
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      JDColors.navy,
                      Color(0xFF075575),
                      JDColors.waterBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: WaterWavePainter(_waveController.value),
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ScaleTransition(
                                    scale: _logoScale,
                                    child: FadeTransition(
                                      opacity: _logoOpacity,
                                      child: const SplashLogo(),
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  FadeTransition(
                                    opacity: _contentOpacity,
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Jal-Drishti',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'जल-दृ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFFD8F5FF),
                                            fontSize: 19,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Smart Water Monitoring',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          FadeTransition(
                            opacity: _contentOpacity,
                            child: const Text(
                              'Secure. Accurate. Connected.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 13),
                          AnimatedOpacity(
                            opacity: _showTapHint ? 1 : 0,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOut,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  color: Color(0xFFD8F5FF),
                                  size: 17,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Tap anywhere to continue',
                                  style: TextStyle(
                                    color: Color(0xFFD8F5FF),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 158,
            height: 158,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF72DBFF).withValues(alpha: 0.58),
                  blurRadius: 34,
                  spreadRadius: 7,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 150,
                ),
                Positioned(
                  top: 68,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 31,
                      height: 31,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: JDColors.waterBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
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


class WaterWavePainter extends CustomPainter {
  WaterWavePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(
      canvas,
      size,
      yPosition: size.height * 0.18,
      amplitude: 20,
      wavelength: 180,
      opacity: 0.11,
      phase: progress * math.pi * 2,
    );

    _drawWave(
      canvas,
      size,
      yPosition: size.height * 0.70,
      amplitude: 26,
      wavelength: 220,
      opacity: 0.10,
      phase: -progress * math.pi * 2,
    );

    _drawWave(
      canvas,
      size,
      yPosition: size.height * 0.80,
      amplitude: 16,
      wavelength: 160,
      opacity: 0.07,
      phase: progress * math.pi * 3,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double yPosition,
    required double amplitude,
    required double wavelength,
    required double opacity,
    required double phase,
  }) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    for (double x = 0; x <= size.width; x += 4) {
      final y = yPosition +
          math.sin((x / wavelength) * math.pi * 2 + phase) * amplitude;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaterWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}