import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_logger/shelf_logger.dart';

Middleware requestLoggerMiddleware() {
  return logRequests(
    logger: (message, isError) {
      final timestamp = DateTime.now().toIso8601String();
      if (isError) {
        stderr.writeln('[$timestamp] ERROR: $message');
      } else {
        stdout.writeln('[$timestamp] $message');
      }
    },
  );
}

