/*
 * Created by Archer on 2022/12/15.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shrinex_io/src/client/rest_client.dart';
import 'package:shrinex_io/src/client/rest_options.dart';
import 'package:shrinex_io/src/http/http_request.dart';
import 'package:shrinex_io/src/http/http_response.dart';

class DioRestClient implements RestClient {
  final Dio _restClient;

  final RestOptions restOptions;

  factory DioRestClient.using({
    required RestOptions restOptions,
  }) =>
      DioRestClient(
        restOptions: restOptions,
        restClient: _newDio(restOptions),
      );

  @visibleForTesting
  DioRestClient({
    required Dio restClient,
    required this.restOptions,
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

  static Dio _newDio(RestOptions restOptions) {
    var options = BaseOptions(
      baseUrl: restOptions.baseUrl,
      responseType: ResponseType.json,
      validateStatus: (status) => true,
      receiveDataWhenStatusError: true,
      contentType: Headers.jsonContentType,
      receiveTimeout: restOptions.readTimeout,
      connectTimeout: restOptions.connectTimeout,
    );
    return Dio(options);
  }
}
