import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tribe/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings/notifications'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', _selectedFilter == 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Goals', _selectedFilter == 'Goals'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Social', _selectedFilter == 'Social'),
                  const SizedBox(width: 8),
                  _buildFilterChip('System', _selectedFilter == 'System'),
                ],
              ),
            ),
          ),
          // Notifications List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _buildDateHeader('Today'),
                _buildNotificationItem(
                  context,
                  icon: Icons.celebration,
                  iconColor: accentColor,
                  title: 'Goal Completed! 🎉',
                  message: 'You and 3 friends completed "Run a 5k" goal',
                  time: '2 hours ago',
                  isUnread: true,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD9WT6XnxjMQK5dUp3VOLWft2BydqDrbYxsC6kILvr_Rb5dPIeLFAoPKl6yFzsiVLmXQXeXGDfL4j8CkgELI27Aj1lK9rNuTvHrHei2ixZ9nHMFHx0WgLvVBUcUl5eh5OAITXBkMUrQQG9WPFYLmORxtYJLcUncB5Oe_3JJvA61tAkw0p-16ov7NDZnSAI0HV-p9ybPtozZZfRAY5kSZl3dNQfdIfX_x2XFm3Nvsmg3VbmgJQiOiLji52qb2qvCI7iYNTWywY4aGIs',
                  onTap: () => context.go('/goals/group'),
                ),
                _buildNotificationItem(
                  context,
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                  title: 'New Like',
                  message: 'Alvin Amwata liked your memory "Weekend Trip"',
                  time: '3 hours ago',
                  isUnread: true,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBI-EAHM1ea5gJFYdzEHRc10JyVRmp8xNZNtZFXNTrZGEzKawcFEfPNwRMhz5ZeIX4ZRYrW8PHK1BWV-yE0vZJ7TBDqmF73WBpZzUrRNcnOUIZeo6YFZw5BVSuMVVuyIW2UqvilfcIFmj8V0YFoUZADYH_WUTq30oVj0or_PvPAGqUKm6CHBiweKHhKnbQWebJiwovmpSvTBA40if-_kS95NrmoJx1aS6T-0OOSJCDV2NNT-d7RDE6Auwo1n6zQBeVvN0ozhHBtVto',
                  onTap: () => context.go('/memories'),
                ),
                _buildNotificationItem(
                  context,
                  icon: Icons.comment,
                  iconColor: accentColor,
                  title: 'New Comment',
                  message: 'Tabitha Ombura commented: "This looks amazing! Where is this?"',
                  time: '5 hours ago',
                  isUnread: true,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDArl7QkZFntBm-LiPqnf9d7_eIYO8sEi499lpBBQ3N_jVFRiBYxGJ08yZI-I7ziKT32govvTTbznPfZX9r7uE3lOD1a3VPT7XDML4SXzRVoErm2JDEKvujLUxml37zx3uAwjoAGTcrnJusnReofRvyNoFveBZTXJa5xFaKY0_efoRxDR5T9jCHupi9vZFBX9ohNjicDV6_ls8ORZc8jFJaeoPBdvzPKhruFU-vBQW3NV9Gi9nAJFQWG2DMBRmnsTKkbOPneonG6QY',
                  onTap: () => context.go('/memories'),
                ),
                _buildNotificationItem(
                  context,
                  icon: Icons.person_add,
                  iconColor: accentColor,
                  title: 'Friend Request',
                  message: 'Derrick Juma wants to be your accountability partner',
                  time: '6 hours ago',
                  isUnread: true,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
                  onTap: () {},
                  actionButtons: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Accept', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Decline', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDateHeader('Yesterday'),
                _buildNotificationItem(
                  context,
                  icon: Icons.trending_up,
                  iconColor: accentColor,
                  title: 'Progress Update',
                  message: 'You\'re 75% closer to your "Trip to Costa Rica" goal',
                  time: 'Yesterday',
                  isUnread: false,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD9WT6XnxjMQK5dUp3VOLWft2BydqDrbYxsC6kILvr_Rb5dPIeLFAoPKl6yFzsiVLmXQXeXGDfL4j8CkgELI27Aj1lK9rNuTvHrHei2ixZ9nHMFHx0WgLvVBUcUl5eh5OAITXBkMUrQQG9WPFYLmORxtYJLcUncB5Oe_3JJvA61tAkw0p-16ov7NDZnSAI0HV-p9ybPtozZZfRAY5kSZl3dNQfdIfX_x2XFm3Nvsmg3VbmgJQiOiLji52qb2qvCI7iYNTWywY4aGIs',
                  onTap: () => context.go('/goals'),
                ),
                _buildNotificationItem(
                  context,
                  icon: Icons.group_add,
                  iconColor: accentColor,
                  title: 'Group Activity',
                  message: 'Clarie Gor joined your "Marathon Crew" group',
                  time: 'Yesterday',
                  isUnread: false,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXiZsPYz0VolLUviyCMilRR3IruUkVfaZlreTtEpBZ72CfL2P78a58RDTPBh5AAWNG1YRLG23VuaGFz0PrXwtr2VPGDwqUqmuu0EcO38jNQCgAMLcSiMTDlBzmcq5e2yD0FiVHoh0S7GCZdfeaYSqxEO9ZS54mioTUtZAXBKNmnVk_bYxWESBfinRaO4c068arwMg7oR6P6GF9llprSidsTNX-9thY-9-y-s9MHIYlE_jWU00vWyqkBa3QgtJG82aL6jat9efs0Ok',
                  onTap: () => context.go('/chat/group-1'),
                ),
                _buildNotificationItem(
                  context,
                  icon: Icons.workspace_premium,
                  iconColor: Colors.amber,
                  title: 'Achievement Unlocked',
                  message: 'You earned the "Early Bird" badge for completing 5 morning goals',
                  time: 'Yesterday',
                  isUnread: false,
                  imageUrl: null,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildDateHeader('This Week'),
                _buildNotificationItem(
                  context,
                  icon: Icons.chat_bubble,
                  iconColor: accentColor,
                  title: 'New Message',
                  message: 'Nicy Awino: "Are we still on for lunch tomorrow?"',
                  time: '2 days ago',
                  isUnread: false,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
                  onTap: () => context.go('/chat'),
                ),
                _buildNotificationItem(
                  context,
                  icon: Icons.photo_library,
                  iconColor: accentColor,
                  title: 'New Memory',
                  message: 'Alvin Amwata shared 5 new photos in "Weekend Trip"',
                  time: '3 days ago',
                  isUnread: false,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBI-EAHM1ea5gJFYdzEHRc10JyVRmp8xNZNtZFXNTrZGEzKawcFEfPNwRMhz5ZeIX4ZRYrW8PHK1BWV-yE0vZJ7TBDqmF73WBpZzUrRNcnOUIZeo6YFZw5BVSuMVVuyIW2UqvilfcIFmj8V0YFoUZADYH_WUTq30oVj0or_PvPAGqUKm6CHBiweKHhKnbQWebJiwovmpSvTBA40if-_kS95NrmoJx1aS6T-0OOSJCDV2NNT-d7RDE6Auwo1n6zQBeVvN0ozhHBtVto',
                  onTap: () => context.go('/memories'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
    String? imageUrl,
    VoidCallback? onTap,
    List<Widget>? actionButtons,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? accentColor.withOpacity(0.05)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isUnread
              ? Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon or Avatar
            if (imageUrl != null)
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(imageUrl),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 15,
                              ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (actionButtons != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: actionButtons,
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

