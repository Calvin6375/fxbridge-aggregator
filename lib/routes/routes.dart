import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/rate_aggregator_service.dart';
import '../utils/config.dart';

Handler createRoutes(RateAggregatorService rateService) {
  final router = Router();

  router.get('/health', (Request request) {
    return Response.ok(
      {'status': 'healthy', 'timestamp': DateTime.now().toUtc().toIso8601String()},
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/rates', (Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final base = queryParams['base']?.toUpperCase() ?? 'USD';
      final target = queryParams['target']?.toUpperCase();

      if (target == null || target.isEmpty) {
        return Response.badRequest(
          body: {'error': 'target parameter is required'},
          headers: {'Content-Type': 'application/json'},
        );
      }

      final rateResponse = await rateService.getAggregatedRate(base, target);

      return Response.ok(
        rateResponse.toJson(),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: {'error': e.toString()},
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // OpenAPI/Swagger endpoint
  router.get('/swagger.json', (Request request) {
    final swaggerDoc = {
      'openapi': '3.0.0',
      'info': {
        'title': 'FXBridge Aggregator API',
        'description': 'Multi-Source Rate Aggregator API for forex and crypto exchange rates',
        'version': '1.0.0',
      },
      'servers': [
        {'url': 'http://localhost:8080', 'description': 'Development server'},
      ],
      'paths': {
        '/health': {
          'get': {
            'summary': 'Health check endpoint',
            'responses': {
              '200': {
                'description': 'Service is healthy',
                'content': {
                  'application/json': {
                    'example': {
                      'status': 'healthy',
                      'timestamp': '2024-01-01T00:00:00.000Z',
                    },
                  },
                },
              },
            },
          },
        },
        '/rates': {
          'get': {
            'summary': 'Get aggregated exchange rates',
            'description': 'Fetches real-time exchange rates from multiple providers and returns the best rate',
            'parameters': [
              {
                'name': 'base',
                'in': 'query',
                'required': false,
                'schema': {'type': 'string', 'default': 'USD'},
                'description': 'Base currency code (e.g., USD, BTC, EUR)',
              },
              {
                'name': 'target',
                'in': 'query',
                'required': true,
                'schema': {'type': 'string'},
                'description': 'Target currency code (e.g., EUR, USDT, GBP)',
              },
            ],
            'responses': {
              '200': {
                'description': 'Successfully retrieved rates',
                'content': {
                  'application/json': {
                    'example': {
                      'timestamp': '2024-01-01T00:00:00.000Z',
                      'base': 'USD',
                      'target': 'EUR',
                      'sources': {
                        'ExchangeRate.host': 0.92,
                        'Fixer.io': 0.921,
                      },
                      'bestRate': 0.921,
                      'bestProvider': 'Fixer.io',
                      'arbitrageOpportunity': '0.11',
                    },
                  },
                },
              },
              '400': {
                'description': 'Bad request - missing required parameter',
              },
              '500': {
                'description': 'Internal server error',
              },
            },
          },
        },
      },
    };

    return Response.ok(
      swaggerDoc,
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Serve Swagger UI (simple redirect to swagger.io)
  router.get('/swagger', (Request request) {
    final html = '''
<!DOCTYPE html>
<html>
<head>
    <title>FXBridge API - Swagger UI</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
        SwaggerUIBundle({
            url: "/swagger.json",
            dom_id: "#swagger-ui",
            presets: [SwaggerUIBundle.presets.apis]
        });
    </script>
</body>
</html>
''';

    return Response.ok(
      html,
      headers: {'Content-Type': 'text/html'},
    );
  });

  return router;
}

