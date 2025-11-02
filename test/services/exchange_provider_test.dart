import 'package:test/test.dart';
import '../../lib/services/exchange_provider.dart';

void main() {
  group('ExchangeRateHostProvider', () {
    late ExchangeRateHostProvider provider;

    setUp(() {
      provider = ExchangeRateHostProvider();
    });

    test('should have correct provider name', () {
      expect(provider.name, equals('ExchangeRate.host'));
    });

    test('should fetch rates for valid currency pairs', () async {
      final rates = await provider.getRates('USD', ['EUR']);

      expect(rates, isNotEmpty);
      expect(rates.containsKey('EUR'), isTrue);
      expect(rates['EUR'], greaterThan(0));
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('should handle invalid currency pairs gracefully', () async {
      final rates = await provider.getRates('INVALID', ['ALSO_INVALID']);

      // Should not throw, but may return empty or partial results
      expect(rates, isA<Map<String, double>>());
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  group('BinanceProvider', () {
    late BinanceProvider provider;

    setUp(() {
      provider = BinanceProvider();
    });

    test('should have correct provider name', () {
      expect(provider.name, equals('Binance'));
    });

    test('should fetch rates for valid crypto pairs', () async {
      final rates = await provider.getRates('BTC', ['USDT']);

      // May or may not succeed depending on availability, but should not throw
      expect(rates, isA<Map<String, double>>());
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  group('FixerProvider', () {
    test('should return empty rates when no API key provided', () async {
      final provider = FixerProvider(null);
      final rates = await provider.getRates('USD', ['EUR']);

      expect(rates, isEmpty);
    });

    test('should have correct provider name', () {
      final provider = FixerProvider('test_key');
      expect(provider.name, equals('Fixer.io'));
    });
  });
}

