import 'dart:math';

class RateSource {
  final String provider;
  final double rate;

  RateSource(this.provider, this.rate);
}

class ArbitrageService {
  /// Finds the best rate across multiple sources
  /// Returns the provider name with the highest rate (for selling base currency)
  RateSource findBestRate(Map<String, double> sourceRates) {
    if (sourceRates.isEmpty) {
      throw Exception('No rates available');
    }

    String bestProvider = '';
    double bestRate = 0.0;

    for (final entry in sourceRates.entries) {
      if (entry.value > bestRate) {
        bestRate = entry.value;
        bestProvider = entry.key;
      }
    }

    return RateSource(bestProvider, bestRate);
  }

  /// Calculates arbitrage opportunity percentage
  /// Returns the percentage difference between highest and lowest rates
  double calculateArbitrageOpportunity(Map<String, double> sourceRates) {
    if (sourceRates.isEmpty || sourceRates.length < 2) {
      return 0.0;
    }

    final rates = sourceRates.values.toList();
    final maxRate = rates.reduce(max);
    final minRate = rates.reduce(min);

    if (minRate == 0) return 0.0;

    return ((maxRate - minRate) / minRate) * 100;
  }

  /// Gets all rates sorted by value (descending)
  List<RateSource> getSortedRates(Map<String, double> sourceRates) {
    final sortedEntries = sourceRates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries.map((e) => RateSource(e.key, e.value)).toList();
  }
}

