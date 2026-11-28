enum PingFilter { all, relay, direct }
enum SortMetric { avg, min, loss }

class PingTarget {
  const PingTarget({
    required this.countryCode,
    required this.name,
    required this.type,
    required this.routeAddress,
    required this.min,
    required this.avg,
    required this.max,
    required this.loss,
  });

  final String countryCode;
  final String name;
  final String type;
  final String routeAddress;

  final int min;
  final int avg;
  final int max;
  final int loss;

  bool get isRelay => type.toLowerCase().contains('relay');

  PingTarget copyWith({
    int? min,
    int? avg,
    int? max,
    int? loss,
  }) {
    return PingTarget(
      countryCode: countryCode,
      name: name,
      type: type,
      routeAddress: routeAddress,
      min: min ?? this.min,
      avg: avg ?? this.avg,
      max: max ?? this.max,
      loss: loss ?? this.loss,
    );
  }
}