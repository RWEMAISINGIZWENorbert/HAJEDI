import 'dart:convert';

import 'package:hajedi/core/network/sync_handler.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/core/network/sync_metadata.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/repository/user_repository.dart';
import 'package:hive/hive.dart';
import 'package:hajedi/utils/auth_utils.dart';

class UserSyncHandler implements SyncHandler {
  final Box<User> userBox;
  final UserRepository userRepository;
  SyncManager? syncManager;

  UserSyncHandler({
    required this.userBox,
    required this.userRepository,
    this.syncManager,
  });

  void setSyncManager(SyncManager manager) {
    syncManager = manager;
  }

  @override
  String get entityType => 'user';

  @override
  Future<bool> sendToServer(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operationType) {
      case 'create':
        return _createUser(payload);

      case 'update':
        return _updateUser(payload);

      case 'delete':
        return _deleteUser(payload);

      default:
        return false;
    }
  }

  Future<bool> _createUser(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    final user = User(
      id: payload['id']?.toString() ?? '',
      clientId: clientId,
      name: payload['name']?.toString() ?? '',
      role: payload['role']?.toString() ?? 'employee',
      password: payload['password']?.toString() ?? '',
    );

    final serverUser = await userRepository.registerUser(user);
    final storedUser = userBox.get(clientId);

    if (storedUser != null) {
      await userBox.put(
        clientId,
        storedUser.copyWith(
          id: serverUser.id,
          clientId: serverUser.clientId,
          isSynced: true,
          updatedAt: DateTime.now(),
        ),
      );
    }

    return true;
  }

  Future<bool> _updateUser(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    await userRepository.updateUser(
      clientId,
      name: payload['name']?.toString(),
      role: payload['role']?.toString(),
      password: payload['password']?.toString(),
    );

    await _markLocalUserAsSynced(clientId);
    return true;
  }

  Future<bool> _deleteUser(
    Map<String, dynamic> payload,
  ) async {
    final clientId = _readClientId(payload);

    if (clientId == null) {
      return false;
    }

    await userRepository.removeUser(clientId);
    return true;
  }

  @override
  Future<void> pullRemoteChanges() async {
    final cursor = await SyncMetadata.getUsersCursor();
    print("User: pull Remote Changes");

    final response = await userRepository.getUserChanges(
      since: cursor,
    );

    final data = response['data'] as Map<String, dynamic>;

    final created = data['created'] as List<dynamic>? ?? [];
    final updated = data['updated'] as List<dynamic>? ?? [];
    final deleted = data['deleted'] as List<dynamic>? ?? [];

    for (final item in created) {
      await _saveRemoteUser(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in updated) {
      await _saveRemoteUser(
        Map<String, dynamic>.from(item as Map),
      );
    }

    for (final item in deleted) {
      final deletedData = Map<String, dynamic>.from(item as Map);
      print("The DeletedData $deletedData");
      final clientId = deletedData['clientId']?.toString();
      print("Te Deleted ClientId: $clientId");
      final user = userBox.get(clientId);
      print("The Deleted User: $user");
      final deletedUserName = user?.name;
      print("The Deleted User Name: $deletedUserName");

      if (clientId != null && clientId.isNotEmpty) {
         await userBox.delete(clientId);
      }
        
      // Check if deleted user is the currently authenticated user
      await _logoutIfCurrentUserDeleted(deletedUserName);
    }

    final nextCursor = response['nextCursor']?.toString();

    if (nextCursor != null && nextCursor.isNotEmpty) {
      await SyncMetadata.saveUsersCursor(nextCursor);
    }
  }

  Future<void> _saveRemoteUser(
    Map<String, dynamic> data,
  ) async {
    final clientId = data['clientId']?.toString();

    if (clientId == null || clientId.isEmpty) {
      return;
    }

    final existingUser = userBox.get(clientId);
    final remoteUser = User.fromJson(data);

    await userBox.put(
      clientId,
      remoteUser.copyWith(
        password: existingUser?.password ?? '',
        isSynced: true,
      ),
    );
  }

  Future<void> _markLocalUserAsSynced(
    String clientId,
  ) async {
    final user = userBox.get(clientId);

    if (user == null) {
      return;
    }

    await userBox.put(
      clientId,
      user.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  String? _readClientId(
    Map<String, dynamic> payload,
  ) {
    final value = payload['clientId'] ?? payload['id'];
    final clientId = value?.toString();

    if (clientId == null || clientId.isEmpty) {
      return null;
    }

    return clientId;
  }

  Future<void> _logoutIfCurrentUserDeleted(String? deletedUserName) async {
    print("=== _logoutIfCurrentUserDeleted called with: $deletedUserName ===");
  if (deletedUserName == null || deletedUserName.isEmpty) {
    return;
  }

  // Get current authenticated user
  final currentUser = await AuthUtils.readUser();
  
  if (currentUser != null && currentUser.name == deletedUserName) {
    // Clear auth data to logout the user
    await AuthUtils.clearAuthData();
    print("==================== User logged out due to deletion ====================");
    await syncManager?.stop();
    
    // Note: The app will need to detect this on the next state check
    // and navigate to login screen. This can be done in main.dart
    // by checking AuthUtils.isAuthenticated() on app start/resume.
  }
}

}