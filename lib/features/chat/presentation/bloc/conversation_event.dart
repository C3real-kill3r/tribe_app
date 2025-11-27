import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

class LoadConversations extends ConversationEvent {
  final int page;
  final int limit;

  const LoadConversations({this.page = 1, this.limit = 20});

  @override
  List<Object> get props => [page, limit];
}

class RefreshConversations extends ConversationEvent {
  const RefreshConversations();
}

class MessageReceivedInConversation extends ConversationEvent {
  final String conversationId;
  final Map<String, dynamic> message;

  const MessageReceivedInConversation({
    required this.conversationId,
    required this.message,
  });

  @override
  List<Object> get props => [conversationId, message];
}

class TypingUpdateInConversation extends ConversationEvent {
  final String conversationId;
  final String userId;
  final String userName;
  final bool isTyping;

  const TypingUpdateInConversation({
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.isTyping,
  });

  @override
  List<Object> get props => [conversationId, userId, userName, isTyping];
}

