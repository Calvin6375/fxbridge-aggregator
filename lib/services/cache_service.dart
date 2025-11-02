import 'dart:collection';

class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  CacheEntry(this.data, Duration ttl) : expiresAt = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CacheEntry> _cache = {};
  final Duration _defaultTtl;

  CacheService({Duration? defaultTtl}) : _defaultTtl = defaultTtl ?? const Duration(seconds: 60);

  /// Get cached value or null if expired/not found
  dynamic get(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data;
  }

  /// Set cached value with TTL
  void set(String key, dynamic value, {Duration? ttl}) {
    _cache[key] = CacheEntry(value, ttl ?? _defaultTtl);
  }

  /// Clear expired entries
  void cleanExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Get cache size
  int get size => _cache.length;
}

