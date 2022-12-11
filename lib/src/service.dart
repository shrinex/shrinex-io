/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shrinex_io/src/bearer_token.dart';
import 'package:shrinex_io/src/error_envelope.dart';
import 'package:shrinex_io/src/http_request.dart';
import 'package:shrinex_io/src/server_options.dart';

/// A type that knows how to fetch ShrineX data.
abstract class Service {
  /// Used to authenticate ShrineX api
  BearerToken? get bearerToken;

  /// The [ServerOptions] associated with this [Service]
  ServerOptions get serverOptions;

  late final _restClient = () {
    var options = BaseOptions(
      baseUrl: serverOptions.baseUrl,
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,
      contentType: Headers.jsonContentType,
      receiveTimeout: serverOptions.readTimeout,
      connectTimeout: serverOptions.connectTimeout,
    );
    return Dio(options);
  }();

  /// Factory method that helps create [Service] instance
  factory Service.using({
    BearerToken? bearerToken,
    required ServerOptions serverOptions,
  }) =>
      _Service(
        bearerToken: bearerToken,
        serverOptions: serverOptions,
      );

  /// Returns a new service with the Service token replaced
  Service login(BearerToken bearerToken) {
    return Service.using(
      bearerToken: bearerToken,
      serverOptions: serverOptions,
    );
  }

  /// Returns a new service with the bearer token set to `null`
  Service logout() {
    return Service.using(
      bearerToken: null,
      serverOptions: serverOptions,
    );
  }
}

/// Reactive extension for [Service]
extension ReactiveX on Service {
  /// Entry point for making HTTP request, returns a cold but broadcast stream
  Stream<Map<String, dynamic>> observe(HttpRequest request) {
    final options = RequestOptions(
      path: request.path,
      data: request.body,
      headers: request.headers,
      method: request.method.rawValue,
      queryParameters: request.queryParams,
      responseType: _restClient.options.responseType,
      contentType: _restClient.options.contentType,
      baseUrl: request.baseUrl ?? _restClient.options.baseUrl,
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

class _Service with Service {
  @override
  final BearerToken? bearerToken;

  @override
  final ServerOptions serverOptions;

  _Service({
    this.bearerToken,
    required this.serverOptions,
  });
}

const _missingResponseBody = ErrorEnvelope(12590, "Missing response body");
const _cannotConnectToHost = ErrorEnvelope(12591, "Cannot connect to host");
