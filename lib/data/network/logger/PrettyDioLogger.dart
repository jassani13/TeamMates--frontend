import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CleanDioLogger extends Interceptor {
  final bool logRequest;
  final bool logResponse;
  final bool logError;

  CleanDioLogger({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
  });

  void _prettyPrintJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(data);

      // ek hi block me print hoga, har line ke aage "flutter:" nahi aayega
      debugPrint(prettyJson, wrapWidth: 1024);
    } catch (_) {
      debugPrint(data.toString(), wrapWidth: 1024);
    }
  }


  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest) {
      debugPrint("➡️ [${options.method}] ${options.uri}");

      if (options.headers.isNotEmpty) {
        debugPrint("Headers:");
        options.headers.forEach((k, v) => debugPrint("  $k: $v"));
      }

      if (options.data != null) {
        if (options.data is FormData) {
          final formData = options.data as FormData;

          if (formData.fields.isNotEmpty) {
            debugPrint("FormData fields:");
            for (var field in formData.fields) {
              debugPrint("  ${field.key}: ${field.value}");
            }
          }

          if (formData.files.isNotEmpty) {
            debugPrint("FormData files:");
            for (var file in formData.files) {
              debugPrint("  ${file.key}: ${file.value.filename}");
            }
          }
        } else {
          debugPrint("Body:");
          _prettyPrintJson(options.data);
        }
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponse) {
      debugPrint("✅ [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}");
      debugPrint("Response:");
      _prettyPrintJson(response.data);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logError) {
      debugPrint("❌ ERROR [${err.response?.statusCode ?? 'Unknown'}] ${err.requestOptions.uri}");
      debugPrint("Message: ${err.message}");

      if (err.response?.data != null) {
        debugPrint("Error Response:");
        _prettyPrintJson(err.response?.data);
      }
    }
    handler.next(err);
  }
}
