import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ExchangeProvider {
  String get name;
  Future<Map<String, double>> getRates(String base, List<String> targets);
}

class BinanceProvider implements ExchangeProvider {
  @override
  String get name => 'Binance';

  @override
  Future<Map<String, double>> getRates(String base, List<String> targets) async {
    final rates = <String, double>{};
    
    for (final target in targets) {
      try {
        // Binance format: BTCUSDT, ETHUSDT, etc.
        final symbol = '${base.toUpperCase()}${target.toUpperCase()}';
        final url = Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=$symbol');
        
        final response = await http.get(url).timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception('Binance API timeout'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final price = double.tryParse(data['price']?.toString() ?? '') ?? 0.0;
          if (price > 0) {
            rates[target] = price;
          }
        }
      } catch (e) {
        // Log error but continue with other pairs
        print('Error fetching $base/$target from Binance: $e');
      }
    }
    
    return rates;
  }
}

class ExchangeRateHostProvider implements ExchangeProvider {
  @override
  String get name => 'ExchangeRate.host';

  @override
  Future<Map<String, double>> getRates(String base, List<String> targets) async {
    final rates = <String, double>{};
    
    try {
      final targetsStr = targets.join(',');
      final url = Uri.parse(
        'https://api.exchangerate.host/latest?base=$base&symbols=$targetsStr'
      );
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('ExchangeRate.host API timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final ratesMap = data['rates'] as Map<String, dynamic>?;
        
        if (ratesMap != null) {
          for (final entry in ratesMap.entries) {
            final rate = double.tryParse(entry.value.toString()) ?? 0.0;
            if (rate > 0) {
              rates[entry.key] = rate;
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching rates from ExchangeRate.host: $e');
    }
    
    return rates;
  }
}

class FixerProvider implements ExchangeProvider {
  final String? apiKey;

  FixerProvider(this.apiKey);

  @override
  String get name => 'Fixer.io';

  @override
  Future<Map<String, double>> getRates(String base, List<String> targets) async {
    final rates = <String, double>{};
    
    if (apiKey == null || apiKey!.isEmpty) {
      // Fixer.io requires API key, return empty if not provided
      return rates;
    }

    try {
      final targetsStr = targets.join(',');
      final url = Uri.parse(
        'https://api.fixer.io/latest?access_key=$apiKey&base=$base&symbols=$targetsStr'
      );
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Fixer.io API timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final ratesMap = data['rates'] as Map<String, dynamic>?;
          
          if (ratesMap != null) {
            for (final entry in ratesMap.entries) {
              final rate = double.tryParse(entry.value.toString()) ?? 0.0;
              if (rate > 0) {
                rates[entry.key] = rate;
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching rates from Fixer.io: $e');
    }
    
    return rates;
  }
}

