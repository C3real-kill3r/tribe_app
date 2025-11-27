part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends UserEvent {}

class RefreshUserProfile extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final String? fullName;
  final String? username;
  final String? bio;
  final String? email;

  const UpdateUserProfile({
    this.fullName,
    this.username,
    this.bio,
    this.email,
  });

  @override
  List<Object> get props => [
        fullName ?? '',
        username ?? '',
        bio ?? '',
        email ?? '',
      ];
}

