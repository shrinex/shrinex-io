/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:shrinex_core/shrinex_core.dart';

enum Kind implements SelfDescribing, RawEnum<int> {
  dev(1, "开发环境"),
  prod(2, "生产环境"),
  local(3, "本地环境"),
  ;

  @override
  final int rawValue;

  @override
  final String description;

  const Kind(
    this.rawValue,
    this.description,
  );
}

/// A type that knows the location of a ShrineX API.
abstract class ServerOptions {
  Kind get kind;

  String get baseUrl;

  int get readTimeout;

  int get connectTimeout;

  factory ServerOptions(
    Kind kind,
    String baseUrl, {
    int readTimeout = 5000,
    int connectTimeout = 2000,
  }) =>
      _ServerOptions(
        kind,
        baseUrl,
        readTimeout,
        connectTimeout,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ServerOptions &&
        other.kind == kind &&
        other.baseUrl == baseUrl &&
        other.readTimeout == readTimeout &&
        other.connectTimeout == connectTimeout;
  }

  @override
  int get hashCode => Object.hash(
        kind,
        baseUrl,
        readTimeout,
        connectTimeout,
      );
}

class _ServerOptions with ServerOptions {
  @override
  final Kind kind;

  @override
  final String baseUrl;

  @override
  final int readTimeout;

  @override
  final int connectTimeout;

  const _ServerOptions(
    this.kind,
    this.baseUrl,
    this.readTimeout,
    this.connectTimeout,
  );
}
