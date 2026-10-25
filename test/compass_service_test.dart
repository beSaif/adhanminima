import 'dart:async';

import 'package:adhanminima/services/compass_service.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_test/flutter_test.dart';

const timeout = Duration(milliseconds: 50);

CompassEvent heading(double degrees) =>
    CompassEvent.fromList([degrees, degrees, 15]);

void main() {
  test('a compass that never reports counts as unavailable', () async {
    final events = StreamController<CompassEvent>();
    final service = CompassService(
      events: events.stream,
      firstReadingTimeout: timeout,
    );

    final readings = await service.readings(46.2, 6.1).toList();
    expect(readings, [isA<CompassWaiting>(), isA<CompassUnavailable>()]);
    expect(events.hasListener, isFalse);
  });

  test('a quiet compass that already reported keeps its heading', () async {
    final events = StreamController<CompassEvent>();
    final service = CompassService(
      events: events.stream,
      firstReadingTimeout: timeout,
    );
    final readings = service.readings(46.2, 6.1).toList();

    events.add(heading(90));
    await Future<void>.delayed(timeout * 4);
    await events.close();

    expect(await readings, [isA<CompassWaiting>(), isA<CompassHeading>()]);
  });
}
