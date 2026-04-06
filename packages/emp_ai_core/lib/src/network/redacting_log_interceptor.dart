import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'dio_log_redaction.dart';

/// Same role as Dio [LogInterceptor], but redacts [Authorization] and OAuth fields.
///
/// Add last in the chain if you need to see final headers (Dio recommendation).
final class RedactingLogInterceptor extends Interceptor {
  RedactingLogInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseHeader = true,
    this.responseBody = false,
    this.error = true,
    void Function(Object object)? logPrint,
  }) : logPrint = logPrint ?? _defaultLogPrint;

  bool request;
  bool requestHeader;
  bool requestBody;
  bool responseBody;
  bool responseHeader;
  bool error;
  void Function(Object object) logPrint;

  static void _defaultLogPrint(Object object) {
    debugPrint(object.toString());
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    logPrint('*** Request ***');
    _printKV('uri', options.uri);

    if (request) {
      _printKV('method', options.method);
      _printKV('responseType', options.responseType.toString());
      _printKV('followRedirects', options.followRedirects);
      _printKV('persistentConnection', options.persistentConnection);
      _printKV('connectTimeout', options.connectTimeout);
      _printKV('sendTimeout', options.sendTimeout);
      _printKV('receiveTimeout', options.receiveTimeout);
      _printKV(
        'receiveDataWhenStatusError',
        options.receiveDataWhenStatusError,
      );
      _printKV('extra', options.extra);
    }
    if (requestHeader) {
      logPrint('headers:');
      DioLogRedaction.maskHeaders(
        Map<String, dynamic>.from(options.headers),
      ).forEach((String k, Object? v) => _printKV(' $k', v));
    }
    if (requestBody) {
      logPrint('data:');
      _printRedacted(options.data);
    }
    logPrint('');

    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    logPrint('*** Response ***');
    _printResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      logPrint('*** DioException ***:');
      logPrint('uri: ${err.requestOptions.uri}');
      logPrint('$err');
      if (err.response != null) {
        _printResponse(err.response!);
      }
      logPrint('');
    }

    handler.next(err);
  }

  void _printResponse(Response<dynamic> response) {
    _printKV('uri', response.requestOptions.uri);
    if (responseHeader) {
      _printKV('statusCode', response.statusCode);
      if (response.isRedirect == true) {
        _printKV('redirect', response.realUri);
      }

      logPrint('headers:');
      response.headers.forEach(
        (String k, List<String> v) => _printKV(' $k', v.join('\r\n\t')),
      );
    }
    if (responseBody) {
      logPrint('Response Text:');
      _printRedacted(response.data);
    }
    logPrint('');
  }

  void _printKV(String key, Object? v) {
    logPrint('$key: $v');
  }

  void _printRedacted(Object? msg) {
    final dynamic redacted = DioLogRedaction.redactPayload(msg);
    if (redacted is Map || redacted is List) {
      try {
        logPrint(const JsonEncoder.withIndent('  ').convert(redacted));
        return;
      } on Object {
        // fall through
      }
    }
    redacted.toString().split('\n').forEach(logPrint);
  }
}
