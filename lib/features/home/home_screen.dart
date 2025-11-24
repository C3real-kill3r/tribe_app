import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildWelcomeCard(context),
              const SizedBox(height: 24),
              _buildFriendsOnline(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentActivity(context),
              const SizedBox(height: 80), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCGqbXriBn-se1qGz9Oh6Bog6YzqldQGT_ZqwMUdYgnMoXxVvAKyUv-UzdjW6ZHzAxCzOwcD1zYuXXIb8KeWZY4reevGU4bAO82yE-5XrKv0BE4csYF03QIGW5vF2HQeo3WFXSgj-1Cdv-U9e6oCuy0TTdCoho6fTjrQDVt60L6ATB67lP3gjYcJIQEKsqPKFerdDnHXp0jOxIpKKmlWosfqRml4P0HkH-Pwepbf-eOOUJQFexO9wH917o6vkH8Rmay2HNV3GmwxFk'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Dashboard',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hello, Brian Okuku!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to achieve your goals and make memories with friends today?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsOnline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Friends Online',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 64,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAddFriendButton(context),
              const SizedBox(width: 16),
              _buildFriendAvatar(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBmG7Gts6NR0Q8tTzQDO_XbyU1RM4flr_eFLDD1nXcjGuRxW7JQoQRB1zFu7QatEkEZCxcz1g3UqjqwMgmUCo8xRD8mT9RhaCqZj3iBBcA2CpoVwfD4ruW5FPEk7Sw-linED8Nwj9Wc51xdYselyKDCwDl6DzpbSv_cmerTlfXM1G1loxuEwhrl4ijXzQKdlseK6gnLUV4DFMEw-XmoKXwR9Hg2dTBgw86aEzzuIO3uRJAvIcIHRab4qheZNqwf2BzIX1vSESNjQaE',
                  true),
              const SizedBox(width: 16),
              _buildFriendAvatar(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC39F4tS_dqisNJlaarQawMlFa-ewfuIv3jQVffH4AkgdBvutMVHXxA-sxRcTue5pk8qDXlpOSYocMp4b7n3wu7pgIA5ivyFlcfNOTMUe66eu3xV3EWLRG3CHMDEoymWWvJil7PSI41yIv2XEQLoLBmhGrIDO6np6iNTNzaoQTiWyC6T5IxDxD8s65sIKJNOF5gRX4D4UnHx951_3PjBR6slm2CSxkFv4DrXbBS5QKjYJegoeQ2fX7ltN5U39Fm0zSw2NiAJ-nRbDY',
                  true),
              const SizedBox(width: 16),
              _buildFriendAvatar(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC7fuf9um-U6HXmiAVa5cs83de_n7OJGkC6mwdicwjs3CzSbLwqf8CU0VyxNmCuSVyU3PRDdKX75MO_rbbxBncMYJtNMw0MouAh62kQn3JroOHiR1S987UwaOXGkbgQNVc-43pGQGZC0KqN3QkNqbADaWK6tAB6kdQM3aUtjAv8Mpojq3NjpO6nn4ivL--sjMV41Hy4knen56_9r6BnunGw5ou8aHOENNzJeUGXuGRO7uL_Mg-eZqruSAodFqRC3B1ah2lPYK4qqXA',
                  false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddFriendButton(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 24, color: Theme.of(context).iconTheme.color),
          Text(
            'Add',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendAvatar(String imageUrl, bool isOnline) {
    return Stack(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _buildActionCard(
              context,
              'Group Goals',
              Icons.flag_outlined,
              () => context.go('/goals'),
            ),
            _buildActionCard(
              context,
              'Share Photos',
              Icons.camera_alt_outlined,
              () => context.go('/memories'),
            ),
            _buildActionCard(
              context,
              'Start Chat',
              Icons.chat_bubble_outline,
              () => context.go('/chat'),
            ),
            _buildActionCard(
              context,
              'Accountability',
              Icons.check_circle_outline,
              () => context.go('/goals'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          context,
          'Cedric Ochola',
          'added a new photo.',
          '2 hours ago',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBmG7Gts6NR0Q8tTzQDO_XbyU1RM4flr_eFLDD1nXcjGuRxW7JQoQRB1zFu7QatEkEZCxcz1g3UqjqwMgmUCo8xRD8mT9RhaCqZj3iBBcA2CpoVwfD4ruW5FPEk7Sw-linED8Nwj9Wc51xdYselyKDCwDl6DzpbSv_cmerTlfXM1G1loxuEwhrl4ijXzQKdlseK6gnLUV4DFMEw-XmoKXwR9Hg2dTBgw86aEzzuIO3uRJAvIcIHRab4qheZNqwf2BzIX1vSESNjQaE',
          thumbnail:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuADAScOO6UKN6fOrHGazmASmfbh1PB2u6d_ED3SzeFRL091VWd7RZ2dz_dKVutuwlT1PJGVUJVjfj_0swaXg8uz9zmjtMmIGrO5SwXAhwhVXmjT-1FoejxDNdtDJ3ipZVxiFBBxaRCtrsP9D9ueNR8qU8lXXo_oNDS7PRo46dw5ahGDXNb78fF15aK9xQkUG4ZG-zzTLOPAaMPm0QUIYc40PZot0euPpoBKVYNfI1kfVp6Y-Fqy6dHg5Lhh_grM_R_GWZqnNSty2p4',
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          context,
          'Robert Angira',
          'completed a milestone.',
          'Yesterday',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC39F4tS_dqisNJlaarQawMlFa-ewfuIv3jQVffH4AkgdBvutMVHXxA-sxRcTue5pk8qDXlpOSYocMp4b7n3wu7pgIA5ivyFlcfNOTMUe66eu3xV3EWLRG3CHMDEoymWWvJil7PSI41yIv2XEQLoLBmhGrIDO6np6iNTNzaoQTiWyC6T5IxDxD8s65sIKJNOF5gRX4D4UnHx951_3PjBR6slm2CSxkFv4DrXbBS5QKjYJegoeQ2fX7ltN5U39Fm0zSw2NiAJ-nRbDY',
          icon: Icons.music_note,
          iconColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          context,
          'Tabitha Ombura',
          'commented on a goal.',
          '3 days ago',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC7fuf9um-U6HXmiAVa5cs83de_n7OJGkC6mwdicwjs3CzSbLwqf8CU0VyxNmCuSVyU3PRDdKX75MO_rbbxBncMYJtNMw0MouAh62kQn3JroOHiR1S987UwaOXGkbgQNVc-43pGQGZC0KqN3QkNqbADaWK6tAB6kdQM3aUtjAv8Mpojq3NjpO6nn4ivL--sjMV41Hy4knen56_9r6BnunGw5ou8aHOENNzJeUGXuGRO7uL_Mg-eZqruSAodFqRC3B1ah2lPYK4qqXA',
          icon: Icons.comment,
          iconColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String name,
    String action,
    String timeAgo,
    String avatarUrl, {
    String? thumbnail,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' $action'),
                    ],
                  ),
                ),
                Text(
                  timeAgo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          if (thumbnail != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(thumbnail),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (icon != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
        ],
      ),
    );
  }
}
