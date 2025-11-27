part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthSignupRequested extends AuthEvent {
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;

  const AuthSignupRequested(
    this.fullName,
    this.username,
    this.email,
    this.password,
    this.confirmPassword,
  );

  @override
  List<Object> get props => [fullName, username, email, password, confirmPassword];
}

class AuthLogoutRequested extends AuthEvent {}
