/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shrinex_io/src/error_envelope.dart';
import 'package:shrinex_io/src/http_request.dart';
import 'package:shrinex_io/src/server_options.dart';

abstract class Service {
  ServerOptions get serverOptions;

  late final _restClient = () {
    var options = BaseOptions(
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,
      contentType: Headers.jsonContentType,
      baseUrl: serverOptions.baseUrl.toString(),
      receiveTimeout: serverOptions.readTimeout,
      connectTimeout: serverOptions.connectTimeout,
    );
    return Dio(options);
  }();
}

extension ReactiveX on Service {
  Stream<Map<String, dynamic>> observe(HttpRequest request) {
    final options = RequestOptions(
      path: request.path,
      data: request.body,
      headers: request.headers,
      method: request.method.rawValue,
      queryParameters: request.queryParams,
      responseType: _restClient.options.responseType,
      contentType: _restClient.options.contentType,
      baseUrl: request.baseUrl ?? _restClient.options.baseUrl.toString(),
      receiveTimeout: request.readTimeout ?? _restClient.options.receiveTimeout,
      connectTimeout:
          request.connectTimeout ?? _restClient.options.connectTimeout,
      receiveDataWhenStatusError:
          _restClient.options.receiveDataWhenStatusError,
    );
    return Rx.defer(
      () {
        return Stream.fromFuture(() async {
          try {
            final response =
                await _restClient.fetch<Map<String, dynamic>>(options);
            if (response.data == null) {
              return Future<Map<String, dynamic>>.error(_missingResponseBody);
            }
            return Future.value(response.data!);
          } on DioError catch (err) {
            return _handleError(err);
          }
        }());
      },
      reusable: true,
    ).distinct();
  }

  Future<Map<String, dynamic>> _handleError(DioError err) {
    switch (err.type) {
      case DioErrorType.sendTimeout:
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
        return Future.error(_cannotConnectToHost);
      case DioErrorType.response:
        return Future.error(ErrorEnvelope(
          err.response?.statusCode ?? ErrorEnvelope.unknown.code,
          err.response?.statusMessage ?? ErrorEnvelope.unknown.message,
        ));
      default:
        return Future.error(ErrorEnvelope.unknown);
    }
  }
}

const _missingResponseBody = ErrorEnvelope(12590, "Missing response body");
const _cannotConnectToHost = ErrorEnvelope(12591, "Cannot connect to host");
