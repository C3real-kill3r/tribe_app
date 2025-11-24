import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  final _searchController = TextEditingController();
  bool _onlineStatusVisible = true;
  bool _appearInSuggestions = true;
  bool _shareActivity = true;

  String _profileVisibility = 'Friends Only';
  String _friendRequests = 'Friends of Friends';
  String _directMessages = 'Friends Only';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search settings',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Visibility Section
                  _buildSectionTitle('Profile Visibility'),
                  _buildSettingsCard(
                    children: [
                      _buildSelectableItem(
                        icon: Icons.person_outline,
                        title: 'Who can see my profile',
                        subtitle: 'Control who can view your profile and goals',
                        value: _profileVisibility,
                        onTap: () => _showProfileVisibilityDialog(),
                      ),
                      _buildDivider(),
                      _buildToggleItem(
                        icon: Icons.visibility,
                        title: 'Who can see my online status',
                        subtitle: 'Allow others to see when you\'re active',
                        value: _onlineStatusVisible,
                        onChanged: (value) {
                          setState(() {
                            _onlineStatusVisible = value;
                          });
                        },
                      ),
                      _buildDivider(),
                      _buildToggleItem(
                        icon: Icons.group_add,
                        title: 'Appear in friend suggestions',
                        subtitle: 'Let others discover your profile',
                        value: _appearInSuggestions,
                        onChanged: (value) {
                          setState(() {
                            _appearInSuggestions = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Interactions Section
                  _buildSectionTitle('Interactions'),
                  _buildSettingsCard(
                    children: [
                      _buildSelectableItem(
                        icon: Icons.person_add,
                        title: 'Who can send friend requests',
                        subtitle: 'Manage incoming friend requests',
                        value: _friendRequests,
                        onTap: () => _showFriendRequestsDialog(),
                      ),
                      _buildDivider(),
                      _buildSelectableItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Who can send direct messages',
                        subtitle: 'Filter messages from unknown people',
                        value: _directMessages,
                        onTap: () => _showDirectMessagesDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Data & Information Section
                  _buildSectionTitle('Data & Information'),
                  _buildSettingsCard(
                    children: [
                      _buildToggleItem(
                        icon: Icons.trending_up,
                        title: 'Share activity with friends',
                        subtitle: 'Show goal progress on your profile',
                        value: _shareActivity,
                        onChanged: (value) {
                          setState(() {
                            _shareActivity = value;
                          });
                        },
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        icon: Icons.download,
                        title: 'Download your data',
                        subtitle: 'Get a copy of your information',
                        onTap: () {
                          // Handle download data
                        },
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        icon: Icons.delete_outline,
                        title: 'Delete your account',
                        subtitle: 'Permanently remove your account',
                        iconColor: Colors.red,
                        onTap: () {
                          _showDeleteAccountDialog();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Footer Links
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        Text(
                          ' · ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Terms of Service',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSelectableItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
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
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
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

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: iconColor,
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 80,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  void _showProfileVisibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Who can see my profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Everyone'),
              value: 'Everyone',
              groupValue: _profileVisibility,
              onChanged: (value) {
                setState(() {
                  _profileVisibility = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Friends Only'),
              value: 'Friends Only',
              groupValue: _profileVisibility,
              onChanged: (value) {
                setState(() {
                  _profileVisibility = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Private'),
              value: 'Private',
              groupValue: _profileVisibility,
              onChanged: (value) {
                setState(() {
                  _profileVisibility = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFriendRequestsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Who can send friend requests'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Everyone'),
              value: 'Everyone',
              groupValue: _friendRequests,
              onChanged: (value) {
                setState(() {
                  _friendRequests = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Friends of Friends'),
              value: 'Friends of Friends',
              groupValue: _friendRequests,
              onChanged: (value) {
                setState(() {
                  _friendRequests = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('No One'),
              value: 'No One',
              groupValue: _friendRequests,
              onChanged: (value) {
                setState(() {
                  _friendRequests = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDirectMessagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Who can send direct messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Everyone'),
              value: 'Everyone',
              groupValue: _directMessages,
              onChanged: (value) {
                setState(() {
                  _directMessages = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Friends Only'),
              value: 'Friends Only',
              groupValue: _directMessages,
              onChanged: (value) {
                setState(() {
                  _directMessages = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle account deletion
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

