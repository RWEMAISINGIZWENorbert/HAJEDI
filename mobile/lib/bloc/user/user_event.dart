part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class AddUserLocal extends UserEvent {
  final User user;

  AddUserLocal({required this.user});
}

class UpdateUserLocal extends UserEvent {
  final String clientId;
  final User user;

  UpdateUserLocal({
    required this.clientId,
    required this.user,
  });
}

class DeleteUserLocal extends UserEvent {
  final String clientId;

  DeleteUserLocal({required this.clientId});
}

class SyncUsers extends UserEvent {}