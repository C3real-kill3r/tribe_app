import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tribe/features/chat/data/datasources/conversation_remote_data_source.dart';
import 'package:tribe/features/chat/presentation/bloc/conversation_event.dart';
import 'package:tribe/features/chat/presentation/bloc/conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRemoteDataSource conversationDataSource;

  ConversationBloc({required this.conversationDataSource})
      : super(ConversationInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<RefreshConversations>(_onRefreshConversations);
    on<MessageReceivedInConversation>(_onMessageReceivedInConversation);
    on<TypingUpdateInConversation>(_onTypingUpdateInConversation);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final response = await conversationDataSource.getConversations(
        page: event.page,
        limit: event.limit,
      );
      emit(ConversationLoaded(
        conversations: response['conversations'] ?? [],
        pagination: response['pagination'],
      ));
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onRefreshConversations(
    RefreshConversations event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final response = await conversationDataSource.getConversations(
        page: 1,
        limit: 20,
      );
      emit(ConversationLoaded(
        conversations: response['conversations'] ?? [],
        pagination: response['pagination'],
      ));
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void _onMessageReceivedInConversation(
    MessageReceivedInConversation event,
    Emitter<ConversationState> emit,
  ) {
    final currentState = state;
    if (currentState is ConversationLoaded) {
      // Find the conversation and update it
      final conversations = List<dynamic>.from(currentState.conversations);
      final conversationIndex = conversations.indexWhere(
        (conv) => conv['id']?.toString() == event.conversationId,
      );

      if (conversationIndex != -1) {
        // Update the conversation with new message
        final updatedConversation = Map<String, dynamic>.from(conversations[conversationIndex]);
        updatedConversation['last_message'] = event.message;
        updatedConversation['last_message_at'] = event.message['created_at'];
        
        // Increment unread count if message is not from current user
        // Note: We'd need current user ID to check this, but for now we'll assume
        // the backend handles unread counts. We can increment if needed.
        
        // Remove from current position and add to top (most recent first)
        conversations.removeAt(conversationIndex);
        conversations.insert(0, updatedConversation);

        emit(ConversationLoaded(
          conversations: conversations,
          pagination: currentState.pagination,
        ));
      } else {
        // Conversation not in list, refresh to get it
        add(RefreshConversations());
      }
    }
  }

  void _onTypingUpdateInConversation(
    TypingUpdateInConversation event,
    Emitter<ConversationState> emit,
  ) {
    final currentState = state;
    if (currentState is ConversationLoaded) {
      // Update typing indicators map
      final typingIndicators = Map<String, Map<String, dynamic>?>.from(
        currentState.typingIndicators ?? {},
      );

      if (event.isTyping) {
        typingIndicators[event.conversationId] = {
          'user_id': event.userId,
          'user_name': event.userName,
          'is_typing': true,
        };
      } else {
        // Remove typing indicator when user stops typing
        typingIndicators.remove(event.conversationId);
      }

      emit(ConversationLoaded(
        conversations: currentState.conversations,
        pagination: currentState.pagination,
        typingIndicators: typingIndicators,
      ));
    }
  }
}

