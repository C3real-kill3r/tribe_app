import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tribe/features/chat/presentation/widgets/chat_list_item.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // AI Coach Header
          InkWell(
            onTap: () => context.go('/chat/ai-coach'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tribe Coach',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ask me anything about your goals!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Chat List
          ChatListItem(
            name: 'Marathon Crew',
            message: 'Brian Onyango: Check out the view from my run...',
            time: '10:45 AM',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXiZsPYz0VolLUviyCMilRR3IruUkVfaZlreTtEpBZ72CfL2P78a58RDTPBh5AAWNG1YRLG23VuaGFz0PrXwtr2VPGDwqUqmuu0EcO38jNQCgAMLcSiMTDlBzmcq5e2yD0FiVHoh0S7GCZdfeaYSqxEO9ZS54mioTUtZAXBKNmnVk_bYxWESBfinRaO4c068arwMg7oR6P6GF9llprSidsTNX-9thY-9-y-s9MHIYlE_jWU00vWyqkBa3QgtJG82aL6jat9efs0Ok',
            isUnread: true,
            onTap: () => context.go('/chat/group-1'),
          ),
          ChatListItem(
            name: 'Derrick Juma',
            message: 'Wow, that looks amazing! We have...',
            time: '10:42 AM',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
            isUnread: false,
            onTap: () => context.go('/chat/user-1'),
          ),
          ChatListItem(
            name: 'Nicy Awino',
            message: 'Are we still on for lunch?',
            time: 'Yesterday',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
            isUnread: false,
            onTap: () => context.push('/chat/3'),
          ),
        ],
      ),
    );
  }
}
