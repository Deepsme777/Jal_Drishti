import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';

import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Measure water levels\nwith your smartphone',
      description:
          'Capture a gauge image and let AI calculate the water level quickly and accurately.',
      type: _OnboardingType.capture,
    ),
    _OnboardingData(
      title: 'Trusted data,\nprotected records',
      description:
          'Every reading is linked with location, time, image evidence, and a secure digital fingerprint.',
      type: _OnboardingType.security,
    ),
    _OnboardingData(
      title: 'Works offline,\nsyncs automatically',
      description:
          'Collect readings without internet access. Your data will synchronize securely when you are online.',
      type: _OnboardingType.offline,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 14, 4),
                child: Row(
                  children: [
                    const _HeaderBrand(),
                    const Spacer(),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: JDColors.waterBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: _pages[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                child: Column(
                  children: [
                    _PageDots(
                      currentPage: _currentPage,
                      numberOfPages: _pages.length,
                    ),
                    const SizedBox(height: 24),
                    if (!isLastPage)
                      Row(
                        children: [
                          if (_currentPage > 0) ...[
                            Expanded(
                              child: _SecondaryButton(
                                label: 'Back',
                                onPressed: () {
                                  _goToPage(_currentPage - 1);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            flex: _currentPage > 0 ? 2 : 1,
                            child: _PrimaryButton(
                              label: 'Next',
                              onPressed: () {
                                _goToPage(_currentPage + 1);
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      _PrimaryButton(
                        label: 'Get Started',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _finishOnboarding,
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

class _HeaderBrand extends StatelessWidget {
  const _HeaderBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.water_drop_rounded,
          color: JDColors.waterBlue,
          size: 35,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Jal-Drishti',
              style: TextStyle(
                color: JDColors.navy,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'जल-दृ',
              style: TextStyle(
                color: JDColors.mutedText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
  });

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 540;
        final illustrationSize = isCompact ? 205.0 : 265.0;
        final titleSize = isCompact ? 23.0 : 26.0;
        final descriptionSize = isCompact ? 14.0 : 16.0;
        final illustrationGap = isCompact ? 25.0 : 38.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AnimatedIllustration(
                type: data.type,
                size: illustrationSize,
              ),
              SizedBox(height: illustrationGap),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 330),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: JDColors.mutedText,
                    fontSize: descriptionSize,
                    height: 1.48,
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

class _AnimatedIllustration extends StatelessWidget {
  const _AnimatedIllustration({
    required this.type,
    required this.size,
  });

  final _OnboardingType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(type),
      tween: Tween(begin: 0.90, end: 1.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: switch (type) {
          _OnboardingType.capture => const _CaptureIllustration(),
          _OnboardingType.security => const _SecurityIllustration(),
          _OnboardingType.offline => const _OfflineIllustration(),
        },
      ),
    );
  }
}

class _CaptureIllustration extends StatelessWidget {
  const _CaptureIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: JDColors.lightBlue,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.water_drop_rounded,
          color: JDColors.waterBlue,
          size: 132,
        ),
      ),
    );
  }
}

class _SecurityIllustration extends StatelessWidget {
  const _SecurityIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: const BoxDecoration(
            color: JDColors.lightTeal,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 104,
          height: 185,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: JDColors.border),
            boxShadow: [
              BoxShadow(
                color: JDColors.navy.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop_rounded,
                color: JDColors.waterBlue,
                size: 31,
              ),
              SizedBox(height: 12),
              Icon(
                Icons.fingerprint_rounded,
                color: JDColors.teal,
                size: 42,
              ),
              SizedBox(height: 10),
              Icon(
                Icons.lock_rounded,
                color: JDColors.navy,
                size: 25,
              ),
            ],
          ),
        ),
        const Positioned(
          top: 35,
          right: 28,
          child: Icon(
            Icons.cloud_done_rounded,
            color: JDColors.waterBlue,
            size: 48,
          ),
        ),
        const Positioned(
          top: 24,
          left: 36,
          child: Icon(
            Icons.verified_user_rounded,
            color: JDColors.green,
            size: 56,
          ),
        ),
        const Positioned(
          bottom: 30,
          left: 31,
          child: Icon(
            Icons.location_on_rounded,
            color: JDColors.red,
            size: 45,
          ),
        ),
        const Positioned(
          bottom: 31,
          right: 35,
          child: Icon(
            Icons.schedule_rounded,
            color: Color.fromARGB(255, 228, 171, 13),
            size: 43,
          ),
        ),
      ],
    );
  }
}

class _OfflineIllustration extends StatelessWidget {
  const _OfflineIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: const BoxDecoration(
            color: JDColors.lightBlue,
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          bottom: 25,
          child: Container(
            width: 118,
            height: 190,
            decoration: BoxDecoration(
              color: JDColors.navy,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: JDColors.navy.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.white70,
                    size: 31,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 58,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: JDColors.waterBlue,
                    ),
                  ),
                  const SizedBox(height: 11),
                  const Text(
                    '2.84 m',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Saved locally',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          top: 30,
          right: 30,
          child: Icon(
            Icons.cloud_sync_rounded,
            color: JDColors.green,
            size: 56,
          ),
        ),
        const Positioned(
          top: 51,
          left: 30,
          child: Icon(
            Icons.signal_cellular_alt_rounded,
            color: JDColors.amber,
            size: 46,
          ),
        ),
        const Positioned(
          bottom: 43,
          right: 36,
          child: Icon(
            Icons.lock_rounded,
            color: JDColors.teal,
            size: 38,
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.currentPage,
    required this.numberOfPages,
  });

  final int currentPage;
  final int numberOfPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numberOfPages, (index) {
        final isActive = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: isActive ? 25 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? JDColors.waterBlue : JDColors.border,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
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
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: JDColors.waterBlue,
          side: const BorderSide(color: JDColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: JDColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Icon(
                  Icons.water_drop_rounded,
                  color: JDColors.waterBlue,
                  size: 58,
                ),
                const Spacer(),
                const Icon(
                  Icons.lock_person_rounded,
                  color: JDColors.waterBlue,
                  size: 74,
                ),
                const SizedBox(height: 22),
                const Text(
                  'Onboarding complete',
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The professional Jal-Drishti login screen will be added in the next step.',
                  style: TextStyle(
                    color: JDColors.mutedText,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JDColors.waterBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _OnboardingType {
  capture,
  security,
  offline,
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.description,
    required this.type,
  });

  final String title;
  final String description;
  final _OnboardingType type;
}