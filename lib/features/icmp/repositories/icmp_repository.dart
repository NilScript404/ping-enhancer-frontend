
import 'package:my_app/features/icmp/models/ping_target.dart';
import 'package:my_app/features/icmp/services/icmp_api_service.dart';
import 'package:my_app/features/icmp/services/icmp_ping_service.dart';

class IcmpRepository {
  IcmpRepository({
    required this._apiService,
    required this._pingService,
  });

  final IcmpApiService _apiService;
  final IcmpPingService _pingService;

  // دریافت لیست سرورها از بک‌اند
  Future<List<PingTarget>> fetchTargets() {
    return _apiService.fetchTargets();
  }

  // اجرای تست ICMP برای یک سرور
  Future<PingTarget> testTarget(PingTarget target) async {
    try {
      final result = await _pingService.pingServer(
        target.routeAddress,
      );

      final stats = result.stats;

      return target.copyWith(
        min: stats?.min?.inMilliseconds ?? 0,
        avg: stats?.avg?.inMilliseconds ?? 0,
        max: stats?.max?.inMilliseconds ?? 0,
        loss: result.packetLoss.round(),
      );
    } catch (e) {
      return target.copyWith(
        min: 0,
        avg: 0,
        max: 0,
        loss: 100,
      );
    }
  }
}
