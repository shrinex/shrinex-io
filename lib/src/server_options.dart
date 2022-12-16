/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

/// A type that knows the location of ShrineX API
abstract class ServerOptions {
  /// Base url for HTTP request
  String get baseUrl;

  /// How long should we wait before receiving a reply
  int get readTimeout;

  /// How long should we wait before connecting to server
  int get connectTimeout;

  factory ServerOptions(
    String baseUrl, {
    int readTimeout = 5000,
    int connectTimeout = 2000,
  }) =>
      _ServerOptions(
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
        other.baseUrl == baseUrl &&
        other.readTimeout == readTimeout &&
        other.connectTimeout == connectTimeout;
  }

  @override
  int get hashCode => Object.hash(
        baseUrl,
        readTimeout,
        connectTimeout,
      );
}

class _ServerOptions with ServerOptions {
  @override
  final String baseUrl;

  @override
  final int readTimeout;

  @override
  final int connectTimeout;

  const _ServerOptions(
    this.baseUrl,
    this.readTimeout,
    this.connectTimeout,
  );
}
