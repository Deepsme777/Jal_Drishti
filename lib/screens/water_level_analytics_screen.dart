import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';

class WaterLevelAnalyticsScreen extends StatefulWidget {
  const WaterLevelAnalyticsScreen({super.key});

  @override
  State<WaterLevelAnalyticsScreen> createState() =>
      _WaterLevelAnalyticsScreenState();
}

class _WaterLevelAnalyticsScreenState
    extends State<WaterLevelAnalyticsScreen> {
  String _selectedRange = '7 days';

  final List<double> _sevenDayData = const [
    2.36,
    2.42,
    2.50,
    2.47,
    2.58,
    2.66,
    2.84,
  ];

  final List<String> _sevenDayLabels = const [
    '09 Aug',
    '10 Aug',
    '11 Aug',
    '12 Aug',
    '13 Aug',
    '14 Aug',
    '15 Aug',
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
                        'Water level analytics',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showMessage('Export report will be added later.');
                      },
                      icon: const Icon(
                        Icons.file_download_outlined,
                        color: JDColors.navy,
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
                        'Kaveri River – Station 014',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Talakaveri Region  •  Updated 5 minutes ago',
                        style: TextStyle(
                          color: JDColors.mutedText,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 19),
                      const _StationStatusCard(),
                      const SizedBox(height: 20),
                      const Text(
                        'Water level trend',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _RangeSelector(
                        selectedRange: _selectedRange,
                        onSelected: (range) {
                          if (range == 'Custom') {
                            _showMessage('Custom date selection comes next.');
                            return;
                          }

                          setState(() {
                            _selectedRange = range;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _TrendChartCard(
                        title: 'Water level trend — $_selectedRange',
                        values: _sevenDayData,
                        labels: _sevenDayLabels,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Station summary',
                        style: TextStyle(
                          color: JDColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _AnalyticsSummaryGrid(),
                      const SizedBox(height: 22),
                      const _MonitoringNote(),
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

class _StationStatusCard extends StatelessWidget {
  const _StationStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: JDColors.amber.withValues(alpha: 0.28),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.trending_up_rounded,
            color: JDColors.amber,
            size: 31,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rising water level detected',
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Current station status: Watch',
                  style: TextStyle(
                    color: JDColors.text,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _WatchBadge(),
        ],
      ),
    );
  }
}

class _WatchBadge extends StatelessWidget {
  const _WatchBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: JDColors.amber.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Watch',
        style: TextStyle(
          color: JDColors.amber,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.selectedRange,
    required this.onSelected,
  });

  final String selectedRange;
  final void Function(String range) onSelected;

  @override
  Widget build(BuildContext context) {
    const ranges = [
      '24 hours',
      '7 days',
      '30 days',
      'Custom',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ranges.map((range) {
        final selected = range == selectedRange;

        return ChoiceChip(
          label: Text(
            range,
            style: TextStyle(
              color: selected ? Colors.white : JDColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          selected: selected,
          showCheckmark: false,
          selectedColor: JDColors.waterBlue,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: selected ? JDColors.waterBlue : JDColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          onSelected: (_) {
            onSelected(range);
          },
        );
      }).toList(),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({
    required this.title,
    required this.values,
    required this.labels,
  });

  final String title;
  final List<double> values;
  final List<String> labels;

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
          Text(
            title,
            style: const TextStyle(
              color: JDColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Level in meters',
            style: TextStyle(
              color: JDColors.mutedText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 175,
            width: double.infinity,
            child: CustomPaint(
              painter: _WaterTrendPainter(values),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((label) {
              return Text(
                label.substring(0, 2),
                style: const TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WaterTrendPainter extends CustomPainter {
  _WaterTrendPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 30;
    const double rightPadding = 8;
    const double topPadding = 12;
    const double bottomPadding = 14;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    const minValue = 2.20;
    const maxValue = 3.00;

    final gridPaint = Paint()
      ..color = JDColors.border
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = JDColors.waterBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = JDColors.waterBlue.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = JDColors.waterBlue
      ..style = PaintingStyle.fill;

    final lastPointPaint = Paint()
      ..color = JDColors.green
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const yLabels = ['3.0', '2.8', '2.6', '2.4'];

    for (int i = 0; i < 4; i++) {
      final y = topPadding + (chartHeight / 3) * i;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(
          color: JDColors.mutedText,
          fontSize: 10,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(0, y - 6),
      );
    }

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = leftPadding +
          (chartWidth / (values.length - 1)) * i;

      final normalized =
          (values[i] - minValue) / (maxValue - minValue);

      final y = topPadding + chartHeight - normalized * chartHeight;

      points.add(Offset(x, y));
    }

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
        i == points.length - 1 ? 6 : 4.5,
        i == points.length - 1 ? lastPointPaint : pointPaint,
      );

      if (i == points.length - 1) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(
          points[i],
          6,
          borderPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WaterTrendPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _AnalyticsSummaryGrid extends StatelessWidget {
  const _AnalyticsSummaryGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Current',
                value: '2.84 m',
                icon: Icons.water_drop_rounded,
                color: JDColors.waterBlue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: '24-hour change',
                value: '+0.18 m',
                icon: Icons.trending_up_rounded,
                color: JDColors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: '7-day average',
                value: '2.61 m',
                icon: Icons.analytics_outlined,
                color: JDColors.teal,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: 'Trend',
                value: 'Rising',
                icon: Icons.show_chart_rounded,
                color: JDColors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 121,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: JDColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 33,
            height: 33,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color == JDColors.amber ? JDColors.navy : color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: JDColors.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitoringNote extends StatelessWidget {
  const _MonitoringNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: JDColors.lightBlue,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: JDColors.waterBlue.withValues(alpha: 0.16),
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
              'The water level has increased steadily over the last 24 hours. Verify the next field reading and monitor nearby stations.',
              style: TextStyle(
                color: JDColors.text,
                fontSize: 13,
                height: 1.42,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}