/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shrinex_io/src/bearer_token.dart';
import 'package:shrinex_io/src/http_request.dart';
import 'package:shrinex_io/src/http_response.dart';
import 'package:shrinex_io/src/server_options.dart';
import 'package:shrinex_io/src/types.dart';

/// A type that knows how to fetch ShrineX data
abstract class Service {
  /// Used to authenticate ShrineX api
  BearerToken? get bearerToken;

  /// The [ServerOptions] associated with this [Service]
  ServerOptions get serverOptions;

  late final _restClient = () {
    var options = BaseOptions(
      baseUrl: serverOptions.baseUrl,
      responseType: ResponseType.json,
      validateStatus: (status) => true,
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

  /// Returns a new service with the [Service] token replaced
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Service &&
        other.bearerToken == bearerToken &&
        other.serverOptions == serverOptions;
  }

  @override
  int get hashCode => (bearerToken?.hashCode ?? 7) ^ serverOptions.hashCode;
}

/// Reactive extension for [Service]
extension ReactiveX on Service {
  /// Entry point for making HTTP request
  /// Once called, the method returns a cold but broadcast stream
  Stream<Map<String, dynamic>> observe(
    HttpRequest request, {
    RequestCallback requestCallback = defaultRequestCallback,
    ExceptionHandler exceptionHandler = defaultExceptionHandler,
    ResponseErrorHandler responseErrorHandler = defaultResponseErrorHandler,
  }) {
    requestCallback(request);
    final options = RequestOptions(
      path: request.path,
      data: request.body,
      headers: request.headers,
      method: request.method.rawValue,
      queryParameters: request.queryParams,
      responseType: _restClient.options.responseType,
      contentType: _restClient.options.contentType,
      validateStatus: _restClient.options.validateStatus,
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
                (await _restClient.fetch<Map<String, dynamic>>(options))
                    .asHttpResponse();
            if (responseErrorHandler.hasError(response)) {
              return Future<Map<String, dynamic>>.error(
                  responseErrorHandler.handleError(request, response));
            }
            return Future<Map<String, dynamic>>.value(response.body!);
          } on Exception catch (ex) {
            return Future<Map<String, dynamic>>.error(exceptionHandler(ex));
          }
        }());
      },
      reusable: true,
    );
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
