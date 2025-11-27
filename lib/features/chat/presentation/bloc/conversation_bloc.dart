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
}

