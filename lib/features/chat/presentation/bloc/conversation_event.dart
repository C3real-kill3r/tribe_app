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

