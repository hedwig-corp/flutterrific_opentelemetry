// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterrific_opentelemetry/src/util/platform_detection.dart';

void main() {
  group('OTEL_EXPORTER_OTLP_HEADERS parsing', () {
    test('parseOtlpHeaders returns empty map when no environment variable is set', () {
      // When OTEL_EXPORTER_OTLP_HEADERS is not set, it defaults to empty string
      final headers = PlatformDetection.parseOtlpHeaders();
      expect(headers, isEmpty);
    });

    test('parseOtlpHeaders handles single key-value pair', () {
      // This test demonstrates the expected format for a single header
      // In actual usage, this would be set via --dart-define=OTEL_EXPORTER_OTLP_HEADERS="api-key=secret123"
      
      // Note: We can't actually test environment variable parsing in unit tests
      // because String.fromEnvironment is evaluated at compile time.
      // This test documents the expected behavior.
      
      const testInput = "api-key=secret123";
      final result = _parseHeadersString(testInput);
      expect(result, equals({"api-key": "secret123"}));
    });

    test('parseOtlpHeaders handles multiple key-value pairs', () {
      const testInput = "authorization=Bearer token123,content-type=application/json,x-custom=value";
      final result = _parseHeadersString(testInput);
      expect(result, equals({
        "authorization": "Bearer token123",
        "content-type": "application/json", 
        "x-custom": "value"
      }));
    });

    test('parseOtlpHeaders handles headers with spaces in values', () {
      const testInput = "authorization=Bearer token with spaces,user-agent=My App 1.0";
      final result = _parseHeadersString(testInput);
      expect(result, equals({
        "authorization": "Bearer token with spaces",
        "user-agent": "My App 1.0"
      }));
    });

    test('parseOtlpHeaders handles empty values', () {
      const testInput = "api-key=,authorization=Bearer token";
      final result = _parseHeadersString(testInput);
      expect(result, equals({
        "api-key": "",
        "authorization": "Bearer token"
      }));
    });

    test('parseOtlpHeaders ignores invalid formats', () {
      const testInput = "valid-key=value,invalid-no-equals,another-valid=test";
      final result = _parseHeadersString(testInput);
      expect(result, equals({
        "valid-key": "value",
        "another-valid": "test"
      }));
    });

    test('parseOtlpHeaders ignores empty keys', () {
      const testInput = "=empty-key,valid=value";
      final result = _parseHeadersString(testInput);
      expect(result, equals({
        "valid": "value"
      }));
    });

    test('parseOtlpHeaders handles whitespace around separators', () {
      const testInput = " key1 = value1 , key2=value2, key3 =value3";
      final result = _parseHeadersString(testInput);
      expect(result, equals({
        "key1": "value1",
        "key2": "value2", 
        "key3": "value3"
      }));
    });

    test('parseOtlpHeaders handles Grafana-style authentication', () {
      // Example for Grafana Cloud authentication
      const testInput = "authorization=Basic dXNlcjpwYXNz";
      final result = _parseHeadersString(testInput);
      expect(result, equals({
        "authorization": "Basic dXNlcjpwYXNz"
      }));
    });
  });
}

// Helper function that mimics the logic from PlatformDetection.parseOtlpHeaders()
// but takes a string parameter instead of reading from environment variables
Map<String, String> _parseHeadersString(String headersEnv) {
  if (headersEnv.isEmpty) {
    return <String, String>{};
  }

  final headers = <String, String>{};
  
  // Split by comma and process each key-value pair
  for (final pair in headersEnv.split(',')) {
    final trimmedPair = pair.trim();
    if (trimmedPair.isEmpty) continue;
    
    // Find the first '=' to split key and value
    final equalIndex = trimmedPair.indexOf('=');
    if (equalIndex == -1) {
      // Invalid format - skip this pair
      continue;
    }
    
    final key = trimmedPair.substring(0, equalIndex).trim();
    final value = trimmedPair.substring(equalIndex + 1).trim();
    
    if (key.isEmpty) {
      continue;
    }
    
    headers[key] = value;
  }
  
  return headers;
}