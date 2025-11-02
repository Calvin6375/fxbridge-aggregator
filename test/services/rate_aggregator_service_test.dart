import 'package:test/test.dart';
import '../../lib/services/rate_aggregator_service.dart';
import '../../lib/utils/config.dart';

void main() {
  group('RateAggregatorService', () {
    late RateAggregatorService service;
    late Config config;

    setUp(() {
      config = Config();
      config.load();
      service = RateAggregatorService(config);
    });

    test('should return RateResponse with required fields', () async {
      final response = await service.getAggregatedRate('USD', 'EUR');

      expect(response, isA<RateResponse>());
      expect(response.timestamp, isNotEmpty);
      expect(response.base, equals('USD'));
      expect(response.target, equals('EUR'));
      expect(response.sources, isNotEmpty);
      expect(response.bestRate, greaterThan(0));
      expect(response.bestProvider, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('should return JSON serializable response', () async {
      final response = await service.getAggregatedRate('USD', 'EUR');
      final json = response.toJson();

      expect(json, contains('timestamp'));
      expect(json, contains('base'));
      expect(json, contains('target'));
      expect(json, contains('sources'));
      expect(json, contains('bestRate'));
      expect(json, contains('bestProvider'));
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('should cache responses', () async {
      final response1 = await service.getAggregatedRate('USD', 'GBP');
      final response2 = await service.getAggregatedRate('USD', 'GBP');

      // Cached responses should have same timestamp (or very close)
      expect(response1.timestamp, equals(response2.timestamp));
    }, timeout: const Timeout(Duration(seconds: 15)));
  });
}

