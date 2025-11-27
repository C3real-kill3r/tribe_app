import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tribe/core/di/service_locator.dart' as di;
import 'package:tribe/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tribe/features/chat/data/services/websocket_service.dart';
import 'package:tribe/features/chat/presentation/bloc/conversation_bloc.dart';
import 'package:tribe/features/chat/presentation/bloc/conversation_event.dart';
import 'package:tribe/features/chat/presentation/bloc/conversation_state.dart';
import 'package:tribe/features/chat/presentation/widgets/chat_list_item.dart';

class _ChatSearchDelegate extends SearchDelegate<ChatItem?> {
  final List<ChatItem> _allChats;

  _ChatSearchDelegate(this._allChats);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredChats = query.isEmpty
        ? _allChats
        : _allChats
            .where((chat) =>
                chat.name.toLowerCase().contains(query.toLowerCase()) ||
                chat.message.toLowerCase().contains(query.toLowerCase()))
            .toList();

    if (filteredChats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No chats found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with a different term',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return ChatListItem(
          name: chat.name,
          message: chat.message,
          time: chat.time,
          imageUrl: chat.imageUrl,
          isUnread: chat.isUnread,
          onTap: () {
            close(context, chat);
            chat.onTap();
          },
        );
      },
    );
  }
}

class ChatItem {
  final String name;
  final String message;
  final String time;
  final String imageUrl;
  final bool isUnread;
  final bool isGroup;
  final VoidCallback onTap;
  final String? typingUserName;

  ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.imageUrl,
    required this.isUnread,
    required this.isGroup,
    required this.onTap,
    this.typingUserName,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<WebSocketMessage>? _wsSubscription;
  ConversationBloc? _conversationBloc;
  String? _currentUserId;

  List<ChatItem> _convertConversationsToChatItems(
    List<dynamic> conversations,
    Map<String, Map<String, dynamic>?>? typingIndicators,
  ) {
    return conversations.map((conv) {
      final conversationId = conv['id']?.toString() ?? '';
      final isGroup = conv['is_group'] ?? false;
      
      // For direct messages, find the other participant (not the current user)
      String name;
      String imageUrl;
      
      if (isGroup || (conv['name'] != null && conv['name'].toString().isNotEmpty)) {
        // Group chat or named conversation
        name = conv['name']?.toString() ?? 'Group Chat';
        imageUrl = conv['image_url']?.toString() ?? '';
      } else {
        // Direct message - find the other participant
        final participants = conv['participants'] as List<dynamic>?;
        if (participants != null && participants.isNotEmpty) {
          // Find the participant that is not the current user
          dynamic otherParticipant;
          try {
            otherParticipant = participants.firstWhere(
              (p) {
                final participantUserId = p['user_id']?.toString();
                return participantUserId != null && 
                       participantUserId != _currentUserId;
              },
            );
          } catch (e) {
            // If not found, use the first participant as fallback
            otherParticipant = participants.isNotEmpty ? participants[0] : null;
          }
          
          if (otherParticipant != null) {
            name = otherParticipant['full_name']?.toString() ?? 
                   otherParticipant['username']?.toString() ?? 
                   'Unknown';
            imageUrl = otherParticipant['profile_image_url']?.toString() ?? '';
          } else {
            name = 'Unknown';
            imageUrl = '';
          }
        } else {
          name = 'Unknown';
          imageUrl = '';
        }
      }
      
      // Check if someone is typing
      final typingInfo = typingIndicators?[conversationId];
      final typingUserName = typingInfo?['user_name'] as String?;
      
      final lastMessage = conv['last_message'];
      String message;
      if (typingUserName != null) {
        message = '$typingUserName is typing...';
      } else if (lastMessage != null) {
        message = '${lastMessage['sender']?['full_name'] ?? ''}: ${lastMessage['content'] ?? ''}';
      } else {
        message = 'No messages yet';
      }
      
      final lastMessageAt = lastMessage?['created_at'];
      final time = lastMessageAt != null 
          ? _formatTime(lastMessageAt)
          : '';
      final unreadCount = conv['unread_count'] ?? 0;
      
      return ChatItem(
        name: name,
        message: message,
        time: time,
        imageUrl: imageUrl,
        isUnread: unreadCount > 0,
        isGroup: isGroup,
        typingUserName: typingUserName,
        onTap: () => context.go(
          '/chat/$conversationId',
          extra: {
            'chatName': name,
            'chatImageUrl': imageUrl,
            'isGroup': isGroup,
          },
        ),
      );
    }).toList();
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays == 0) {
        return DateFormat('h:mm a').format(dateTime);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(dateTime);
      } else {
        return DateFormat('MMM d').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupWebSocket(List<dynamic> conversations) async {
    try {
      // Store bloc reference if not already stored
      if (_conversationBloc == null && mounted) {
        _conversationBloc = context.read<ConversationBloc>();
      }

      // Get current user ID if not already stored
      if (_currentUserId == null && mounted) {
        try {
          final authBloc = context.read<AuthBloc>();
          if (authBloc.state is AuthAuthenticated) {
            final authState = authBloc.state as AuthAuthenticated;
            _currentUserId = authState.user.id;
          }
        } catch (e) {
          debugPrint('⚠️ Could not get current user ID: $e');
        }
      }

      // Connect to WebSocket if not already connected
      if (!_webSocketService.isConnected) {
        await _webSocketService.connect();
      }

      // Set up listener if not already set up
      if (_wsSubscription == null) {
        _wsSubscription = _webSocketService.messageStream.listen((wsMessage) {
          if (!mounted || _conversationBloc == null) return;

          // Handle connection events
          if (wsMessage.event == WebSocketEventType.connected) {
            debugPrint('✅ WebSocket: Connection established in ChatScreen');
            // Resubscribe to all conversations when reconnected
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _webSocketService.isConnected) {
                final state = _conversationBloc!.state;
                if (state is ConversationLoaded) {
                  _setupWebSocket(state.conversations);
                }
              }
            });
            return;
          }

          // Handle subscription confirmation
          if (wsMessage.event == WebSocketEventType.subscribed) {
            debugPrint('✅ WebSocket: Subscription confirmed for ${wsMessage.conversationId}');
            return;
          }

          // Handle pong (heartbeat response) - no action needed
          if (wsMessage.event == WebSocketEventType.pong) {
            return;
          }

          if (wsMessage.event == WebSocketEventType.disconnected ||
              wsMessage.event == WebSocketEventType.error) {
            debugPrint('⚠️ WebSocket: ${wsMessage.event} - Connection will be re-established');
            // Don't process messages when disconnected/error
            return;
          }

          final conversationId = wsMessage.conversationId;
          if (conversationId == null) return;

          switch (wsMessage.event) {
            case WebSocketEventType.messageNew:
              // Update conversation with new message
              if (wsMessage.data != null) {
                _conversationBloc!.add(MessageReceivedInConversation(
                  conversationId: conversationId,
                  message: wsMessage.data!,
                ));
              }
              break;

            case WebSocketEventType.typing:
              // Update typing indicator
              if (wsMessage.data != null) {
                final userId = wsMessage.data!['user_id']?.toString();
                final userName = wsMessage.data!['user_name']?.toString() ?? 'Someone';
                final isTyping = wsMessage.data!['is_typing'] as bool? ?? false;

                if (userId != null) {
                  _conversationBloc!.add(TypingUpdateInConversation(
                    conversationId: conversationId,
                    userId: userId,
                    userName: userName,
                    isTyping: isTyping,
                  ));
                }
              }
              break;

            default:
              break;
          }
        });
      }

      // Subscribe to all conversations
      for (final conversation in conversations) {
        final conversationId = conversation['id']?.toString();
        if (conversationId != null) {
          await _webSocketService.subscribeToConversation(conversationId);
        }
      }
    } catch (e) {
      debugPrint('❌ Error setting up WebSocket in ChatScreen: $e');
    }
  }

  List<ChatItem> _getFilteredChats(
    int tabIndex,
    List<dynamic> conversations,
    Map<String, Map<String, dynamic>?>? typingIndicators,
  ) {
    final allChats = _convertConversationsToChatItems(conversations, typingIndicators);
    switch (tabIndex) {
      case 0: // All
        return allChats;
      case 1: // Kin (DMs only)
        return allChats.where((chat) => !chat.isGroup).toList();
      case 2: // Tribes (Groups only)
        return allChats.where((chat) => chat.isGroup).toList();
      default:
        return allChats;
    }
  }

  Widget _buildChatList(int tabIndex, ConversationState state) {
    if (state is ConversationLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is ConversationError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ConversationBloc>().add(LoadConversations());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final conversations = state is ConversationLoaded ? state.conversations : [];
    final typingIndicators = state is ConversationLoaded ? state.typingIndicators : null;
    final filteredChats = _getFilteredChats(tabIndex, conversations, typingIndicators);

    if (filteredChats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tabIndex == 1
                    ? Icons.person_outline
                    : Icons.group_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                tabIndex == 1
                    ? 'No direct messages yet'
                    : 'No group chats yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                tabIndex == 1
                    ? 'Start a conversation with someone'
                    : 'Create or join a tribe to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return ChatListItem(
          name: chat.name,
          message: chat.message,
          time: chat.time,
          imageUrl: chat.imageUrl,
          isUnread: chat.isUnread,
          typingUserName: chat.typingUserName,
          onTap: chat.onTap,
        );
      },
    );
  }

  void _handleSearch(List<dynamic> conversations) {
    final state = context.read<ConversationBloc>().state;
    final typingIndicators = state is ConversationLoaded ? state.typingIndicators : null;
    final chatItems = _convertConversationsToChatItems(conversations, typingIndicators);
    showSearch(
      context: context,
      delegate: _ChatSearchDelegate(chatItems),
    );
  }

  void _handleNewMessage() {
    // Show a bottom sheet or dialog to start a new conversation
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        // Calculate bottom padding: navigation bar height (70) + margins (8 top + 8 bottom = 16) + safe area bottom
        // The navigation bar is 70px high with 8px vertical margins on each side
        const bottomNavBarHeight = 70.0 + 16.0; // Navigation bar height + total vertical margins
        final safeAreaBottom = mediaQuery.padding.bottom;
        final bottomPadding = safeAreaBottom + bottomNavBarHeight;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: mediaQuery.viewInsets.bottom + bottomPadding,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Message',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('New Direct Message'),
                  subtitle: const Text('Start a conversation with a friend'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/chat/select-kin');
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.group_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('New Group Chat'),
                  subtitle: const Text('Select a tribe to chat'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/chat/select-group');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ConversationBloc>()..add(LoadConversations()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Kin'),
              Tab(text: 'Tribes'),
            ],
          ),
          actions: [
            BlocBuilder<ConversationBloc, ConversationState>(
              builder: (context, state) {
                final conversations = state is ConversationLoaded ? state.conversations : [];
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _handleSearch(conversations),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_square),
              onPressed: _handleNewMessage,
            ),
          ],
        ),
        body: BlocConsumer<ConversationBloc, ConversationState>(
          listener: (context, state) {
            // Update bloc reference
            if (_conversationBloc == null && mounted) {
              _conversationBloc = context.read<ConversationBloc>();
            }
            
            // Get current user ID if not already stored
            if (_currentUserId == null && mounted) {
              try {
                final authBloc = context.read<AuthBloc>();
                if (authBloc.state is AuthAuthenticated) {
                  final authState = authBloc.state as AuthAuthenticated;
                  _currentUserId = authState.user.id;
                }
              } catch (e) {
                debugPrint('⚠️ Could not get current user ID: $e');
              }
            }
            
            // Set up WebSocket when conversations are loaded
            if (state is ConversationLoaded) {
              _setupWebSocket(state.conversations);
            }
          },
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              children: [
                // All tab
                Builder(
                  builder: (context) {
                    return Column(
                      children: [
                        // AI Coach Header (only in All tab)
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
                        Expanded(
                          child: _buildChatList(0, state),
                        ),
                      ],
                    );
                  },
                ),
              // Kin tab (DMs only)
              _buildChatList(1, state),
              // Tribes tab (Groups only)
              _buildChatList(2, state),
            ],
          );
          },
        ),
      ),
    );
  }
}
