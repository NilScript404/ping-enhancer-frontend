
import 'package:dio/dio.dart';
import 'package:my_app/features/icmp/models/ping_target.dart';

class IcmpApiService {
  IcmpApiService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  final Dio _dio;

  Future<List<PingTarget>> fetchTargets() async {
    final response = await _dio.get('/api/configs');

    final List<dynamic> data = response.data;

    return data.map((item) {
      final json = Map<String, dynamic>.from(item);

      return PingTarget(
        countryCode: json['location']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        type: json['route_type']?.toString() ?? '',
        routeAddress: json['route_address']?.toString() ?? '',
        min: 0,
        avg: 0,
        max: 0,
        loss: 0,
      );
    }).toList();
  }
}
