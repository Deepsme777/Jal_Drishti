import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';
import 'water_level_analytics_screen.dart';

const Color _alertRed = Color(0xFFD94A45);

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  bool _acknowledged = false;

  void _acknowledgeAlert() {
    setState(() {
      _acknowledged = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert acknowledged successfully.'),
        behavior: SnackBarBehavior.floating,
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
                        'Water-level alert',
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
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2D9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: JDColors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Watch',
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
                      const _WarningCard(),
                      const SizedBox(height: 22),
                      const Text(
                        'Water level trend',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _TrendChartCard(),
                      const SizedBox(height: 22),
                      const Text(
                        'Recommended actions',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _ActionsCard(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _acknowledged ? null : _acknowledgeAlert,
                          icon: Icon(
                            _acknowledged
                                ? Icons.check_circle_rounded
                                : Icons.done_rounded,
                          ),
                          label: Text(
                            _acknowledged
                                ? 'Alert acknowledged'
                                : 'Acknowledge alert',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _acknowledged
                                ? JDColors.green
                                : JDColors.amber,
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
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const WaterLevelAnalyticsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text(
                            'View station details',
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

class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: JDColors.amber.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.water_damage_rounded,
                color: JDColors.amber,
                size: 31,
              ),
              SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Rising water level detected',
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          _AlertInfoRow(
            label: 'Station',
            value: 'Kaveri River – 014',
          ),
          SizedBox(height: 12),
          _AlertInfoRow(
            label: 'Current level',
            value: '2.84 m',
            largeValue: true,
          ),
          SizedBox(height: 12),
          _AlertInfoRow(
            label: 'Change in last 6 hours',
            value: '+0.42 m',
            valueColor: _alertRed,
          ),
          SizedBox(height: 12),
          _AlertInfoRow(
            label: 'Last verified',
            value: '5 minutes ago',
          ),
        ],
      ),
    );
  }
}

class _AlertInfoRow extends StatelessWidget {
  const _AlertInfoRow({
    required this.label,
    required this.value,
    this.largeValue = false,
    this.valueColor = JDColors.navy,
  });

  final String label;
  final String value;
  final bool largeValue;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: largeValue ? 20 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: JDColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: _alertRed,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Last 6 hours',
                style: TextStyle(
                  color: JDColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Spacer(),
              Text(
                '+0.42 m',
                style: TextStyle(
                  color: _alertRed,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Water level in meters',
            style: TextStyle(
              color: JDColors.mutedText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 145,
            width: double.infinity,
            child: CustomPaint(
              painter: _AlertTrendPainter(),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '11 AM',
                style: TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 10,
                ),
              ),
              Text(
                '1 PM',
                style: TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 10,
                ),
              ),
              Text(
                '3 PM',
                style: TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 10,
                ),
              ),
              Text(
                '5 PM',
                style: TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 10.0;
    const rightPadding = 10.0;
    const topPadding = 10.0;
    const bottomPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()
      ..color = JDColors.border
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = _alertRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = _alertRed.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = _alertRed
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final y = topPadding + (chartHeight / 3) * i;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    final points = [
      Offset(leftPadding, topPadding + chartHeight * 0.84),
      Offset(leftPadding + chartWidth * 0.18, topPadding + chartHeight * 0.80),
      Offset(leftPadding + chartWidth * 0.36, topPadding + chartHeight * 0.69),
      Offset(leftPadding + chartWidth * 0.54, topPadding + chartHeight * 0.51),
      Offset(leftPadding + chartWidth * 0.72, topPadding + chartHeight * 0.30),
      Offset(leftPadding + chartWidth, topPadding + chartHeight * 0.08),
    ];

    final linePath = Path();

    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, topPadding + chartHeight)
      ..lineTo(points.first.dx, topPadding + chartHeight)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        i == points.length - 1 ? 6 : 4,
        pointPaint,
      );
    }

    final selectedPointBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      points.last,
      6,
      selectedPointBorder,
    );
  }

  @override
  bool shouldRepaint(covariant _AlertTrendPainter oldDelegate) {
    return false;
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard();

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
        children: [
          _ActionRow(
            number: '1',
            label: 'Verify the next field reading',
          ),
          SizedBox(height: 15),
          _ActionRow(
            number: '2',
            label: 'Notify the responsible officer',
          ),
          SizedBox(height: 15),
          _ActionRow(
            number: '3',
            label: 'Monitor nearby river stations',
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.number,
    required this.label,
  });

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 29,
          height: 29,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: JDColors.lightBlue,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: JDColors.waterBlue,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: JDColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}