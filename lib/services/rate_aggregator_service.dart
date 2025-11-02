import '../utils/config.dart';
import 'exchange_provider.dart';
import 'arbitrage_service.dart';
import 'cache_service.dart';

class RateResponse {
  final String timestamp;
  final String base;
  final String target;
  final Map<String, double> sources;
  final double bestRate;
  final String bestProvider;
  final double? arbitrageOpportunity;

  RateResponse({
    required this.timestamp,
    required this.base,
    required this.target,
    required this.sources,
    required this.bestRate,
    required this.bestProvider,
    this.arbitrageOpportunity,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'base': base,
      'target': target,
      'sources': sources,
      'bestRate': bestRate,
      'bestProvider': bestProvider,
      if (arbitrageOpportunity != null)
        'arbitrageOpportunity': arbitrageOpportunity!.toStringAsFixed(2),
    };
  }
}

class RateAggregatorService {
  final List<ExchangeProvider> _providers;
  final ArbitrageService _arbitrageService;
  final CacheService _cacheService;
  final Config _config;

  RateAggregatorService(this._config)
      : _arbitrageService = ArbitrageService(),
        _cacheService = CacheService(
          defaultTtl: Duration(seconds: _config.cacheTtlSeconds),
        ) {
    _providers = [
      BinanceProvider(),
      ExchangeRateHostProvider(),
      if (_config.fixerApiKey != null && _config.fixerApiKey!.isNotEmpty)
        FixerProvider(_config.fixerApiKey),
    ];
  }

  Future<RateResponse> getAggregatedRate(
    String base,
    String target,
  ) async {
    final cacheKey = 'rate_${base.toLowerCase()}_${target.toLowerCase()}';
    final cached = _cacheService.get(cacheKey);
    
    if (cached != null) {
      return RateResponse.fromJson(cached);
    }

    final sources = <String, double>{};
    
    // Fetch rates from all providers in parallel
    final futures = _providers.map((provider) async {
      try {
        final rates = await provider.getRates(base, [target]);
        if (rates.containsKey(target)) {
          sources[provider.name] = rates[target]!;
        }
      } catch (e) {
        print('Error fetching from ${provider.name}: $e');
      }
    }));

    await Future.wait(futures);

    if (sources.isEmpty) {
      throw Exception('No rates available from any provider');
    }

    final bestRateSource = _arbitrageService.findBestRate(sources);
    final arbitrageOpportunity = sources.length > 1
        ? _arbitrageService.calculateArbitrageOpportunity(sources)
        : null;

    final response = RateResponse(
      timestamp: DateTime.now().toUtc().toIso8601String(),
      base: base.toUpperCase(),
      target: target.toUpperCase(),
      sources: sources,
      bestRate: bestRateSource.rate,
      bestProvider: bestRateSource.provider,
      arbitrageOpportunity: arbitrageOpportunity,
    );

    // Cache the response
    _cacheService.set(cacheKey, response.toJson());

    return response;
  }
}

// Extension to convert JSON back to RateResponse for caching
extension RateResponseExtension on RateResponse {
  static RateResponse fromJson(Map<String, dynamic> json) {
    return RateResponse(
      timestamp: json['timestamp'] as String,
      base: json['base'] as String,
      target: json['target'] as String,
      sources: Map<String, double>.from(
        (json['sources'] as Map).map((k, v) => MapEntry(k, v is double ? v : double.parse(v.toString()))),
      ),
      bestRate: json['bestRate'] is double ? json['bestRate'] : double.parse(json['bestRate'].toString()),
      bestProvider: json['bestProvider'] as String,
      arbitrageOpportunity: json['arbitrageOpportunity'] != null
          ? double.tryParse(json['arbitrageOpportunity'].toString())
          : null,
    );
  }
}

