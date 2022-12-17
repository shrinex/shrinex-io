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
        return _kErrCannotConnectToHost;
      case DioErrorType.response:
        return ErrorEnvelope(
          code: ex.response?.statusCode ?? ErrorEnvelope.unknown.code,
          message: ex.response?.statusMessage ?? ErrorEnvelope.unknown.message,
        );
      default:
        return ErrorEnvelope(code: -2, message: ex.message);
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
    if (json[_kCodeKey].integerValue != 200) {
      return true;
    }

    return false;
  }

  @override
  ErrorEnvelope handleError(HttpRequest request, HttpResponse response) {
    if (response.body == null) {
      return _kErrMissingResponseBody;
    }

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      return ErrorEnvelope(
        code: response.statusCode ?? ErrorEnvelope.unknown.code,
        message: response.statusMessage ?? ErrorEnvelope.unknown.message,
      );
    }

    final json = JSON.from(response.body);
    return ErrorEnvelope(
      code: json[_kCodeKey].integer ?? ErrorEnvelope.unknown.code,
      message: json[_kMessageKey].string ?? ErrorEnvelope.unknown.message,
    );
  }
}

const _kCodeKey = "code";
const _kMessageKey = "message";
const _kErrMissingResponseBody = ErrorEnvelope(
  code: -3,
  message: "Missing response body",
);
const _kErrCannotConnectToHost = ErrorEnvelope(
  code: -4,
  message: "Cannot connect to the host",
);
