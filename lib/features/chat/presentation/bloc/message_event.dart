import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

class LoadMessages extends MessageEvent {
  final String conversationId;
  final int page;
  final int limit;

  const LoadMessages({
    required this.conversationId,
    this.page = 1,
    this.limit = 50,
  });

  @override
  List<Object> get props => [conversationId, page, limit];
}

class SendMessage extends MessageEvent {
  final String conversationId;
  final String content;

  const SendMessage({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object> get props => [conversationId, content];
}

class RefreshMessages extends MessageEvent {
  final String conversationId;

  const RefreshMessages({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

class MessageReceived extends MessageEvent {
  final String conversationId;
  final Map<String, dynamic> message;

  const MessageReceived({
    required this.conversationId,
    required this.message,
  });

  @override
  List<Object> get props => [conversationId, message];
}

