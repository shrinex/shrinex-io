/*
 * Created by Archer on 2022/12/11.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:shrinex_io/src/error_envelope.dart';
import 'package:shrinex_io/src/http_request.dart';
import 'package:shrinex_io/src/http_response.dart';

/// Callback for code that operates on a [HttpRequest]
/// Allows manipulating the request headers, and write to the request body
typedef RequestCallback = void Function(HttpRequest);

void defaultRequestCallback(HttpRequest request) {}

/// Strategy interface used by the [Service] to determine
/// whether a particular response has an error or not
abstract class ResponseErrorHandler {
  /// Indicate whether the given response has any errors
  bool hasError(HttpResponse response);

  /// Handle the error in the given request-response pair
  Future<Map<String, dynamic>> handleError(
      HttpRequest request, HttpResponse response);
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
    return false;
  }

  @override
  Future<Map<String, dynamic>> handleError(
      HttpRequest request, HttpResponse response) {
    if (response.body == null) {
      return Future.error(_missingResponseBody);
    }
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      return Future.error(ErrorEnvelope(
        response.statusCode ?? ErrorEnvelope.unknown.code,
        response.statusMessage ?? ErrorEnvelope.unknown.message,
      ));
    }
    return Future.error(ErrorEnvelope.unknown);
  }
}

const _missingResponseBody = ErrorEnvelope(12590, "Missing response body");
