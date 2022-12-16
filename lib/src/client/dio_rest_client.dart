/*
 * Created by Archer on 2022/12/15.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shrinex_io/src/client/rest_client.dart';
import 'package:shrinex_io/src/http/http_request.dart';
import 'package:shrinex_io/src/http/http_response.dart';
import 'package:shrinex_io/src/server_options.dart';

class DioRestClient implements RestClient {
  final Dio _restClient;

  final ServerOptions serverOptions;

  factory DioRestClient.using(
    ServerOptions serverOptions,
  ) =>
      DioRestClient(
        serverOptions: serverOptions,
        restClient: _newDio(serverOptions),
      );

  @visibleForTesting
  DioRestClient({
    required Dio restClient,
    required this.serverOptions,
  }) : _restClient = restClient;

  @override
  Future<HttpResponse> execute(HttpRequest request) async {
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
    return (await _restClient.fetch(options)).asHttpResponse();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DioRestClient &&
          runtimeType == other.runtimeType &&
          _restClient == other._restClient;

  @override
  int get hashCode => _restClient.hashCode;

  static Dio _newDio(ServerOptions serverOptions) {
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
  }
}
