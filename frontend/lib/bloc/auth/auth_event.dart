part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String name;
  final String password;

  LoginRequested({
    required this.name,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {}