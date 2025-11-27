import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tribe/features/auth/domain/entities/user.dart';
import 'package:tribe/features/user/domain/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<RefreshUserProfile>(_onRefreshUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await userRepository.getCurrentUserProfile();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      emit(UserUpdating((state as UserLoaded).user));
    }
    try {
      final user = await userRepository.updateUserProfile(
        fullName: event.fullName,
        username: event.username,
        bio: event.bio,
        email: event.email,
      );
      emit(UserLoaded(user));
    } catch (e) {
      if (state is UserUpdating) {
        emit(UserError(e.toString()));
        // Try to reload the previous user data
        add(RefreshUserProfile());
      } else {
        emit(UserError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshUserProfile(
    RefreshUserProfile event,
    Emitter<UserState> emit,
  ) async {
    try {
      final user = await userRepository.getCurrentUserProfile();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

