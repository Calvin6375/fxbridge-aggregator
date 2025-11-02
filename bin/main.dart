import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../lib/utils/config.dart';
import '../lib/services/rate_aggregator_service.dart';
import '../lib/middleware/request_logger.dart';
import '../lib/routes/routes.dart';

void main(List<String> args) async {
  final config = Config();
  config.load();

  final rateService = RateAggregatorService(config);

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(requestLoggerMiddleware())
      .addHandler(createRoutes(rateService));

  final port = int.tryParse(config.port) ?? 8080;
  final host = config.host;

  print('🚀 FXBridge Aggregator API starting on http://$host:$port');
  print('📚 Swagger UI: http://$host:$port/swagger');
  print('📋 API Docs: http://$host:$port/swagger.json');

  final server = await io.serve(handler, host, port);
  print('✅ Server running on ${server.address}:${server.port}');
}

