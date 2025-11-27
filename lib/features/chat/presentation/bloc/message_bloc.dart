import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tribe/features/chat/data/datasources/conversation_remote_data_source.dart';
import 'package:tribe/features/chat/presentation/bloc/message_event.dart';
import 'package:tribe/features/chat/presentation/bloc/message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final ConversationRemoteDataSource conversationDataSource;

  MessageBloc({required this.conversationDataSource})
      : super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<RefreshMessages>(_onRefreshMessages);
    on<MessageReceived>(_onMessageReceived);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageLoading());
    try {
      final response = await conversationDataSource.getConversationMessages(
        event.conversationId,
        page: event.page,
        limit: event.limit,
      );
      emit(MessageLoaded(
        messages: response['messages'] ?? [],
        pagination: response['pagination'],
        conversationId: event.conversationId,
      ));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<MessageState> emit,
  ) async {
    final currentState = state;
    
    // Optimistically add the message to the current state if it's loaded
    if (currentState is MessageLoaded && currentState.conversationId == event.conversationId) {
      // Get current user info for optimistic message
      final optimisticMessage = {
        'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
        'content': event.content,
        'message_type': 'text',
        'sender': {
          'id': null, // Will be filled from backend
          'full_name': 'You',
          'username': '',
          'profile_image_url': null,
        },
        'created_at': DateTime.now().toIso8601String(),
        'is_optimistic': true,
      };
      
      // Add optimistic message to the end (newest messages are at the end)
      final updatedMessages = List<dynamic>.from(currentState.messages)..add(optimisticMessage);
      emit(currentState.copyWith(messages: updatedMessages));
    }
    
    try {
      // Send message to backend
      final response = await conversationDataSource.sendMessage(
        event.conversationId,
        event.content,
      );
      
      // Debug: Print response to see what we're getting
      print('Message sent successfully. Response: $response');
      
      // Always refresh messages after sending to get the latest from server
      // This ensures we have the complete message with all fields and proper ordering
      add(RefreshMessages(conversationId: event.conversationId));
    } catch (e) {
      // Debug: Print error to see what's failing
      print('Error sending message: $e');
      
      // On error, remove optimistic message and show error
      if (currentState is MessageLoaded && currentState.conversationId == event.conversationId) {
        final cleanMessages = currentState.messages.where((msg) {
          return msg['is_optimistic'] != true;
        }).toList();
        emit(currentState.copyWith(messages: cleanMessages));
      }
      emit(MessageError('Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<MessageState> emit,
  ) async {
    try {
      // Don't emit loading state for refresh to avoid flickering
      final response = await conversationDataSource.getConversationMessages(
        event.conversationId,
        page: 1,
        limit: 50,
      );
      
      final messages = response['messages'] ?? [];
      print('Refreshed messages. Count: ${messages.length}');
      
      emit(MessageLoaded(
        messages: messages,
        pagination: response['pagination'],
        conversationId: event.conversationId,
      ));
    } catch (e) {
      print('Error refreshing messages: $e');
      emit(MessageError('Failed to refresh messages: ${e.toString()}'));
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<MessageState> emit,
  ) {
    final currentState = state;
    
    // Only add message if we're in the correct conversation and have loaded messages
    if (currentState is MessageLoaded && 
        currentState.conversationId == event.conversationId) {
      // Check if message already exists (avoid duplicates)
      final messageId = event.message['id']?.toString();
      final existingMessageIndex = currentState.messages.indexWhere(
        (msg) => msg['id']?.toString() == messageId,
      );
      
      if (existingMessageIndex == -1) {
        // Message doesn't exist, add it in chronological order
        final updatedMessages = List<dynamic>.from(currentState.messages);
        
        // Parse the new message's timestamp
        final newMessageTime = event.message['created_at'] != null
            ? DateTime.tryParse(event.message['created_at'].toString())
            : null;
        
        if (newMessageTime != null) {
          // Find the correct position to insert based on timestamp
          int insertIndex = updatedMessages.length;
          for (int i = 0; i < updatedMessages.length; i++) {
            final msgTime = updatedMessages[i]['created_at'] != null
                ? DateTime.tryParse(updatedMessages[i]['created_at'].toString())
                : null;
            if (msgTime != null && newMessageTime.isBefore(msgTime)) {
              insertIndex = i;
              break;
            }
          }
          updatedMessages.insert(insertIndex, event.message);
        } else {
          // If no timestamp, append to end
          updatedMessages.add(event.message);
        }
        
        emit(currentState.copyWith(messages: updatedMessages));
      } else {
        // Message exists, update it (in case it was an optimistic message)
        final updatedMessages = List<dynamic>.from(currentState.messages);
        updatedMessages[existingMessageIndex] = event.message;
        emit(currentState.copyWith(messages: updatedMessages));
      }
    } else if (currentState is MessageInitial || currentState is MessageLoading) {
      // If we haven't loaded messages yet, trigger a load
      add(LoadMessages(conversationId: event.conversationId));
    }
  }
}

