import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Asks the server whether it is there. Reports the outcome through the
/// connection status, so there is nothing to return.
typedef ConnectionProbe = Future<void> Function();

/// Keeps track of whether the server is currently reachable.
///
/// The state is derived from the outcome of the requests the app sends anyway
/// rather than from the operating system's idea of connectivity: a device can
/// be connected to a wifi that has no internet access, and the server can be
/// down while the device is online. Both cases must count as "offline" here,
/// and only an actual request can tell them apart.
///
/// While offline the server is probed periodically so that the app notices on
/// its own when the connection comes back. Because waiting out that interval
/// takes up to a minute, the operating system's idea of connectivity can be fed
/// in: it says whether probing is worth a try at all, while the answer still
/// comes from the server. A device the system reports as having no network is
/// not probed, since no request could succeed anyway.
class ConnectionStatus extends ChangeNotifier {
  static const _minProbeInterval = Duration(seconds: 15);
  static const _maxProbeInterval = Duration(seconds: 60);

  final ConnectionProbe _probe;

  /// How long to wait before the first probe after going offline. If null no probing happens at all.
  final Duration? _probeInterval;

  StreamSubscription<bool>? _systemHasNetwork;

  /// Whether the operating system reports a network. Assumed until it says
  /// otherwise: the state is only ever learned from an event.
  bool _systemOnline = true;

  bool _online = true;
  Duration _nextProbeDelay = _minProbeInterval;
  Timer? _probeTimer;
  bool _probing = false;
  bool _disposed = false;

  /// [systemHasNetwork] tells whether the operating system currently reports a
  /// network. A device that has one is probed right away instead of waiting for
  /// the next scheduled probe, and one that has none is not probed at all.
  ConnectionStatus(this._probe, {Duration? probeInterval, Stream<bool>? systemHasNetwork})
      : _probeInterval = probeInterval {
    _systemHasNetwork = systemHasNetwork?.listen(_systemConnectivityChanged);
  }

  void _systemConnectivityChanged(bool hasNetwork) {
    _systemOnline = hasNetwork;
    if (hasNetwork) {
      probe();
    } else {
      // Nothing to probe for: stop until the system has a network again.
      _cancelProbeTimer();
    }
  }

  bool get online => _online;

  void reportSuccess() {
    _nextProbeDelay = _minProbeInterval;
    _cancelProbeTimer();
    _setOnline(true);
  }

  void reportFailure() {
    _setOnline(false);
    _scheduleProbe();
  }

  void _setOnline(bool online) {
    if (_disposed || _online == online) {
      return;
    }
    _online = online;
    notifyListeners();
  }

  /// Checks whether the server can be reached again. Call this whenever
  /// something happened that makes a changed connection likely, for example the
  /// app being brought back to the foreground.
  Future<void> probe() async {
    if (_disposed || _probing || _online) {
      return;
    }
    _probing = true;
    try {
      await _probe();
    } on Exception catch (e) {
      // Whether this means we are still offline or that the server answered
      // with something unexpected has already been recorded by the request
      // itself, which reports its outcome here.
      developer.log("The connection probe did not succeed.", error: e);
    } finally {
      _probing = false;
    }

    if (!_online) {
      _scheduleProbe();
    }
  }

  void _scheduleProbe() {
    final interval = _probeInterval;
    if (_disposed || interval == null || _probeTimer != null || !_systemOnline) {
      return;
    }
    final delay = _nextProbeDelay < interval ? interval : _nextProbeDelay;
    _probeTimer = Timer(delay, () {
      _probeTimer = null;
      // Back off so that a long outage does not keep waking the device up every
      // few seconds.
      _nextProbeDelay = delay * 2 > _maxProbeInterval ? _maxProbeInterval : delay * 2;
      probe();
    });
  }

  void _cancelProbeTimer() {
    _probeTimer?.cancel();
    _probeTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _systemHasNetwork?.cancel();
    _cancelProbeTimer();
    super.dispose();
  }
}
