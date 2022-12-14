/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

/// A type that encapsulates context about an error
class ErrorEnvelope {
  /// Unknown error
  static const unknown = ErrorEnvelope(
    code: -1,
    message: "未知错误",
  );

  final int code;
  final String message;

  const ErrorEnvelope({
    required this.code,
    required this.message,
  });
}
