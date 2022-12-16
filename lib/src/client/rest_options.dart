/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

/// A type that knows the location of ShrineX API
abstract class RestOptions {
  /// Base url for HTTP request
  String get baseUrl;

  /// How long should we wait before receiving a reply
  int get readTimeout;

  /// How long should we wait before connecting to server
  int get connectTimeout;

  factory RestOptions(
    String baseUrl, {
    int readTimeout = 5000,
    int connectTimeout = 2000,
  }) =>
      _RestOptions(
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
    return other is RestOptions &&
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

class _RestOptions with RestOptions {
  @override
  final String baseUrl;

  @override
  final int readTimeout;

  @override
  final int connectTimeout;

  const _RestOptions(
    this.baseUrl,
    this.readTimeout,
    this.connectTimeout,
  );
}
