/*
 * Created by Archer on 2022/12/11.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:dio/dio.dart';
import 'package:shrinex_io/src/http_message.dart';

/// Encapsulates response body
mixin HttpInputMessage on HttpMessage {
  /// Response body, null by default
  dynamic get body => null;
}

/// A type that represents a client HTTP response
mixin HttpResponse on HttpInputMessage {
  /// Status code
  int? get statusCode => null;

  /// Status message
  String? get statusMessage => null;
}

class _HttpResponse implements HttpResponse {
  final Response response;

  const _HttpResponse(this.response);

  @override
  dynamic get body => response.data;

  @override
  int? get statusCode => response.statusCode;

  @override
  String? get statusMessage => response.statusMessage;

  @override
  Map<String, List<String>> get headers => response.headers.map;
}

extension HttpResponseConvertible on Response {
  HttpResponse asHttpResponse() => _HttpResponse(this);
}
