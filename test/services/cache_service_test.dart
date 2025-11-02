import 'package:test/test.dart';
import '../../lib/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService(defaultTtl: const Duration(seconds: 1));
    });

    tearDown(() {
      cacheService.clear();
    });

    test('should store and retrieve cached value', () {
      cacheService.set('test_key', {'value': 123});
      final cached = cacheService.get('test_key');
      
      expect(cached, isNotNull);
      expect(cached['value'], equals(123));
    });

    test('should return null for expired cache entry', () async {
      cacheService.set('test_key', {'value': 123}, ttl: const Duration(milliseconds: 100));
      
      final cached1 = cacheService.get('test_key');
      expect(cached1, isNotNull);
      
      await Future.delayed(const Duration(milliseconds: 150));
      
      final cached2 = cacheService.get('test_key');
      expect(cached2, isNull);
    });

    test('should clear all cache entries', () {
      cacheService.set('key1', 'value1');
      cacheService.set('key2', 'value2');
      
      expect(cacheService.size, equals(2));
      
      cacheService.clear();
      
      expect(cacheService.size, equals(0));
      expect(cacheService.get('key1'), isNull);
      expect(cacheService.get('key2'), isNull);
    });

    test('should clean expired entries', () async {
      cacheService.set('key1', 'value1', ttl: const Duration(milliseconds: 50));
      cacheService.set('key2', 'value2', ttl: const Duration(seconds: 10));
      
      expect(cacheService.size, equals(2));
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      cacheService.cleanExpired();
      
      expect(cacheService.size, equals(1));
      expect(cacheService.get('key2'), equals('value2'));
    });
  });
}

