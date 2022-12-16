/*
 * Created by Archer on 2022/12/11.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:dio/dio.dart';
import 'package:shrinex_io/src/error_envelope.dart';
import 'package:shrinex_io/src/http/http_request.dart';
import 'package:shrinex_io/src/http/http_response.dart';
import 'package:shrinex_io/src/smart_json.dart';

/// Strategy handler method used to adapt [Exception] to [ErrorEnvelope]
typedef ExceptionHandler = ErrorEnvelope Function(Exception);

ErrorEnvelope defaultExceptionHandler(Exception ex) {
  if (ex is DioError) {
    switch (ex.type) {
      case DioErrorType.sendTimeout:
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
        return _cannotConnectToHost;
      case DioErrorType.response:
        return ErrorEnvelope(
          ex.response?.statusCode ?? ErrorEnvelope.unknown.code,
          ex.response?.statusMessage ?? ErrorEnvelope.unknown.message,
        );
      default:
        return ErrorEnvelope(12592, ex.message);
    }
  }
  return ErrorEnvelope.unknown;
}

/// Handler method for code that operates on a [HttpRequest]
/// Allows manipulating the request headers, and write to the request body
typedef RequestHandler = HttpRequest Function(HttpRequest);

HttpRequest defaultRequestHandler(HttpRequest request) => request;

/// Strategy interface used by the [Service] to determine
/// whether a particular response has an error or not
abstract class ResponseErrorHandler {
  /// Indicate whether the given response has any errors
  bool hasError(HttpResponse response);

  /// Handle the error in the given request-response pair
  ErrorEnvelope handleError(HttpRequest request, HttpResponse response);
}

const defaultResponseErrorHandler = _ResponseErrorHandler();

class _ResponseErrorHandler implements ResponseErrorHandler {
  const _ResponseErrorHandler();

  @override
  bool hasError(HttpResponse response) {
    if (response.body == null) {
      return true;
    }

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      return true;
    }

    // {"code" : 200, "message" : "ok", "data" : {...}}
    final json = JSON.from(response.body);
    if (json[_responseBodyCodeKey].integerValue != 200) {
      return true;
    }

    return false;
  }

  @override
  ErrorEnvelope handleError(HttpRequest request, HttpResponse response) {
    if (response.body == null) {
      return _missingResponseBody;
    }

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      return ErrorEnvelope(
        response.statusCode ?? ErrorEnvelope.unknown.code,
        response.statusMessage ?? ErrorEnvelope.unknown.message,
      );
    }

    final json = JSON.from(response.body);
    return ErrorEnvelope(
      json[_responseBodyCodeKey].integer ?? ErrorEnvelope.unknown.code,
      json[_responseBodyMessageKey].string ?? ErrorEnvelope.unknown.message,
    );
  }
}

const _responseBodyCodeKey = "code";
const _responseBodyMessageKey = "message";
const _missingResponseBody = ErrorEnvelope(12590, "Missing response body");
const _cannotConnectToHost = ErrorEnvelope(12591, "Cannot connect to the host");
