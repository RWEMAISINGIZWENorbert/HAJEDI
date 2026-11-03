part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {
  final String message;

  AuthInitial({this.message = ''});
}

class LoginLoading extends AuthState {}

class LoginSuccessfully extends AuthState {
  final String message;

  LoginSuccessfully({required this.message});
}

class LoginFailure extends AuthState {
  final String message;

  LoginFailure({required this.message});
}

class LogoutSuccessfully extends AuthState {
  final String message;

  LogoutSuccessfully({required this.message});
}

class LogoutFailure extends AuthState {
  final String message;

  LogoutFailure({required this.message});
}