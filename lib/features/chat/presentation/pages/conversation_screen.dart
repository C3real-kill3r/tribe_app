import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tribe/core/di/service_locator.dart' as di;
import 'package:tribe/core/services/timezone_service.dart';
import 'package:tribe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tribe/features/chat/data/datasources/ai_coach_service.dart';
import 'package:tribe/features/chat/data/datasources/conversation_remote_data_source.dart';
import 'package:tribe/features/chat/data/services/websocket_service.dart';
import 'package:tribe/features/chat/presentation/bloc/message_bloc.dart';
import 'package:tribe/features/chat/presentation/bloc/message_event.dart';
import 'package:tribe/features/chat/presentation/bloc/message_state.dart';

class ConversationScreen extends StatefulWidget {
  final String chatId;
  final String? chatName;
  final String? chatImageUrl;
  final bool? isGroup;

  const ConversationScreen({
    super.key,
    required this.chatId,
    this.chatName,
    this.chatImageUrl,
    this.isGroup,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AICoachService _aiCoachService = AICoachService();
  final List<Map<String, dynamic>> _legacyMessages = [];
  final WebSocketService _webSocketService = WebSocketService();
  final TimezoneService _timezoneService = TimezoneService();
  StreamSubscription<WebSocketMessage>? _wsSubscription;
  Timer? _typingTimer;
  Set<String> _typingUsers = {};
  bool _isUserTyping = false;
  Map<String, bool> _participantOnlineStatus = {}; // Map of user_id -> is_online
  MessageBloc? _messageBloc; // Store reference to MessageBloc for real conversations

  bool get _isAICoach => widget.chatId == 'ai-coach';
  bool get _isGroupChat => widget.isGroup ?? widget.chatId.startsWith('group-');
  // Real conversation if it's a UUID (from backend) and not a legacy chat ID
  bool get _isRealConversation {
    if (_isAICoach) return false;
    // Check if it's a UUID format (8-4-4-4-12 hex characters)
    final uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidPattern.hasMatch(widget.chatId);
  }

  String _getChatTitle() {
    if (_isAICoach) return 'Tribe Coach';
    if (widget.chatName != null) return widget.chatName!;
    // Fallback to hardcoded values for existing chats
    switch (widget.chatId) {
      case 'group-1':
        return 'Marathon Crew';
      case 'user-1':
        return 'Derrick Juma';
      case '3':
        return 'Nicy Awino';
      default:
        // Try to extract name from ID pattern
        if (widget.chatId.startsWith('group-')) {
          return 'Group Chat';
        } else if (widget.chatId.startsWith('user-')) {
          return 'Direct Message';
        }
        return 'Chat';
    }
  }

  String _getChatSubtitle() {
    if (_isAICoach) return 'Online';
    if (_isGroupChat) {
      return 'Group chat';
    }
    
    // Check if any participant is online
    if (_participantOnlineStatus.isNotEmpty) {
      final hasOnlineUser = _participantOnlineStatus.values.any((isOnline) => isOnline);
      if (hasOnlineUser) {
        return 'Online';
      }
    }
    
    return 'Active now';
  }

  String _getChatAvatar() {
    if (widget.chatImageUrl != null && widget.chatImageUrl!.isNotEmpty) {
      return widget.chatImageUrl!;
    }
    // Fallback to hardcoded values for existing chats
    switch (widget.chatId) {
      case 'group-1':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXiZsPYz0VolLUviyCMilRR3IruUkVfaZlreTtEpBZ72CfL2P78a58RDTPBh5AAWNG1YRLG23VuaGFz0PrXwtr2VPGDwqUqmuu0EcO38jNQCgAMLcSiMTDlBzmcq5e2yD0FiVHoh0S7GCZdfeaYSqxEO9ZS54mioTUtZAXBKNmnVk_bYxWESBfinRaO4c068arwMg7oR6P6GF9llprSidsTNX-9thY-9-y-s9MHIYlE_jWU00vWyqkBa3QgtJG82aL6jat9efs0Ok';
      case 'user-1':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs';
      case '3':
        return 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs';
      default:
        return ''; // Return empty string for new chats without image
    }
  }

  List<Map<String, dynamic>> _convertBackendMessages(List<dynamic> backendMessages, String? currentUserId) {
    final converted = <Map<String, dynamic>>[];
    String? lastDate;
    
    for (var msg in backendMessages) {
      final createdAt = msg['created_at'] as String?;
      // Parse UTC string and convert to local time
      final messageDate = createdAt != null 
          ? _timezoneService.parseUtcToLocal(createdAt) 
          : null;
      final dateStr = messageDate != null ? _timezoneService.formatDate(messageDate) : null;
      
      // Add date separator if date changed
      if (dateStr != null && dateStr != lastDate) {
        converted.add({
          'text': dateStr,
          'type': 'date',
        });
        lastDate = dateStr;
      }
      
      final senderId = msg['sender']?['id']?.toString();
      final isMe = senderId == currentUserId || msg['is_optimistic'] == true;
      
      // Skip optimistic messages that have been replaced by real ones
      if (msg['is_optimistic'] == true && msg['id']?.toString().startsWith('temp_') == true) {
        // Check if we have a real message with similar content and recent timestamp
        final hasRealMessage = backendMessages.any((m) => 
          m['id']?.toString().startsWith('temp_') != true &&
          m['content'] == msg['content'] &&
          m['created_at'] != null
        );
        if (hasRealMessage) {
          continue; // Skip optimistic message if real one exists
        }
      }
      
      converted.add({
        'id': msg['id']?.toString(),
        'text': msg['content'] ?? '',
        'isMe': isMe,
        'time': messageDate != null ? _timezoneService.formatTime(messageDate) : 'Now',
        'user': msg['sender']?['full_name'] ?? (isMe ? 'You' : 'Unknown'),
        'avatar': msg['sender']?['profile_image_url'] ?? '',
        'type': msg['message_type'] ?? 'text',
        'created_at': createdAt,
        'is_optimistic': msg['is_optimistic'] ?? false,
      });
    }
    
    return converted;
  }

  void _loadLegacyMessages() {
    if (_isAICoach) {
      _legacyMessages.add({
        'text': "Hi! I'm your Tribe Coach. How can I help you today?",
        'isMe': false,
        'time': 'Now',
        'type': 'text',
      });
    } else {
      // Load unique messages based on chatId for legacy chats
      switch (widget.chatId) {
        case 'group-1': // Marathon Crew
          _legacyMessages.addAll([
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
          _legacyMessages.addAll([
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
          _legacyMessages.addAll([
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
          _legacyMessages.addAll([
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

  void _scrollToBottom({bool smooth = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (smooth) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    if (_isAICoach) {
      // Handle AI Coach messages
      if (mounted) {
        setState(() {
          _legacyMessages.add({
            'text': userMessage,
            'isMe': true,
            'time': 'Now',
            'type': 'text',
          });
        });
        _scrollToBottom();
        await Future.delayed(const Duration(seconds: 1));
        final aiResponse = await _aiCoachService.getResponse(userMessage);
        if (mounted) {
          setState(() {
            _legacyMessages.add({
              'text': aiResponse,
              'isMe': false,
              'time': 'Now',
              'type': 'text',
            });
          });
          _scrollToBottom();
        }
      }
    } else if (_isRealConversation) {
      // Send real message to backend (this persists to DB)
      if (mounted) {
        try {
          // Use stored bloc reference or get from service locator
          final messageBloc = _messageBloc ?? di.sl<MessageBloc>();
          messageBloc.add(SendMessage(
            conversationId: widget.chatId,
            content: userMessage,
          ));
          // Optimistic update will show message immediately
          // WebSocket will confirm and update with server response
          _scrollToBottom();
        } catch (e) {
          debugPrint('Error sending message: $e');
          // Show error to user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send message: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } else {
      // Legacy hardcoded chat handling
      if (mounted) {
        setState(() {
          _legacyMessages.add({
            'text': userMessage,
            'isMe': true,
            'time': 'Now',
            'type': 'text',
          });
        });
        _scrollToBottom();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (!_isRealConversation) {
      _loadLegacyMessages();
    } else {
      _setupWebSocket();
      _messageController.addListener(_onTextChanged);
      _loadConversationDetails();
    }
  }

  Future<void> _loadConversationDetails() async {
    try {
      final dataSource = di.sl<ConversationRemoteDataSource>();
      final details = await dataSource.getConversationDetails(widget.chatId);
      
      if (mounted && details['participants'] != null) {
        setState(() {
          final participants = details['participants'] as List<dynamic>;
          for (var participant in participants) {
            final userId = participant['user_id']?.toString();
            final isOnline = participant['is_online'] as bool?;
            if (userId != null && isOnline != null) {
              _participantOnlineStatus[userId] = isOnline;
            }
          }
        });
      }
    } catch (e) {
      // Silently fail - online status is not critical
      debugPrint('Failed to load conversation details: $e');
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _typingTimer?.cancel();
    _messageController.removeListener(_onTextChanged);
    if (_isRealConversation) {
      _webSocketService.unsubscribeFromConversation(widget.chatId);
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _setupWebSocket() async {
    debugPrint('🔌 Setting up WebSocket for conversation ${widget.chatId}');
    
    // Connect to WebSocket and wait for connection
    try {
      await _webSocketService.connect();
      debugPrint('✅ WebSocket connected');
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
      return;
    }
    
    // Subscribe to conversation (will wait for connection if needed)
    await _webSocketService.subscribeToConversation(widget.chatId);
    debugPrint('📡 Subscribed to conversation ${widget.chatId}');
    
    // Send presence update
    _webSocketService.sendPresence('online');
    
    // Listen to WebSocket messages
    _wsSubscription = _webSocketService.messageStream.listen((wsMessage) {
      if (!mounted) return;
      
      debugPrint('📨 Received WebSocket event: ${wsMessage.event} for conversation ${wsMessage.conversationId}');
      
      // Handle connection events
      if (wsMessage.event == WebSocketEventType.connected) {
        debugPrint('✅ WebSocket connection confirmed');
        // Send presence update on successful connection
        _webSocketService.sendPresence('online');
        // Resubscribe after connection
        _webSocketService.subscribeToConversation(widget.chatId);
        return;
      }
      
      if (wsMessage.conversationId != widget.chatId && 
          wsMessage.event != WebSocketEventType.presence) {
        debugPrint('⏭️ Skipping message for different conversation');
        return;
      }
      
      switch (wsMessage.event) {
        case WebSocketEventType.messageNew:
          debugPrint('💬 New message received via WebSocket');
          _handleNewMessage(wsMessage.data);
          break;
        case WebSocketEventType.typing:
          _handleTypingIndicator(wsMessage.data);
          break;
        case WebSocketEventType.presence:
          _handlePresenceUpdate(wsMessage.data);
          break;
        default:
          break;
      }
    });
  }

  void _handlePresenceUpdate(Map<String, dynamic>? data) {
    // Handle presence updates for online status
    if (data != null) {
      final userId = data['user_id']?.toString();
      final isOnline = data['is_online'] as bool?;
      if (userId != null && isOnline != null) {
        setState(() {
          _participantOnlineStatus[userId] = isOnline;
        });
      }
    }
  }

  void _handleNewMessage(Map<String, dynamic>? data) {
    if (data == null) return;
    
    // Add message directly to bloc for real-time updates
    if (mounted) {
      try {
        // Use stored bloc reference or get from service locator
        final messageBloc = _messageBloc ?? di.sl<MessageBloc>();
        // Use MessageReceived event to add message directly to state
        messageBloc.add(MessageReceived(
          conversationId: widget.chatId,
          message: data,
        ));
        
        // Scroll to bottom after a short delay to allow UI to update
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _scrollToBottom();
          }
        });
      } catch (e) {
        debugPrint('Error handling new message: $e');
        // Fallback to refresh if direct add fails
        try {
          final messageBloc = _messageBloc ?? di.sl<MessageBloc>();
          messageBloc.add(RefreshMessages(conversationId: widget.chatId));
        } catch (refreshError) {
          debugPrint('Error refreshing messages: $refreshError');
        }
      }
    }
  }

  void _handleTypingIndicator(Map<String, dynamic>? data) {
    if (data == null) return;
    
    setState(() {
      final userId = data['user_id'] as String?;
      final isTyping = data['is_typing'] as bool? ?? false;
      final userName = data['user_name'] as String?;
      
      if (isTyping && userId != null) {
        _typingUsers.add(userName ?? userId);
      } else if (userId != null) {
        _typingUsers.removeWhere((name) => name == userName || name == userId);
      }
    });
  }

  void _onTextChanged() {
    if (!_isRealConversation) return;
    
    final hasText = _messageController.text.isNotEmpty;
    
    if (hasText && !_isUserTyping) {
      _isUserTyping = true;
      _webSocketService.sendTypingIndicator(widget.chatId, true);
      
      // Stop typing indicator after 3 seconds of no typing
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (_isUserTyping) {
          _isUserTyping = false;
          _webSocketService.sendTypingIndicator(widget.chatId, false);
        }
      });
    } else if (!hasText && _isUserTyping) {
      _isUserTyping = false;
      _typingTimer?.cancel();
      _webSocketService.sendTypingIndicator(widget.chatId, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // For real conversations, use MessageBloc; otherwise use legacy hardcoded messages
    if (_isRealConversation) {
      return BlocProvider(
        create: (context) {
          // Store bloc reference for use in callbacks
          final bloc = di.sl<MessageBloc>()..add(LoadMessages(conversationId: widget.chatId));
          _messageBloc = bloc;
          return bloc;
        },
        child: Builder(
          builder: (context) => _buildConversationUI(context),
        ),
      );
    } else {
      // Legacy hardcoded messages for AI coach and old chat IDs
      return _buildLegacyConversationUI(context);
    }
  }

  Widget _buildConversationUI(BuildContext context) {
    return BlocListener<MessageBloc, MessageState>(
      listener: (context, state) {
        if (state is MessageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is MessageLoaded) {
          // Scroll to bottom when messages are loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollToBottom(smooth: false);
            }
          });
        }
      },
      child: Scaffold(
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
                            : (_getChatAvatar().isNotEmpty
                                ? NetworkImage(_getChatAvatar())
                                : null),
                        backgroundColor: _isAICoach
                            ? Theme.of(context).colorScheme.primary
                            : (_getChatAvatar().isEmpty
                                ? Theme.of(context).colorScheme.primary
                                : null),
                        child: _isAICoach
                            ? const Icon(Icons.auto_awesome, color: Colors.white)
                            : (_getChatAvatar().isEmpty
                                ? Text(
                                    _getChatTitle()[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null),
                      ),
                      if (!_isAICoach && !_isGroupChat)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getChatSubtitle() == 'Online' 
                                  ? Colors.green 
                                  : Colors.grey,
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
                          _typingUsers.isNotEmpty
                              ? (_typingUsers.length == 1
                                  ? '${_typingUsers.first} is typing...'
                                  : '${_typingUsers.length} people are typing...')
                              : _getChatSubtitle(),
                          style: TextStyle(
                            color: _typingUsers.isNotEmpty
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[600],
                            fontSize: 12,
                            fontStyle: _typingUsers.isNotEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
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
              child: BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  if (state is MessageLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is MessageError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              try {
                                final messageBloc = _messageBloc ?? di.sl<MessageBloc>();
                                messageBloc.add(LoadMessages(conversationId: widget.chatId));
                              } catch (e) {
                                debugPrint('Error retrying load messages: $e');
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Get current user ID from AuthBloc
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      String? currentUserId;
                      if (authState is AuthAuthenticated) {
                        currentUserId = authState.user.id.toString();
                      }
                      
                      final messages = state is MessageLoaded 
                          ? _convertBackendMessages(state.messages, currentUserId)
                          : <Map<String, dynamic>>[];
                      
                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            'No messages yet. Start the conversation!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }
                      
                      // Auto-scroll to bottom when messages first load
                      if (state is MessageLoaded && messages.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollToBottom(smooth: false);
                          }
                        });
                      }
                      
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return _buildMessageWidget(context, message);
                              },
                            ),
                          ),
                          // Typing indicator
                          if (_typingUsers.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey[600]!,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _typingUsers.length == 1
                                        ? '${_typingUsers.first} is typing...'
                                        : '${_typingUsers.length} people are typing...',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
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
                              decoration: InputDecoration(
                                hintText: _isGroupChat
                                    ? 'Message your Tribe...'
                                    : 'Message your Kin...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  Widget _buildLegacyConversationUI(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header (same as above)
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
                            : (_getChatAvatar().isNotEmpty
                                ? NetworkImage(_getChatAvatar())
                                : null),
                        backgroundColor: _isAICoach
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        child: _isAICoach
                            ? const Icon(Icons.auto_awesome, color: Colors.white)
                            : (_getChatAvatar().isEmpty
                                ? Text(
                                    _getChatTitle()[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null),
                      ),
                      if (!_isAICoach && !_isGroupChat)
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
                itemCount: _legacyMessages.length,
                itemBuilder: (context, index) {
                  final message = _legacyMessages[index];
                  return _buildMessageWidget(context, message);
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
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
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

  Widget _buildMessageWidget(BuildContext context, Map<String, dynamic> message) {
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
                  : (message['avatar'] != null && message['avatar'].toString().isNotEmpty
                      ? NetworkImage(message['avatar'] ?? '')
                      : null),
              child: _isAICoach
                  ? const Icon(Icons.auto_awesome, size: 16)
                  : (message['avatar'] == null || message['avatar'].toString().isEmpty
                      ? Text(
                          (message['user'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        )
                      : null),
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
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      message['user'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFFD2B1),
                              Color(0xFFFFAA8E)
                            ],
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
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    message['time'] ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
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
