import 'package:equatable/equatable.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<dynamic> messages;
  final Map<String, dynamic>? pagination;
  final String conversationId;

  const MessageLoaded({
    required this.messages,
    this.pagination,
    required this.conversationId,
  });

  @override
  List<Object> get props => [messages, pagination ?? {}, conversationId];
}

class MessageError extends MessageState {
  final String message;

  const MessageError(this.message);

  @override
  List<Object> get props => [message];
}

