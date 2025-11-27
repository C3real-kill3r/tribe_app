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
    try {
      final response = await conversationDataSource.sendMessage(
        event.conversationId,
        event.content,
      );
      
      // Reload messages to get the new one
      add(LoadMessages(conversationId: event.conversationId));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<MessageState> emit,
  ) async {
    try {
      final response = await conversationDataSource.getConversationMessages(
        event.conversationId,
        page: 1,
        limit: 50,
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
}

