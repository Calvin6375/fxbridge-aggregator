import 'dart:io';
import 'package:dotenv/dotenv.dart';

class Config {
  static final Config _instance = Config._internal();
  factory Config() => _instance;
  Config._internal();

  late final DotEnv _env;

  void load() {
    _env = DotEnv(includePlatformEnvironment: true)..load();
  }

  String get port => _env['PORT'] ?? '8080';
  String get host => _env['HOST'] ?? '0.0.0.0';
  int get cacheTtlSeconds => int.tryParse(_env['CACHE_TTL_SECONDS'] ?? '60') ?? 60;
  String get logLevel => _env['LOG_LEVEL'] ?? 'info';
  
  String? get binanceApiKey => _env['BINANCE_API_KEY'];
  String? get exchangerateApiKey => _env['EXCHANGERATE_API_KEY'];
  String? get fixerApiKey => _env['FIXER_API_KEY'];
}

