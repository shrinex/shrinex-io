/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:shrinex_io/src/http/http_message.dart';
import 'package:shrinex_io/src/http/http_method.dart';
import 'package:shrinex_io/src/server_options.dart';

/// Encapsulates request body
abstract class HttpOutputMessage extends HttpMessage {
  /// Request body, null by default
  dynamic get body => null;
}

/// A type that represents a client HTTP request
abstract class HttpRequest extends HttpOutputMessage {
  /// Request path
  String get path;

  /// Request method
  HttpMethod get method;

  /// Optional base url, overrides [ServerOptions.baseUrl] if present
  String? get baseUrl => null;

  /// Optional read timeout, overrides [ServerOptions.readTimeout] if present
  int? get readTimeout => null;

  /// Optional connect timeout, overrides [ServerOptions.connectTimeout] if present
  int? get connectTimeout => null;

  /// Query parameters
  Map<String, dynamic> get queryParams => {};
}