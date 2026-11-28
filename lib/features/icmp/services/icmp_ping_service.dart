
import 'package:dart_ping/dart_ping.dart';

class IcmpPingService {
  Future<PingSummary> pingServer(String address) async {
    final host = address.trim();

    if (host.isEmpty) {
      throw ArgumentError('Server route address is empty');
    }

    final ping = Ping(
      host,
      count: 5,
      interval: 1,
      timeout: 2,
    );

    PingSummary? summary;

    await for (final event in ping.stream) {
      if (event is PingSummary) {
        summary = event;
      }
    }

    if (summary == null) {
      throw Exception('No ICMP summary received for $host');
    }

    return summary;
  }
}
