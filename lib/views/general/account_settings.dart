import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/views/general/main_layout_view.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      title: Text(
        'Account Settings',
        style: TextStyle(
          color: context.themeValue(
            light: AppColors.lightText,
            dark: AppColors.darkText,
          ),
        ),
      ),
      showNavbar: false,
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildSettingsTile(
            icon: Icons.tune,
            title: 'Notification Settings',
            onTap: () => _navigateToNotificationSettings(),
          ),

          const Divider(),

          // Privacy & Security Section
          _buildSectionHeader('Privacy & Security'),
          _buildSettingsTile(
            icon: Icons.block,
            title: 'Blocked Users',
            onTap: () => _navigateToBlockedUsers(),
          ),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            onTap: () => _navigateToTwoFactor(),
          ),

          const Divider(),

          // App Settings Section
          _buildSectionHeader('App Settings'),
          _buildSettingsTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Change app appearance',
            onTap: () => _navigateToTheme(),
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _navigateToLanguage(),
          ),

          const Divider(),

          // Support Section
          _buildSectionHeader('Support'),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Help Center',
            onTap: () => _navigateToHelp(),
          ),
          _buildSettingsTile(
            icon: Icons.feedback,
            title: 'Send Feedback',
            onTap: () => _sendFeedback(),
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About',
            onTap: () => _navigateToAbout(),
          ),

          const Divider(),

          // Logout Section
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Log Out',
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[700]),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  void _navigateToNotificationSettings() {
    // Navigate to notification settings
  }

  void _navigateToBlockedUsers() {
    // Navigate to blocked users list
  }

  void _navigateToTwoFactor() {
    // Navigate to 2FA settings
  }

  void _navigateToTheme() {
    // Navigate to theme settings
  }

  void _navigateToLanguage() {
    // Navigate to language settings
  }

  void _navigateToHelp() {
    // Navigate to help center
  }

  void _sendFeedback() {
    // Open feedback form
  }

  void _navigateToAbout() {
    // Navigate to about page
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Perform logout
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
