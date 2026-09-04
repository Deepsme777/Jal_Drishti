import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/jd_colors.dart';
import 'alert_screen.dart';
import 'station_qr_flow.dart';
import 'reading_history_screen.dart';
import 'monitoring_map_screen.dart';
import 'profile_settings_screen.dart';
import 'capture_reading_screen.dart';


class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: JDColors.background,
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _DashboardHome(
                onCapture: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                onScanQr: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QrScannerScreen(),
                    ),
                  );
                },
                onAlerts: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AlertScreen(),
                    ),
                  );
                },
              ),
              CaptureReadingScreen(
                isActive: _selectedIndex == 1,
              ),
              const MonitoringMapScreen(),
              const ReadingHistoryScreen(),
              const ProfileSettingsScreen(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          height: 72,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFD9F2F4),
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt_rounded),
              label: 'Capture',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({
    required this.onCapture,
    required this.onScanQr,
    required this.onAlerts,
  });

  final VoidCallback onCapture;
  final VoidCallback onScanQr;
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(
            onAlerts: onAlerts,
          ),
          const SizedBox(height: 28),
          const Text(
            'Good afternoon, Deeps',
            style: TextStyle(
              color: JDColors.mutedText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Water Monitoring',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 22),
          const _SystemStatusCard(),
          const SizedBox(height: 27),
          const Text(
            'Quick actions',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'Capture\nReading',
                  subtitle: 'Scan gauge and measure water level',
                  icon: Icons.camera_alt_rounded,
                  accentColor: JDColors.waterBlue,
                  onTap: onCapture,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: _QuickActionCard(
                  title: 'Scan\nStation QR',
                  subtitle: 'Identify a monitoring location',
                  icon: Icons.qr_code_scanner_rounded,
                  accentColor: JDColors.teal,
                  onTap: onScanQr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Nearby Stations',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 13),
          const _StationCard(
            stationName: 'Kaveri River – Station 014',
            distance: '1.2 km away',
            level: '2.84 m',
            status: 'Watch',
            statusColor: JDColors.amber,
          ),
          const SizedBox(height: 11),
          const _StationCard(
            stationName: 'Palar River – Station 022',
            distance: '3.8 km away',
            level: '1.76 m',
            status: 'Normal',
            statusColor: JDColors.green,
          ),
          const SizedBox(height: 11),
          const _StationCard(
            stationName: 'Musi River – Station 031',
            distance: '5.4 km away',
            level: '2.11 m',
            status: 'Normal',
            statusColor: JDColors.green,
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.onAlerts,
  });

  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 47,
          height: 47,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: JDColors.waterBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: 29,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jal-Drishti',
              style: TextStyle(
                color: JDColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'जल-दृ',
              style: TextStyle(
                color: JDColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onAlerts,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 45,
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: JDColors.border),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: JDColors.navy,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SystemStatusCard extends StatelessWidget {
  const _SystemStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JDColors.border),
        boxShadow: [
          BoxShadow(
            color: JDColors.navy.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: JDColors.lightGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.cloud_done_rounded,
              color: JDColors.green,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System status',
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Last sync: Just now',
                  style: TextStyle(
                    color: JDColors.mutedText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: JDColors.lightGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  color: JDColors.green,
                  size: 9,
                ),
                SizedBox(width: 6),
                Text(
                  'Online',
                  style: TextStyle(
                    color: JDColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 202,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: JDColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47,
                height: 47,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 25,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: JDColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                style: const TextStyle(
                  color: JDColors.mutedText,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard({
    required this.stationName,
    required this.distance,
    required this.level,
    required this.status,
    required this.statusColor,
  });

  final String stationName;
  final String distance;
  final String level;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: JDColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: JDColors.lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.water_rounded,
              color: JDColors.waterBlue,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: JDColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$distance  •  Current level: $level',
                  style: const TextStyle(
                    color: JDColors.mutedText,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}