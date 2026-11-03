part of 'user_bloc.dart';


@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UsersLoadingState extends UserState {}

class UsersLoadedState extends UserState {
  final List<User> users;

  UsersLoadedState({required this.users});
}

class RequestSuccessfullyState extends UserState {
  final String message;

  RequestSuccessfullyState({required this.message});
}

class RequestFailureState extends UserState {
  final String message;

  RequestFailureState({required this.message});
}