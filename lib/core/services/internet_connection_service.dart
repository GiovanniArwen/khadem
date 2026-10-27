import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class InternetConnectionService {
  InternetConnectionService._();

  static final InternetConnectionService instance =
      InternetConnectionService._();

  final Connectivity _connectivity = Connectivity();

  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> initialize() async {
    await _checkInternet();

    _subscription = _connectivity.onConnectivityChanged.listen((_) async {
      await _checkInternet();
    });
  }

Future<void> _checkInternet() async {
  try {
    final connectivityResult = await _connectivity.checkConnectivity();

    isConnected.value =
        !connectivityResult.contains(ConnectivityResult.none);
  } catch (_) {
    isConnected.value = false;
  }
}
  Future<void> dispose() async {
    await _subscription?.cancel();
    isConnected.dispose();
  }
}