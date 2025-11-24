import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tribe/features/chat/data/datasources/ai_coach_service.dart';

class ConversationScreen extends StatefulWidget {
  final String chatId;

  const ConversationScreen({super.key, required this.chatId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AICoachService _aiCoachService = AICoachService();
  final List<Map<String, dynamic>> _messages = [];

  bool get _isAICoach => widget.chatId == 'ai-coach';

  String _getChatTitle() {
    if (_isAICoach) return 'Tribe Coach';
    switch (widget.chatId) {
      case 'group-1':
        return 'Marathon Crew';
      case 'user-1':
        return 'Derrick Juma';
      case '3':
        return 'Nicy Awino';
      default:
        return 'Chat';
    }
  }

  String _getChatSubtitle() {
    if (_isAICoach) return 'Online';
    switch (widget.chatId) {
      case 'group-1':
        return '6 members';
      case 'user-1':
      case '3':
        return 'Active now';
      default:
        return 'Active';
    }
  }

  String _getChatAvatar() {
    switch (widget.chatId) {
      case 'group-1':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXiZsPYz0VolLUviyCMilRR3IruUkVfaZlreTtEpBZ72CfL2P78a58RDTPBh5AAWNG1YRLG23VuaGFz0PrXwtr2VPGDwqUqmuu0EcO38jNQCgAMLcSiMTDlBzmcq5e2yD0FiVHoh0S7GCZdfeaYSqxEO9ZS54mioTUtZAXBKNmnVk_bYxWESBfinRaO4c068arwMg7oR6P6GF9llprSidsTNX-9thY-9-y-s9MHIYlE_jWU00vWyqkBa3QgtJG82aL6jat9efs0Ok';
      case 'user-1':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs';
      case '3':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs';
      default:
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    if (_isAICoach) {
      _messages.add({
        'text': "Hi! I'm your Tribe Coach. How can I help you today?",
        'isMe': false,
        'time': 'Now',
        'type': 'text',
      });
    } else {
      // Load unique messages based on chatId
      switch (widget.chatId) {
        case 'group-1': // Marathon Crew
          _messages.addAll([
            {
              'text': 'Today',
              'type': 'date',
            },
            {
              'text': 'Hey everyone! Just finished my 5k run for the day. Feeling great!',
              'isMe': false,
              'time': '10:00 AM',
              'user': 'Alvin Amwata',
              'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBI-EAHM1ea5gJFYdzEHRc10JyVRmp8xNZNtZFXNTrZGEzKawcFEfPNwRMhz5ZeIX4ZRYrW8PHK1BWV-yE0vZJ7TBDqmF73WBpZzUrRNcnOUIZeo6YFZw5BVSuMVVuyIW2UqvilfcIFmj8V0YFoUZADYH_WUTq30oVj0or_PvPAGqUKm6CHBiweKHhKnbQWebJiwovmpSvTBA40if-_kS95NrmoJx1aS6T-0OOSJCDV2NNT-d7RDE6Auwo1n6zQBeVvN0ozhHBtVto',
              'type': 'text',
            },
            {
              'text': "Awesome job, Alvin! Killing it. I'm hitting the pavement in an hour.",
              'isMe': true,
              'time': '10:05 AM',
              'type': 'text',
            },
            {
              'text': "Brian Onyango completed the 'Run 10k this week' goal!",
              'type': 'system',
            },
            {
              'text': 'Check out the view from my run this morning! 🏃‍♂️',
              'isMe': false,
              'time': '10:15 AM',
              'user': 'Brian Onyango',
              'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCGqbXriBn-se1qGz9Oh6Bog6YzqldQGT_ZqwMUdYgnMoXxVvAKyUv-UzdjW6ZHzAxCzOwcD1zYuXXIb8KeWZY4reevGU4bAO82yE-5XrKv0BE4csYF03QIGW5vF2HQeo3WFXSgj-1Cdv-U9e6oCuy0TTdCoho6fTjrQDVt60L6ATB67lP3gjYcJIQEKsqPKFerdDnHXp0jOxIpKKmlWosfqRml4P0HkH-Pwepbf-eOOUJQFexO9wH917o6vkH8Rmay2HNV3GmwxFk',
              'type': 'text',
            },
          ]);
          break;
        case 'user-1': // Derrick Juma
          _messages.addAll([
            {
              'text': 'Today',
              'type': 'date',
            },
            {
              'text': 'Hey! How are you doing?',
              'isMe': false,
              'time': '10:30 AM',
              'user': 'Derrick Juma',
              'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
              'type': 'text',
            },
            {
              'text': "I'm doing great! Thanks for asking. How about you?",
              'isMe': true,
              'time': '10:32 AM',
              'type': 'text',
            },
            {
              'text': 'Wow, that looks amazing! We have to plan something together soon.',
              'isMe': false,
              'time': '10:42 AM',
              'user': 'Derrick Juma',
              'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
              'type': 'text',
            },
          ]);
          break;
        case '3': // Nicy Awino
          _messages.addAll([
            {
              'text': 'Yesterday',
              'type': 'date',
            },
            {
              'text': 'Are we still on for lunch tomorrow?',
              'isMe': false,
              'time': '3:45 PM',
              'user': 'Nicy Awino',
              'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
              'type': 'text',
            },
            {
              'text': 'Yes! Looking forward to it. Same place?',
              'isMe': true,
              'time': '3:50 PM',
              'type': 'text',
            },
            {
              'text': 'Perfect! See you there at 1 PM 🍽️',
              'isMe': false,
              'time': '4:00 PM',
              'user': 'Nicy Awino',
              'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
              'type': 'text',
            },
          ]);
          break;
        default:
          _messages.addAll([
            {
              'text': 'Today',
              'type': 'date',
            },
            {
              'text': 'Hey! How can I help you?',
              'isMe': false,
              'time': '10:00 AM',
              'user': 'Friend',
              'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
              'type': 'text',
            },
          ]);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add({
        'text': userMessage,
        'isMe': true,
        'time': 'Now',
        'type': 'text',
      });
      _messageController.clear();
    });
    _scrollToBottom();

    if (_isAICoach) {
      await Future.delayed(const Duration(seconds: 1));
      final aiResponse = await _aiCoachService.getResponse(userMessage);
      if (mounted) {
        setState(() {
          _messages.add({
            'text': aiResponse,
            'isMe': false,
            'time': 'Now',
            'type': 'text',
          });
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                      Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: _isAICoach
                            ? null
                            : NetworkImage(_getChatAvatar()),
                        backgroundColor: _isAICoach
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        child: _isAICoach
                            ? const Icon(Icons.auto_awesome, color: Colors.white)
                            : null,
                      ),
                      if (!_isAICoach && widget.chatId != 'group-1')
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getChatTitle(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          _getChatSubtitle(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Messages Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final type = message['type'] as String;

                  if (type == 'date') {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          message['text'],
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                    );
                  }

                  if (type == 'system') {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium,
                                size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              message['text'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final isMe = message['isMe'] as bool;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment:
                          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) ...[
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: _isAICoach
                                ? null
                                : NetworkImage(message['avatar'] ?? ''),
                            child: _isAICoach
                                ? const Icon(Icons.auto_awesome, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment:
                                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (!isMe && !_isAICoach)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                                  child: Text(
                                    message['user'] ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: isMe
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFFFD2B1),
                                            Color(0xFFFFAA8E)
                                          ], // Light mode gradient
                                        )
                                      : null,
                                  color: isMe
                                      ? null
                                      : Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF332F2C)
                                          : const Color(0xFFF3EAE4),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 20),
                                  ),
                                ),
                                child: Text(
                                  message['text'],
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.black87
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {},
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF332F2C)
                            : const Color(0xFFF3EAE4),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Message your Tribe...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.sentiment_satisfied),
                            onPressed: () {},
                            color: Colors.grey,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
