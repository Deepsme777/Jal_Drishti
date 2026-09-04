import 'package:flutter/material.dart';

import '../theme/jd_colors.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log out?',
            style: TextStyle(
              color: JDColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'You will need to sign in again to access your field-monitoring workspace.',
            style: TextStyle(
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
                Navigator.pop(dialogContext);
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
                Navigator.pop(dialogContext);
                _showMessage('Logout will be connected to authentication later.');
              },
              child: const Text(
                'Log out',
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile & settings',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 20),
          _ProfileCard(
            onEditProfile: () {
              _showMessage('Profile editing will be added later.');
            },
          ),
          const SizedBox(height: 26),
          const Text(
            'Preferences',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              _SettingsSwitchTile(
                icon: Icons.notifications_none_rounded,
                iconColor: JDColors.amber,
                title: 'Alert notifications',
                subtitle: 'Receive important water-level updates',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const _SettingsDivider(),
              _SettingsSwitchTile(
                icon: Icons.sync_rounded,
                iconColor: JDColors.teal,
                title: 'Automatic sync',
                subtitle: 'Sync readings when connected',
                value: _autoSyncEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoSyncEnabled = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            'Account',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              _SettingsActionTile(
                icon: Icons.badge_outlined,
                iconColor: JDColors.waterBlue,
                title: 'Field officer details',
                subtitle: 'Role, assigned region and station access',
                onTap: () {
                  _showMessage('Officer details will be added later.');
                },
              ),
              const _SettingsDivider(),
              _SettingsActionTile(
                icon: Icons.lock_outline_rounded,
                iconColor: JDColors.teal,
                title: 'Privacy & security',
                subtitle: 'Manage account protection settings',
                onTap: () {
                  _showMessage('Privacy settings will be added later.');
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            'Support',
            style: TextStyle(
              color: JDColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              _SettingsActionTile(
                icon: Icons.help_outline_rounded,
                iconColor: JDColors.teal,
                title: 'Help & support',
                subtitle: 'Get help using Jal-Drishti',
                onTap: () {
                  _showMessage('Support resources will be added later.');
                },
              ),
              const _SettingsDivider(),
              _SettingsActionTile(
                icon: Icons.info_outline_rounded,
                iconColor: JDColors.mutedText,
                title: 'About Jal-Drishti',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  _showMessage('Jal-Drishti version 1.0.0');
                },
              ),
            ],
          ),
          const SizedBox(height: 23),
          SizedBox(
            width: double.infinity,
            height: 53,
            child: OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Log out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: JDColors.red,
                side: BorderSide(
                  color: JDColors.red.withValues(alpha: 0.45),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Jal-Drishti • Water Monitoring System',
              style: TextStyle(
                color: JDColors.mutedText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.onEditProfile,
  });

  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: JDColors.border),
        boxShadow: [
          BoxShadow(
            color: JDColors.navy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: JDColors.waterBlue,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'D',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deeps',
                  style: TextStyle(
                    color: JDColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Field Officer',
                  style: TextStyle(
                    color: JDColors.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Jal-Drishti field monitoring team',
                  style: TextStyle(
                    color: JDColors.mutedText,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditProfile,
            icon: const Icon(
              Icons.edit_outlined,
              color: JDColors.waterBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JDColors.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 10, 14),
      child: Row(
        children: [
          _SettingsIcon(
            icon: icon,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SettingsText(
              title: title,
              subtitle: subtitle,
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: JDColors.waterBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          child: Row(
            children: [
              _SettingsIcon(
                icon: icon,
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SettingsText(
                  title: title,
                  subtitle: subtitle,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: JDColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 41,
      height: 41,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }
}

class _SettingsText extends StatelessWidget {
  const _SettingsText({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: JDColors.navy,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: JDColors.mutedText,
            fontSize: 11.5,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      color: JDColors.border,
    );
  }
}