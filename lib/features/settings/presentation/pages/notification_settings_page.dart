import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _goalReminders = true;
  bool _friendRequests = true;
  bool _messages = true;
  bool _achievements = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push Notifications Section
            _buildSectionHeader('Push Notifications'),
            _buildSettingsCard(
              child: _buildToggleItem(
                title: 'Enable Push Notifications',
                subtitle: 'Receive notifications on your device',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            // Email Notifications Section
            _buildSectionHeader('Email Notifications'),
            _buildSettingsCard(
              child: _buildToggleItem(
                title: 'Email Notifications',
                subtitle: 'Receive updates via email',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            // Notification Types Section
            _buildSectionHeader('Notification Types'),
            _buildSettingsCard(
              children: [
                _buildToggleItem(
                  title: 'Goal Reminders',
                  subtitle: 'Reminders for your goals and habits',
                  value: _goalReminders,
                  onChanged: (value) {
                    setState(() {
                      _goalReminders = value;
                    });
                  },
                ),
                _buildDivider(),
                _buildToggleItem(
                  title: 'Friend Requests',
                  subtitle: 'When someone sends you a friend request',
                  value: _friendRequests,
                  onChanged: (value) {
                    setState(() {
                      _friendRequests = value;
                    });
                  },
                ),
                _buildDivider(),
                _buildToggleItem(
                  title: 'Messages',
                  subtitle: 'New messages from friends',
                  value: _messages,
                  onChanged: (value) {
                    setState(() {
                      _messages = value;
                    });
                  },
                ),
                _buildDivider(),
                _buildToggleItem(
                  title: 'Achievements',
                  subtitle: 'When you unlock achievements',
                  value: _achievements,
                  onChanged: (value) {
                    setState(() {
                      _achievements = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({Widget? child, List<Widget>? children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child ?? Column(children: children!),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.withOpacity(0.2),
    );
  }
}

