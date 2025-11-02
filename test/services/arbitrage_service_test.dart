import 'package:test/test.dart';
import '../../lib/services/arbitrage_service.dart';

void main() {
  group('ArbitrageService', () {
    late ArbitrageService arbitrageService;

    setUp(() {
      arbitrageService = ArbitrageService();
    });

    test('should find the best rate from multiple sources', () {
      final sourceRates = {
        'Provider1': 1.0,
        'Provider2': 1.5,
        'Provider3': 1.2,
      };

      final bestRate = arbitrageService.findBestRate(sourceRates);

      expect(bestRate.provider, equals('Provider2'));
      expect(bestRate.rate, equals(1.5));
    });

    test('should throw exception for empty rates', () {
      expect(
        () => arbitrageService.findBestRate({}),
        throwsException,
      );
    });

    test('should calculate arbitrage opportunity percentage', () {
      final sourceRates = {
        'Provider1': 1.0,
        'Provider2': 1.1,
      };

      final opportunity = arbitrageService.calculateArbitrageOpportunity(sourceRates);

      expect(opportunity, closeTo(10.0, 0.01));
    });

    test('should return 0 for single source', () {
      final sourceRates = {
        'Provider1': 1.0,
      };

      final opportunity = arbitrageService.calculateArbitrageOpportunity(sourceRates);

      expect(opportunity, equals(0.0));
    });

    test('should return sorted rates in descending order', () {
      final sourceRates = {
        'Provider1': 1.0,
        'Provider2': 1.5,
        'Provider3': 1.2,
      };

      final sorted = arbitrageService.getSortedRates(sourceRates);

      expect(sorted.length, equals(3));
      expect(sorted[0].rate, equals(1.5));
      expect(sorted[1].rate, equals(1.2));
      expect(sorted[2].rate, equals(1.0));
    });
  });
}

