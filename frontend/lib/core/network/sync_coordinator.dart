import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hajedi/core/network/sync_manager.dart';

class SyncCoordinator with WidgetsBindingObserver {
  final SyncManager syncManager;
  final Duration interval;

  Timer? _timer;

  SyncCoordinator(
    this.syncManager, {
    this.interval = const Duration(seconds: 60),
  });

  void start() {
    WidgetsBinding.instance.addObserver(this);

    _startForegroundSync();
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
  }

  void _startForegroundSync() {
    _timer?.cancel();

    syncManager.syncIfConnected();

    _timer = Timer.periodic(
      interval,
      (_) {
        syncManager.syncIfConnected();
      },
    );
  }

  void _stopForegroundSync() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _startForegroundSync();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopForegroundSync();
    }
  }
}