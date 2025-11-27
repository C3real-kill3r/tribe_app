import 'package:equatable/equatable.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<dynamic> conversations;
  final Map<String, dynamic>? pagination;
  final Map<String, Map<String, dynamic>?>? typingIndicators;

  const ConversationLoaded({
    required this.conversations,
    this.pagination,
    this.typingIndicators,
  });

  @override
  List<Object> get props => [
        conversations,
        pagination ?? {},
        typingIndicators ?? {},
      ];
}

class ConversationError extends ConversationState {
  final String message;

  const ConversationError(this.message);

  @override
  List<Object> get props => [message];
}

