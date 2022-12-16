/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:shrinex_io/src/client/rest_options.dart';
import 'package:shrinex_io/src/http/http_message.dart';
import 'package:shrinex_io/src/http/http_method.dart';

/// Encapsulates request body
abstract class HttpOutputMessage extends HttpMessage {
  /// Request body, null by default
  dynamic get body => null;

  /// This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions
  const HttpOutputMessage();
}

/// A type that represents a client HTTP request
abstract class HttpRequest extends HttpOutputMessage {
  /// Request path
  String get path;

  /// Request method
  HttpMethod get method;

  /// Optional base url, overrides [RestOptions.baseUrl] if present
  String? get baseUrl => null;

  /// Optional read timeout, overrides [RestOptions.readTimeout] if present
  int? get readTimeout => null;

  /// Optional connect timeout, overrides [RestOptions.connectTimeout] if present
  int? get connectTimeout => null;

  /// Query parameters
  Map<String, dynamic> get queryParams => {};

  /// This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions
  const HttpRequest();
}

/// Used for predefined requests
class ClientHttpRequest implements HttpRequest {
  @override
  final String path;

  @override
  final dynamic body;

  @override
  final String? baseUrl;

  @override
  final int? readTimeout;

  @override
  final HttpMethod method;

  @override
  final int? connectTimeout;

  @override
  final Map<String, dynamic> queryParams;

  @override
  final Map<String, List<String>> headers;

  const ClientHttpRequest({
    this.body,
    this.baseUrl,
    this.readTimeout,
    this.connectTimeout,
    required this.path,
    required this.method,
    required this.headers,
    required this.queryParams,
  });
}
