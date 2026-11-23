import 'package:flutter/foundation.dart';
import 'package:kaufhansel_client/sync/connection_status.dart';

/// Whether the server can be reached and how many changes are still waiting to be sent to it.
class SyncStatus extends ChangeNotifier {
  final ConnectionStatus _connection;
  int _pendingChanges = 0;

  SyncStatus(this._connection) {
    _connection.addListener(notifyListeners);
  }

  bool get online => _connection.online;

  int get numPendingChanges => _pendingChanges;

  bool get hasPendingChanges => _pendingChanges > 0;

  bool get isOutOfSync => !online || hasPendingChanges;

  void setPendingChanges(int pendingChanges) {
    if (_pendingChanges == pendingChanges) {
      return;
    }
    _pendingChanges = pendingChanges;
    notifyListeners();
  }

  @override
  void dispose() {
    _connection.removeListener(notifyListeners);
    super.dispose();
  }
}
