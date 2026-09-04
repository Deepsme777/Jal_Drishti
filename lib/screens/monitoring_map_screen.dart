import 'package:flutter/material.dart';

import '../theme/jd_colors.dart';
import 'water_level_analytics_screen.dart';

class MonitoringMapScreen extends StatefulWidget {
  const MonitoringMapScreen({super.key});

  @override
  State<MonitoringMapScreen> createState() => _MonitoringMapScreenState();
}

class _MonitoringMapScreenState extends State<MonitoringMapScreen> {
  final List<_StationMarkerData> _stations = const [
    _StationMarkerData(
      stationId: '014',
      river: 'Kaveri River',
      level: '2.84 m',
      status: 'Watch',
      updated: 'Updated 5 minutes ago',
      markerColor: JDColors.amber,
      x: 0.53,
      y: 0.43,
    ),
    _StationMarkerData(
      stationId: '022',
      river: 'Palar River',
      level: '1.76 m',
      status: 'Normal',
      updated: 'Updated 18 minutes ago',
      markerColor: JDColors.green,
      x: 0.26,
      y: 0.60,
    ),
    _StationMarkerData(
      stationId: '031',
      river: 'Musi River',
      level: '2.11 m',
      status: 'Normal',
      updated: 'Updated 26 minutes ago',
      markerColor: JDColors.green,
      x: 0.72,
      y: 0.68,
    ),
    _StationMarkerData(
      stationId: '046',
      river: 'Bhavani River',
      level: '3.42 m',
      status: 'Alert',
      updated: 'Updated 8 minutes ago',
      markerColor: JDColors.red,
      x: 0.78,
      y: 0.28,
    ),
    _StationMarkerData(
      stationId: '059',
      river: 'Amaravathi River',
      level: '—',
      status: 'Offline',
      updated: 'Last updated 3 hours ago',
      markerColor: Colors.grey,
      x: 0.34,
      y: 0.29,
    ),
  ];

  late _StationMarkerData _selectedStation;

  @override
  void initState() {
    super.initState();
    _selectedStation = _stations.first;
  }

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
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _MapBackgroundPainter(),
          ),
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: _stations.map((station) {
                  final isSelected =
                      station.stationId == _selectedStation.stationId;

                  return Positioned(
                    left: constraints.maxWidth * station.x - 23,
                    top: constraints.maxHeight * station.y - 23,
                    child: _StationMapMarker(
                      station: station,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedStation = station;
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Positioned(
          top: 17,
          left: 18,
          right: 18,
          child: Column(
            children: [
              Container(
                height: 53,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: JDColors.navy.withValues(alpha: 0.13),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: JDColors.mutedText,
                      size: 24,
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'Search station or river',
                        style: TextStyle(
                          color: JDColors.mutedText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.tune_rounded,
                      color: JDColors.waterBlue,
                      size: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const _MapLegend(),
            ],
          ),
        ),
        Positioned(
          right: 18,
          bottom: 214,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            elevation: 4,
            child: InkWell(
              onTap: () {
                _showMessage('Your current location will be added later.');
              },
              borderRadius: BorderRadius.circular(15),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.my_location_rounded,
                  color: JDColors.waterBlue,
                  size: 23,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: _SelectedStationCard(
            station: _selectedStation,
            onOpenStation: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WaterLevelAnalyticsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StationMapMarker extends StatelessWidget {
  const _StationMapMarker({
    required this.station,
    required this.selected,
    required this.onTap,
  });

  final _StationMarkerData station;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: selected ? 48 : 42,
        height: selected ? 48 : 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: station.markerColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: selected ? 4 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: station.markerColor.withValues(alpha: 0.35),
              blurRadius: selected ? 14 : 8,
              spreadRadius: selected ? 2 : 0,
            ),
          ],
        ),
        child: Icon(
          station.status == 'Offline'
              ? Icons.cloud_off_rounded
              : Icons.water_drop_rounded,
          color: Colors.white,
          size: selected ? 25 : 21,
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: JDColors.navy.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(
            color: JDColors.green,
            label: 'Normal',
          ),
          SizedBox(width: 10),
          _LegendItem(
            color: JDColors.amber,
            label: 'Watch',
          ),
          SizedBox(width: 10),
          _LegendItem(
            color: JDColors.red,
            label: 'Alert',
          ),
          SizedBox(width: 10),
          _LegendItem(
            color: Colors.grey,
            label: 'Offline',
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: JDColors.text,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SelectedStationCard extends StatelessWidget {
  const _SelectedStationCard({
    required this.station,
    required this.onOpenStation,
  });

  final _StationMarkerData station;
  final VoidCallback onOpenStation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: JDColors.navy.withValues(alpha: 0.17),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: station.markerColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: station.markerColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${station.river} – Station ${station.stationId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: JDColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      station.updated,
                      style: const TextStyle(
                        color: JDColors.mutedText,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: station.markerColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  station.status,
                  style: TextStyle(
                    color: station.markerColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text(
                'Current level',
                style: TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                station.level,
                style: TextStyle(
                  color: station.markerColor == JDColors.red
                      ? JDColors.red
                      : JDColors.waterBlue,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: onOpenStation,
              style: ElevatedButton.styleFrom(
                backgroundColor: JDColors.waterBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Open station',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()
      ..color = const Color(0xFFE7F0E4)
      ..style = PaintingStyle.fill;

    final waterPaint = Paint()
      ..color = const Color(0xFF86D0E4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19
      ..strokeCap = StrokeCap.round;

    final roadPaint = Paint()
      ..color = const Color(0xFFFDFCF5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final minorRoadPaint = Paint()
      ..color = const Color(0xFFCDD7CF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final townPaint = Paint()
      ..color = const Color(0xFF92A89A)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      landPaint,
    );

    final river = Path()
      ..moveTo(size.width * 0.12, size.height * 0.05)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.20,
        size.width * 0.19,
        size.height * 0.39,
        size.width * 0.49,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.77,
        size.height * 0.60,
        size.width * 0.72,
        size.height * 0.79,
        size.width * 0.93,
        size.height * 0.96,
      );

    canvas.drawPath(river, waterPaint);

    final roadOne = Path()
      ..moveTo(-10, size.height * 0.25)
      ..lineTo(size.width * 0.27, size.height * 0.36)
      ..lineTo(size.width * 0.62, size.height * 0.28)
      ..lineTo(size.width + 10, size.height * 0.42);

    final roadTwo = Path()
      ..moveTo(size.width * 0.08, size.height * 0.80)
      ..lineTo(size.width * 0.37, size.height * 0.66)
      ..lineTo(size.width * 0.64, size.height * 0.75)
      ..lineTo(size.width * 0.94, size.height * 0.61);

    canvas.drawPath(roadOne, roadPaint);
    canvas.drawPath(roadTwo, roadPaint);

    final minorRoadOne = Path()
      ..moveTo(size.width * 0.10, size.height * 0.52)
      ..lineTo(size.width * 0.33, size.height * 0.45)
      ..lineTo(size.width * 0.62, size.height * 0.56)
      ..lineTo(size.width * 0.88, size.height * 0.47);

    final minorRoadTwo = Path()
      ..moveTo(size.width * 0.18, size.height * 0.16)
      ..lineTo(size.width * 0.43, size.height * 0.25)
      ..lineTo(size.width * 0.74, size.height * 0.15);

    canvas.drawPath(minorRoadOne, minorRoadPaint);
    canvas.drawPath(minorRoadTwo, minorRoadPaint);

    final towns = [
      Offset(size.width * 0.18, size.height * 0.40),
      Offset(size.width * 0.43, size.height * 0.20),
      Offset(size.width * 0.66, size.height * 0.53),
      Offset(size.width * 0.82, size.height * 0.76),
      Offset(size.width * 0.28, size.height * 0.74),
    ];

    for (final town in towns) {
      canvas.drawCircle(town, 5, townPaint);
      canvas.drawCircle(town, 10, townPaint..color = townPaint.color.withValues(alpha: 0.15));
      townPaint.color = const Color(0xFF92A89A);
    }
  }

  @override
  bool shouldRepaint(covariant _MapBackgroundPainter oldDelegate) {
    return false;
  }
}

class _StationMarkerData {
  const _StationMarkerData({
    required this.stationId,
    required this.river,
    required this.level,
    required this.status,
    required this.updated,
    required this.markerColor,
    required this.x,
    required this.y,
  });

  final String stationId;
  final String river;
  final String level;
  final String status;
  final String updated;
  final Color markerColor;
  final double x;
  final double y;
}