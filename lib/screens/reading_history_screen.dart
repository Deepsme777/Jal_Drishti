import 'dart:io';

import 'package:flutter/material.dart';

import '../data/reading_store.dart';
import '../theme/jd_colors.dart';
import 'reading_detail_screen.dart';

class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  String _selectedFilter = 'All';

  List<WaterReading> _filterReadings(List<WaterReading> readings) {
    if (_selectedFilter == 'All') {
      return readings;
    }

    return readings
        .where(
          (reading) => reading.status == _selectedFilter,
        )
        .toList();
  }

  Future<void> _confirmDeleteReading(WaterReading reading) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          'Delete reading?',
          style: TextStyle(
            color: JDColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Delete the ${reading.levelLabel} reading from ${reading.stationName}? This cannot be undone.',
          style: const TextStyle(
            color: JDColors.text,
            height: 1.4,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: JDColors.mutedText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: JDColors.red,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true) {
    return;
  }

  await ReadingStore.deleteReading(reading);

  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Reading deleted permanently.'),
      behavior: SnackBarBehavior.floating,
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<WaterReading>>(
      valueListenable: ReadingStore.readings,
      builder: (context, readings, child) {
        final filteredReadings = _filterReadings(readings);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reading history',
                style: TextStyle(
                  color: JDColors.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${readings.length} water-level readings available',
                style: const TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              _HistorySummaryCard(
                totalReadings: readings.length,
              ),
              const SizedBox(height: 25),
              const Text(
                'Filter readings',
                style: TextStyle(
                  color: JDColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _HistoryFilterChip(
                    label: 'All',
                    selected: _selectedFilter == 'All',
                    onSelected: () {
                      setState(() {
                        _selectedFilter = 'All';
                      });
                    },
                  ),
                  _HistoryFilterChip(
                    label: 'Watch',
                    selected: _selectedFilter == 'Watch',
                    onSelected: () {
                      setState(() {
                        _selectedFilter = 'Watch';
                      });
                    },
                  ),
                  _HistoryFilterChip(
                    label: 'Normal',
                    selected: _selectedFilter == 'Normal',
                    onSelected: () {
                      setState(() {
                        _selectedFilter = 'Normal';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                _selectedFilter == 'All'
                    ? 'All readings'
                    : '$_selectedFilter readings',
                style: const TextStyle(
                  color: JDColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (filteredReadings.isEmpty)
                const _EmptyHistoryState()
              else
                ...filteredReadings.map(
                  (reading) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReadingHistoryCard(
                      reading: reading,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReadingDetailScreen(
                              reading: reading,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        _confirmDeleteReading(reading);
                      },
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

class _HistorySummaryCard extends StatelessWidget {
  const _HistorySummaryCard({
    required this.totalReadings,
  });

  final int totalReadings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: JDColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: JDColors.waterBlue.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: JDColors.waterBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Field readings',
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalReadings saved readings in this session',
                  style: const TextStyle(
                    color: JDColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            totalReadings.toString(),
            style: const TextStyle(
              color: JDColors.waterBlue,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : JDColors.mutedText,
          fontSize: 12,
          fontWeight: FontWeight.w800,
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
        onSelected();
      },
    );
  }
}

class _ReadingHistoryCard extends StatelessWidget {
  const _ReadingHistoryCard({
    required this.reading,
    required this.onTap,
    required this.onDelete,
  });

  final WaterReading reading;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color get _statusColor {
    if (reading.status == 'Watch') {
      return JDColors.amber;
    }

    if (reading.status == 'Alert') {
      return JDColors.red;
    }

    return JDColors.green;
  }

  Color get _statusBackground {
    if (reading.status == 'Watch') {
      return const Color(0xFFFFF2D9);
    }

    if (reading.status == 'Alert') {
      return const Color(0xFFFFE4E2);
    }

    return JDColors.lightGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: JDColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReadingImageOrIcon(
                imagePath: reading.imagePath,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.stationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: JDColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reading.stationRegion,
                      style: const TextStyle(
                        color: JDColors.mutedText,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: JDColors.mutedText,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${reading.dateLabel} • ${reading.timeLabel}',
                          style: const TextStyle(
                            color: JDColors.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(16),
                      child: const SizedBox(
                        width: 31,
                        height: 28,
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: JDColors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    reading.levelLabel,
                    style: const TextStyle(
                      color: JDColors.waterBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      reading.status,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingImageOrIcon extends StatelessWidget {
  const _ReadingImageOrIcon({
    required this.imagePath,
  });

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.file(
          File(imagePath!),
          width: 48,
          height: 62,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 48,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: JDColors.lightBlue,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(
        Icons.water_drop_rounded,
        color: JDColors.waterBlue,
        size: 26,
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JDColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: JDColors.mutedText,
            size: 35,
          ),
          SizedBox(height: 12),
          Text(
            'No readings found',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try selecting a different filter.',
            style: TextStyle(
              color: JDColors.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}