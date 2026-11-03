import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/core/helpers/sync_queue.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/data/user.dart';
import 'package:hive/hive.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final Box<User> _userBox;
  final SyncManager _syncManager;

  StreamSubscription<BoxEvent>? _userBoxSubscription;

  UserBloc(this._userBox, this._syncManager) : super(UserInitial()) {
    on<LoadUsers>(_loadUsers);
    on<AddUserLocal>(_addUserLocal);
    on<UpdateUserLocal>(_updateUserLocal);
    on<DeleteUserLocal>(_deleteUserLocal);
    on<SyncUsers>(_syncUsers);

    _userBoxSubscription = _userBox.watch().listen((event) {
      add(LoadUsers());
    });
  }

  @override
  Future<void> close() async {
    await _userBoxSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadUsers(
    LoadUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoadingState());

    try {
      final users = _userBox.values.toList();
      emit(UsersLoadedState(users: users));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _addUserLocal(
    AddUserLocal event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoadingState());

    try {
      final user = event.user.copyWith(
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      final exists = _userBox.values.any(
        (storedUser) =>
            storedUser.id == user.id ||
            storedUser.name.trim().toLowerCase() ==
                user.name.trim().toLowerCase(),
      );

      if (!exists) {
        await _userBox.put(user.clientId, user);

        await SyncQueue.enqueue(
          entityType: 'user',
          operationType: 'create',
          payload: user.toJson(),
        );
      }
      await _syncManager.syncIfConnected();
      emit(UsersLoadedState(users: _userBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _updateUserLocal(
    UpdateUserLocal event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoadingState());

    try {
      final existing = _userBox.get(event.clientId);

      if (existing == null) {
        throw Exception('User not found locally');
      }

      final updated = event.user.copyWith(
        id: event.clientId,
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      await _userBox.put(event.clientId, updated);

      await SyncQueue.enqueue(
        entityType: 'user',
        operationType: 'update',
        payload: updated.toJson(),
      );

      await _syncManager.syncIfConnected();
      emit(UsersLoadedState(users: _userBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _deleteUserLocal(
    DeleteUserLocal event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoadingState());

    try {
      final user = _userBox.get(event.clientId);

      if (user != null) {
        await _userBox.delete(event.clientId);

        await SyncQueue.enqueue(
          entityType: 'user',
          operationType: 'delete',
          payload: {'id': event.clientId, 'clientId': event.clientId},
        );
      }
      await _syncManager.syncIfConnected();
      emit(UsersLoadedState(users: _userBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }

  Future<void> _syncUsers(
    SyncUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoadingState());

    try {
      final pendingUsers = _userBox.values.where((user) => !user.isSynced).toList();

      for (final user in pendingUsers) {
        final updated = user.copyWith(isSynced: true, updatedAt: DateTime.now());
        await _userBox.put(user.clientId, updated);
      }

      emit(UsersLoadedState(users: _userBox.values.toList()));
    } catch (e) {
      emit(RequestFailureState(message: e.toString()));
    }
  }
}