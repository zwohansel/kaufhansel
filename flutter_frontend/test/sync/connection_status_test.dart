import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaufhansel_client/sync/connection_status.dart';

void main() {
  late StreamController<bool> systemHasNetwork;
  late int probes;
  final List<ConnectionStatus> toBeDisposed = [];

  setUp(() {
    systemHasNetwork = StreamController<bool>();
    probes = 0;
  });

  tearDown(() {
    toBeDisposed.forEach((status) => status.dispose());
    toBeDisposed.clear();
    systemHasNetwork.close();
  });

  /// A status that follows what the system says about the network and counts how
  /// often it asked the server. Without a probe interval the stream is the only
  /// thing that can make it ask.
  ConnectionStatus makeStatus({Duration? probeInterval}) {
    final status = ConnectionStatus(() async => probes++,
        probeInterval: probeInterval, systemHasNetwork: systemHasNetwork.stream);
    toBeDisposed.add(status);
    return status;
  }

  /// Lets the stream deliver its event.
  Future<void> deliver() => Future.delayed(Duration.zero);

  test("asks the server whether it is back when the device gets a network", () async {
    makeStatus().reportFailure();

    systemHasNetwork.add(true);
    await deliver();

    expect(probes, 1);
  });

  test("does not ask while the server is known to be reachable", () async {
    makeStatus();

    systemHasNetwork.add(true);
    await deliver();

    expect(probes, 0);
  });

  // A widget test for the sake of its fake clock: the first probe is a quarter
  // of a minute away, which is not a wait a test can sit through.
  testWidgets("stops asking while the device has no network at all", (WidgetTester tester) async {
    // Being offline alone would have the server asked every 15 seconds.
    final status = makeStatus(probeInterval: Duration(seconds: 15));
    status.reportFailure();

    systemHasNetwork.add(false);
    await tester.pump();
    await tester.pump(Duration(minutes: 2));

    expect(probes, 0, reason: "a device without a network cannot reach the server");

    // An explicit probe, as the app does when it comes back to the foreground,
    // still asks: the system may have been quicker to report the loss than the
    // recovery. It must not start the periodic probing up again, though.
    await status.probe();
    await tester.pump(Duration(minutes: 2));

    expect(probes, 1, reason: "the periodic probing must stay off without a network");

    systemHasNetwork.add(true);
    await tester.pump();

    expect(probes, 2, reason: "the probing has to pick back up with the network");

    // The probe above has scheduled the next one, which the test must not leave
    // behind.
    status.dispose();
    toBeDisposed.remove(status);
  });

  test("stops asking once it is disposed", () async {
    final status = makeStatus();
    status.reportFailure();
    status.dispose();
    toBeDisposed.remove(status);

    systemHasNetwork.add(true);
    await deliver();

    expect(probes, 0);
  });
}
